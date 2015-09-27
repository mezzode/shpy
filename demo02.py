#!/usr/bin/python2.7 -u
import os
import sys
a = sys.argv[1]
b = sys.argv[2]
if os.path.exists(str(a)) and (not os.path.exists(str(b)) or os.stat(str(a)).st_mtime > os.stat(str(b)).st_mtime):
    print str(a) + ' is newer than ' + str(b)
elif os.path.exists(str(b)) and (not os.path.exists(str(a)) or os.stat(str(b)).st_mtime > os.stat(str(a)).st_mtime):
    print str(a) + ' is older than ' + str(b)
else:
    print str(a) + ' and ' + str(b) + ' are the same age'
