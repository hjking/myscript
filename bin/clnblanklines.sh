#!/bin/bash

#  Delete blank lines from a file
#  Usage: clnblanklines file
#

SUCCESS=0
E_NO_ARGS=65

# Usage
if [ -z "$1" ]
then
    echo "Usage: `basename $0` filename"
    exit $E_NO_ARGS
fi

fn="$1"

mv -f $1 "$fn".old
cat "$fn".old | awk '$0!~/^$/ {print $0}' > $fn

echo -n " ---> Remove backup file:" "$fn".old "?"
read reply

case "$reply" in
    y|Y|YES|yes)
        rm -i "$fn".old
        ;;
    n|N|no|NO)
        ;;
    *)
        echo "You did not make a choice, please remove it by yourself!"
esac

exit 0

#####
# End of Script
###################
