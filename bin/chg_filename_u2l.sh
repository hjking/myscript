#!/bin/bash

# Change upper case filename to lower case

if [ $# -lt 1 ]
then
    echo "Please at least specify a file"
    exit 0
fi

for file in $@
do
  mv $file `echo $file | tr [:upper:] [:lower:]` 2>/dev/null
done

exit 0
