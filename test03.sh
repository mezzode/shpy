#!/bin/sh
# prints range between two numbers, inclusive
a=$1
b=$2
if test $a -lt $b
then
    while test $a -le $b
    do # range up
        echo $a
        a=`expr $a + 1` # increment
    done
else
    # echo "$1 is not smaller than $2"
    while test $a -ge $b
    do # range down
        echo $a
        a=`expr $a - 1` # decrement
    done
fi
