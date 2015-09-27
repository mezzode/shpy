#!/bin/sh
for f in *.*
do
    echo `wc -l $f`
done
