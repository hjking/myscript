#!/bin/bash

for filename in *
do
    if [ -d $filename ]
    then
        echo $filename
        cp -f 1vcs.csh $filename/
        cp -f 2verdi.csh $filename/
    fi
done
