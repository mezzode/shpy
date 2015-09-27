#!/usr/bin/python2.7 -u
import os
# check modifications
x = 0
while (int(x) < 5):
    if os.path.exists('demo0' + str(x) + '.sh') and (not os.path.exists('demo0' + str(x) + '.py') or os.stat('demo0' + str(x) + '.sh').st_mtime > os.stat('demo0' + str(x) + '.py').st_mtime):
        print 'Warning, demo0' + str(x) + '.sh has been edited.'
    x = (int(x) + 1)
x = 0
while (int(x) < 5):
    if os.path.exists('test0' + str(x) + '.sh') and (not os.path.exists('test0' + str(x) + '.py') or os.stat('test0' + str(x) + '.sh').st_mtime > os.stat('test0' + str(x) + '.py').st_mtime):
        print 'Warning, test0' + str(x) + '.sh has been edited.'
    x = (int(x) + 1)
