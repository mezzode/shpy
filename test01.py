#!/usr/bin/python2.7 -u
# test tests
a = 10
if not ((int(a) >= 0) and not (int(a) >= 1)):
    print 'This is printed'
else:
    print 'This is not'
if not (len('zero') == 0):
    print 'This is printed'
else:
    print 'This is not'
if not ((str(a) == '0') and not (str(a) == '1')):
    print 'This is printed'
else:
    print 'This is not'
if not (int(a) >= 0):
    print 'This is not'
else:
    print 'This is printed'
