#!/bin/sh

cd hulk

git add -A
git reset ae334bc7cb47 --hard

for file in ./LTS-patches/*
do
 git am --reject $file
 if [ $? -ne 0 ];then
 git am --abort
 cp $file ./LTS_failed
 else
 cp $file ./LTS_ok
 fi
 git add -A
 git reset ae334bc7cb47 --hard
done
