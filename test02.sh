#!/bin/sh
# test echo
a='sh'
b='py'
c="shpy"
d="$a$b"

# double quotes
echo "with double quotes"
echo "$a$b converts $a to $b\n"

# single quotes
echo 'with single quotes'
echo '$a$b converts $a to $b\n'

# echo -n
echo "with echo -n"
echo -n $a$b      # trailing whitespace
# echo " converts $a to $b"
echo -n ' converts '
echo -n "$a "
echo -n to
echo -n " $b" "\n"
echo
echo 'examples'
echo "for example $b.$a to $a.$b"
echo "for example $b.sh to $a.py"

echo "$a$b == $c == $d" '==' "shpy"
