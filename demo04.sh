#!/bin/sh
# check modifications
x=0
while test $x -lt 5
do
    if test demo0$x.sh -nt demo0$x.py 
    then
        echo "Warning, demo0$x.sh has been edited."
    fi
    x=`expr $x + 1`
done
x=0
while test $x -lt 5
do
    if test test0$x.sh -nt test0$x.py 
    then
        echo "Warning, test0$x.sh has been edited."
    fi
    x=`expr $x + 1`
done
