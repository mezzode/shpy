#!/bin/sh
a=$1
b=$2
if test $a -nt $b
then
    echo "$a is newer than $b"
elif test $a -ot $b
then
    echo "$a is older than $b"
else
    echo "$a and $b are the same age"
fi
