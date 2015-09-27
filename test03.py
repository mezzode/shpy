#!/usr/bin/python2.7 -u
import glob
# for loop vs ls
for f in sorted(glob.glob("*")):
    print str(f)
print '\n'.join(sorted(glob.glob('*'))) # annoyingly ls translated to python does not have same sort order
