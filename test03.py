#!/usr/bin/python2.7 -u
import sys
# prints range between two numbers, inclusive
a = sys.argv[1]
b = sys.argv[2]
if (int(a) < int(b)):
    while (int(a) <= int(b)):
        # range up
        print a
        a = (int(a) + 1) # increment
else:
    # echo "$1 is not smaller than $2"
    while (int(a) >= int(b)):
        # range down
        print a
        a = (int(a) - 1) # decrement
