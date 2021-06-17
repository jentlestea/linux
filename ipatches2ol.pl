#!/usr/bin/perl -w
# cat ipatches2ol.pl

# use Data::Dumper;
# use XML::Simple;

use feature ":5.10.0";
use File::Basename;
use Getopt::Long;

my $DEBUG = 1;
my $OLD;
my $RECENT;
my $UPDATE;
my $FILE; # patch list file
my $STYLE = "oneline"; # oneline, patchwork
#my $URL = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=";
my $URL = "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?id=";
my $TAG;
my $FROM;
my $LOCAL;
my $VERSION = "unspecified";
my $VERBOSE;

usage() unless (@ARGV);
my $result = GetOptions(
	'debug|d!' => \$DEBUG,
	'verbose|v!' => \$VERBOSE,
	'old|o!' => \$OLD,
	'file|f=s' => \$FILE,
	'version=s' => \$VERSION,
	'style=s' => \$STYLE,
	'url=s' => \$URL,
	'tag=s' => \$TAG,
	'from=s' => \$FROM,
	'checkdate=s' => \$CHECKDATE,
	'recent|r!' => \$RECENT,
	'local|l!' => \$LOCAL,
	'update|u!' => \$UPDATE,
	'help|h|?' => \&usage,
) or usage();

my $LOGFILE = "/var/log/update-cve-`date +%F-%H`.log";
sub syslog {
	my @lines = @_;

	my $ts = `date "+%F %T"`; chomp $ts;
	foreach (@lines) {
		chomp;
		system "echo [$ts] \"$_\" >> $LOGFILE";
		#say "[$ts] $_";
		say "[$ts] $_" if ($VERBOSE);
	}
}

sub cmd {
	my $args = shift;

	if ($args) {
		syslog($args);
		system($args);
	}
}

sub usage {
	say "usage:";
	say " $0 [-d|--debug] [-o|--old] [-r|--recent] [-h|-?|--help]";
	say "";
	say "options:";
	say " -d --debug";
	say " show debug message";
	say " -o --old";
	say " import old cves (from 2002 to this year)";
	say " -r --recent";
	say " import recent cves";
	say " -h -? --help";
	say " show this usage information";

	exit(0);
}

sub url {
	my $commit = shift;
	my $url = "$URL" . "COMMIT";

	$url =~ s/COMMIT/$commit/;
	return $url;
}

sub desc {
	my $commit = shift;
	my $str = `git show --stat $commit`;

	$str = url($commit) . "\n\n" . $str;

	return $str;
}

sub from {
	my $commit = shift;

	if ($FROM) {
		return $FROM;
	}
	elsif ($commit) {
		my $tag = `git describe $commit | sed 's/~.*//' | sed 's/-.*//'`; chomp $tag;

		return "mainline-" . $tag;
	}
	else {
		return "unkown";
	}
}

sub commit {
}

#
# search($param);
#

sub search {
	my ($product, $version, $mod, $commit) = @_;

	my $file = "search.tpl";
	open(my $fh,">", $file)
		or die "Could not open file '$file'";
	print $fh
	"{
	product => \"$product\",
	version => \"$version\",
	cf_upstream_commit => \"$commit\",
	};
	";
	close $fh;

	#my $cmd = './bz_webservice_demo.pl --uri "http://bugzilla.openeuler.org/xmlrpc.cgi" --login "kernel-bugs@openeuler.org" --password "huawei" --rememberlogin --search=search.tpl';
	my $cmd = './bz_webservice_demo.pl --uri "http://bugzilla.openeuler.org/xmlrpc.cgi" --login "kernel-bugs@openeuler.org" --password "huawei" --search=search.tpl';

	my @ids = `$cmd`;
	(my $ids) = grep (/^ids/, @ids);
	$ids =~ s/^ids://;

	return (split / /, $ids);
}

#
# usage:
# $this->description();
#
sub description {
}

sub file_a_new {
	my ($subsys, $version, $subject, $desc, $url, $commit, $mod, $from, $tag, $type, $date, $checkdate) = @_;

	my $file = "newpatch.tpl";
	open(my $fh,">", $file)
		or die "Could not open file '$file'";
	print $fh
	"{
	product => \"Patches\",
	component => \"$subsys\",
	version => \"$version\",
	summary => \'$subject\',
	description => \'$desc\',

	cf_upstream_commit => \"$commit\",
	};
	";
	close $fh;

	#system('./bz_webservice_demo.pl --uri "http://bugzilla.openeuler.org/xmlrpc.cgi" --login "kernel-bugs@huawei.com" --password "huawei" --rememberlogin --create=./newpatch.tpl');
	system('perl ./bz_webservice_demo.pl --uri "https://bugzilla.openeuler.org/xmlrpc.cgi" --login "kernel-bugs@openeuler.org" --password "huawei" --create=./newpatch.tpl');
}

my @SUBSYS = ("Arch", "Driver", "Kernel", "Memory", "Network", "Security", "Storage", "Tools");

