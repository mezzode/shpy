#!/usr/bin/python2.7 -u
import sys
# test echo
a = 'sh'
b = 'py'
c = 'shpy'
d = str(a) + str(b)
# double quotes
print 'with double quotes'
print str(a) + str(b) + ' converts ' + str(a) + ' to ' + str(b) + '\n'
# single quotes
print 'with single quotes'
print '$a$b converts $a to $b\n'
# echo -n
print 'with echo -n'
sys.stdout.write(str(a) + str(b)) # trailing whitespace
# echo " converts $a to $b"
sys.stdout.write(' converts ')
sys.stdout.write(str(a) + ' ')
sys.stdout.write('to')
sys.stdout.write(' ' + str(b) + ' ' + '\n')
print
print 'examples'
print 'for example ' + str(b) + '.' + str(a) + ' to ' + str(a) + '.' + str(b)
print 'for example ' + str(b) + '.sh to ' + str(a) + '.py'
print str(a) + str(b) + ' == ' + str(c) + ' == ' + str(d) + ' ' + '==' + ' ' + 'shpy'
