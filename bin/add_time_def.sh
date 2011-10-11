#!/bin/bash

for filename in *
do
    if [ -d $filename ]
    then
        echo $filename

        cd $filename
        if [ -z time.def ]
        then
            echo "time.def exists"
        else
            touch time.def
        fi
        cd ..
    fi
done
