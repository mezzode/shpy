#!/bin/sh
# prints range between first two args and points at third arg if in range
a=$1
b=$2
c=$3
if test $a -lt $b
then
    while test $a -le $b
    do # range up        
        if test $a -eq $c
        then
            echo "$a <<"
        else
            echo $a
        fi
        a=`expr $a + 1` # increment
    done
else
    # echo "$1 is not smaller than $2"
    while test $a -ge $b
    do # range down
        if test $a -eq $c
        then
            echo "$a <<"
        else
            echo $a
        fi
        a=`expr $a - 1` # increment
    done
fi
