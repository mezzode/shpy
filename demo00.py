#!/usr/bin/python2.7 -u
import sys
# prints range between first two args and points at third arg if in range
a = sys.argv[1]
b = sys.argv[2]
c = sys.argv[3]
if (int(a) < int(b)):
    while (int(a) <= int(b)):
        # range up        
        if (int(a) == int(c)):
            print str(a) + ' <<'
        else:
            print str(a)
        a = (int(a) + 1) # increment
else:
    # echo "$1 is not smaller than $2"
    while (int(a) >= int(b)):
        # range down
        if (int(a) == int(c)):
            print str(a) + ' <<'
        else:
            print str(a)
        a = (int(a) - 1) # increment
