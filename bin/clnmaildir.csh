#!/bin/sh
#-------- remove junk mail headers from all mail files in a dir
###	  cd dir  and  run this script: clnmaildir 
### see clnmail
###................ set the path to the sed-commands file:
cleanlist="$HOME/.m/sed.clnmail.list"

echo "cleanlist = " $cleanlist
  if [ ! -r $cleanlist ]
  then
	echo '$cleanlist not readable ?  exiting'
	exit
  fi
#
/usr/bin/ls ./ > tmpflist
for fn in `cat ./tmpflist`
do
  if [ -f $fn -a "$fn" != tmpflist ]  ## test if a regular file
  then
             ext=`/usr/bin/ls $fn | sed 's/^.*\.//'`
    if   [ "$ext" = gz ]
    then
        echo " --- $fn is gzipped, skipping..."
    elif [ "$ext" = zip ]
    then
        echo " --- $fn is zipped, skipping..."
    else
      if  grep "^From " $fn > /dev/null
      then
           echo "--->" $fn starts with "From", cleaning it!
	cat    $fn > tmpfile
	sed -f $cleanlist tmpfile > $fn
	mv  -f tmpfile "$fn".was
      else
	echo --- "$fn" is NOT a mail file, skipping it
      fi
    fi
  elif [ "$fn" != tmpflist ]
       then
	   echo " --- $fn is NOT a regular file, skipping it..."
  fi
done
     echo "	Done! delete *.was ?"
#		/usr/bin/rm -f *.was
     /bin/rm -f ./tmpflist*
exit