sub checksubsys {
	my $sys = shift;

	if (grep(/^$sys$/, @SUBSYS)) {
		return $sys;
	}
	else {
		return "Unkown";
	}
}

sub import_patches {
	my $filename = shift;

	open(FH, '<', $filename) or die $!;

	while(<FH>){
		# |commit|subject|subsys|mod|type|date|
		if (tr/|/|/ != 7) {
			say "invalid format for this patch, please check. ";
			say "only accept format: |commit|subject|subsys|mod|type|date|";
			say "$_";
			exit(-1);
		}

		my ($ignore, $commit, $subject, $subsys, $mod, $type, $date) = split('\|', $_);
		my $desc = desc($commit);
		my $from = from($commit);
		my $url = url($commit);

		$commit =~ s/ *$//;
		$subject =~ s/ *$//;
		$subject =~ s/'//g;
		$commit =~ s/ *$//;
		$subsys =~ s/ *$//; $mod =~ s/ *$//; $type =~ s/ *$//; $date =~ s/ *$//;
		$subsys = checksubsys($subsys);

		#my @ids = search("Patches", $VERSION, $mod, $commit);
		my @ids = search("Patches", $VERSION, $mod, $commit);
		if (@ids) {
			say "Found similar patch(es): @ids, the flowing patch has been submitted already, please review.";
			say "PATCH: " . $_;
		}
		else {
			file_a_new($subsys, $VERSION, $subject, $desc, $url, $commit, $mod, $from, $TAG, $type, $date, $CHECKDATE);
		}
	}

	close(FH);
}

my @comp = ("Arch", "Driver", "Kernel", "Memory", "Network", "Security", "Storage", "Tools", "Unkown");

sub getsubsys {
	my $sys = shift;

	if ($sys eq "arch") {
		return "Arch";
	}
	elsif ($sys eq "drivers") {
		return "Driver";
	}
	elsif ($sys eq "kernel" || $sys eq "lib" || $sys eq "ipc") {
		return "Kernel";
	}
	elsif ($sys eq "mm") {
		return "Memory";
	}
	elsif ($sys eq "net") {
		return "Network";
	}
	elsif ($sys eq "crypto" || $sys eq "security") {
		return "Security";
	}
	elsif ($sys eq "block" || $sys eq "fs") {
		return "Storage";
	}
	elsif ($sys eq "tools" || $sys eq "scripts") {
		return "Tools";
	}
	else {
		return "Unkown";
	}
}

sub import_patches_oneline {
	my $filename = shift;

	open(FH, '<', $filename) or die $!;

	while(<FH>){
		my ($commit) = split(' ', $_);
		my $desc = desc($commit);
		my $from = from($commit);
		my $url = url($commit);
		my $date = `git log --pretty=%aD -1 $commit`; chomp $date;
		my $subject = `git log --pretty=%s -1 $commit`; chomp $subject;
		my $dirstat = ` git log --dirstat -1 $commit |grep "% " |sort -rn`; chomp $dirstat;
		my $subsys = `git log --pretty=%s -1 $commit | cut -d ":" -f1`; chomp $subsys;
		my $type = `git log -1 $commit |grep -i "category"`; chomp $type;

		if ($dirstat =~ /\s+\d+\.\d+%\s+([\w_-]+)\//) {
			$subsys = getsubsys($1);
		}

		if ($dirstat =~ /\s+\d+\.\d+%\s+[\w_-]+\/([\w_-]+)/) {
			$mod = $1;
		}
		elsif ($dirstat =~ /\s+\d+\.\d+%\s+([\w_-]+)\//) {
			$mod = $1;
		}
		else {
			$mod = $subsys;
		}

		if ($type =~ /\s+\w+:\s*(\w+)/) {
			$type = $1;
		}

		$commit =~ s/ *$//;
		$subject =~ s/ *$//;
		$subject =~ s/'//g;
		$subject =~ s/|//g;
		$desc =~ s/'//g;
		$desc =~ s/|//g;
		$commit =~ s/ *$//;
		$subsys =~ s/ *$//;
		$mod =~ s/ *$//;
		$type =~ s/ *$//;
		$date =~ s/ *$//;

		file_a_new($subsys, $VERSION, $subject, $desc, $url, $commit, $mod, $from, $TAG, $type, $date, $CHECKDATE);
	}

	close(FH);
}

sub process {
	if ($STYLE eq "patchwork") {
		import_patches($FILE, $VERSION);
	}
	elsif ($STYLE eq "oneline") {
		import_patches_oneline($FILE, $VERSION);
	}
}

#
# main
#
process();


# usage:
# $ cat patch.txt
# 7111912 IB/hns: Combine hns_roce_cmd and hns_roce_cmd_box
# 2a8a334 mm, oom: rework oom detection
# 4e20c19 hisi_sas:add chip fatal error
# 0a39474 hisi_sas:add routine test function
# baa35a2 hisi_sas:modify or add some maintenance print.
#
# $./patches2el.pl -f patch.txt
