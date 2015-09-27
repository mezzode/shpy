#!/usr/bin/python2.7 -u
import sys
num = sys.argv[1]
string = sys.argv[2]
c = 0
reg = '^[0-9]+$'
if ((len(sys.argv) - 1) != 2):
    print 'Usage: ./echon.sh <number of lines> <string>'
    sys.exit()
#if ! [[ $num =~ '^[0-9]+$' ]]
# if echo "$1" | egrep -v -q "^[0-9]+$" # i.e. output variable to regex. q suppresses output.
# then
# 	echo "./echon.sh: argument 1 must be a non-negative integer"
# 	exit
# fi
while (int(c) < int(num)):
    print str(string)
    c = (int(c) + 1)
