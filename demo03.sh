#!/bin/sh
num=$1
string=$2
c=0
reg='^[0-9]+$'
if test $# -ne 2
then
	echo "Usage: ./echon.sh <number of lines> <string>"
	exit
fi
#if ! [[ $num =~ '^[0-9]+$' ]]
# if echo "$1" | egrep -v -q "^[0-9]+$" # i.e. output variable to regex. q suppresses output.
# then
# 	echo "./echon.sh: argument 1 must be a non-negative integer"
# 	exit
# fi
while test $c -lt $num
do
	echo $string
	c=`expr $c + 1`
done
