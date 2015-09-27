#!/usr/bin/python2.7 -u
import sys
# test translation of $* and $@
print '$@'
for a in ' '.join(sys.argv[1:]):
    print str(a)
print
print '$*'
for a in ' '.join(sys.argv[1:]):
    print str(a)
