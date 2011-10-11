#!/bin/bash

for dir in dir-{00{1..9},0{10..99},100}
do
    echo $dir
    for file in $dir/file-{A..Z}
    do
        echo `pwd`/$file
        echo `pwd`/$file > $file
        echo line1 >> $file
        echo line2 >> $file
        echo line3 >> $file
        echo line4 >> $file
    done
done
    
