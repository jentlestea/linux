{
	product => "Patches",
	component => "Network",
	version => "unspecified",
	summary => 'neighbour: allow NUD_NOARP entries to be forced GCed',
	description => 'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?id=ddf088d7aaaaacfc836104f2e632b29b1d383cfc

commit ddf088d7aaaaacfc836104f2e632b29b1d383cfc
Author: David Ahern <dsahern@kernel.org>
Date:   Mon Jun 7 11:35:30 2021 -0600

    neighbour: allow NUD_NOARP entries to be forced GCed
    
    commit 7a6b1ab7475fd6478eeaf5c9d1163e7a18125c8f upstream.
    
    IFF_POINTOPOINT interfaces use NUD_NOARP entries for IPv6. Its possible to
    fill up the neighbour table with enough entries that it will overflow for
    valid connections after that.
    
    This behaviour is more prevalent after commit 58956317c8de ("neighbor:
    Improve garbage collection") is applied, as it prevents removal from
    entries that are not NUD_FAILED, unless they are more than 5s old.
    
    Fixes: 58956317c8de (neighbor: Improve garbage collection)
    Reported-by: Kasper Dupont <kasperd@gjkwv.06.feb.2021.kasperd.net>
    Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
    Signed-off-by: David Ahern <dsahern@kernel.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

 net/core/neighbour.c | 1 +
 1 file changed, 1 insertion(+)
',

	cf_upstream_commit => "ddf088d7aaaaacfc836104f2e632b29b1d383cfc",
	};
	