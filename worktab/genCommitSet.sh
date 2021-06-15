#!/bin/sh

if [ -z $1 ] || [ -z $2 ];then
 exit
fi

from=$1
to=$2

echo 'select commitID by your ID' > $to
echo '' >> $to

i=1

for file in $from/*
do
 cat $file | while read line
 do
 #ID=`sed 's/^commit \([^ ]*\).*/\1/' <<< $line`
 ID=`echo $line | awk -F' ' '{print $2}'`
 echo '['$i'] '$ID >> $to
 break
 done
 i=$(($i+1))
done
