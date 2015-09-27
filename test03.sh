#!/bin/sh
# for loop vs ls
for f in * 
do
    echo $f
done
ls # annoyingly ls translated to python does not have same sort order
