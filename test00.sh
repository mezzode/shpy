#!/bin/sh

expr \( \( \( \( $1 \* 2 \) + 10 \) \/ 2 \) - $1 \) # number magic trick
# should print 5 no matter what input
