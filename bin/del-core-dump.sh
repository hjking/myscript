#!/bin/bash

# delete core dump files

DIR=~

find $DIR -name 'core*' -exec rm {} \;

exit 0
