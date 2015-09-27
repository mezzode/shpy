#!/usr/bin/python2.7 -u
import sys
# test nested expr
print ((((int(sys.argv[1]) * 2) + 10) / 2) - int(sys.argv[1])) # number magic trick
# should print 5 given any int
