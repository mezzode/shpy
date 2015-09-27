#!/usr/bin/python2.7 -u
import sys
# test echo
a = 'sh'
b = 'py'
c = 'shpy'
d = a + b
# double quotes
print 'with double quotes'
print a + b + ' converts ' + a + ' to ' + b + '\n'
# single quotes
print 'with single quotes'
print '$a$b converts $a to $b\n'
# echo -n
print 'with echo -n'
sys.stdout.write(a + b) # trailing whitespace
# echo " converts $a to $b"
sys.stdout.write(' converts ')
sys.stdout.write(a + ' ')
sys.stdout.write('to')
sys.stdout.write(' ' + b + ' ' + '\n')
print
print 'examples'
print 'for example ' + b + '.' + a + ' to ' + a + '.' + b
print 'for example ' + b + '.sh to ' + a + '.py'
print a + b + ' == ' + c + ' == ' + d + ' ' + '==' + ' ' + 'shpy'
