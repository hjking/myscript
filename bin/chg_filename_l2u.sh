#!/bin/bash

# Change lower case filename to upper case

if [ $# -lt 1 ]
then
    echo "Please at least specify a file"
    exit 0
fi

for file in $*
do
  mv $file `echo $file | tr [:lower:] [:upper:]` 2>/dev/null
done

exit 0
