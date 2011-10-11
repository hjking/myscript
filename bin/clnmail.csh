#!/bin/sh
#-------- remove junk mail headers from a mail file
#  usage: clnmail file
#
### checks to make sure it's a mail file (starts with: From)
### needs a $cleanlist file containing sed commands of 
###		mail headers to delete,  e.g.:
# /^Date:/d
# /^Content-Description:/d
# /^In-Reply-To:/d
### ................................. set the path to it:
cleanlist="$HOME/.m/sed.clnmail.list"

fn="$1"

if [ ! -f $cleanlist ]
  then
	echo "$cleanlist does NOT exist, exiting"
  exit 1
fi

if  [ -f $fn ]
 then
	#... extract the filename extension ...:
             ext=`echo $fn | sed 's/^.*\.//'`
    if   [ "$ext" = gz ]
     then
        echo " --- $fn is gzipped, skipping..."
    elif [ "$ext" = zip ]
     then
        echo " --- $fn is zipped, skipping..."
    else
      if  grep "^From " $fn > /dev/null
      then
	echo "--->" $fn starts with "From", cleaning it ....
	cat $fn > tmpfile
	sed -f $cleanlist tmpfile > $fn
	mv -f tmpfile "$fn".was
	echo "input file was saved in: " "$fn".was " Delete it ?"
        /usr/bin/rm -i "$fn".was
      fi
    fi
else
    echo "$fn is NOT a mail file, exiting "
fi

##replaces:
# alias cleanmail 'mv -f \!* "\!^".was ;\
#		 sed -f $HOME/.m/sed.cleanlist "\!^".was > "\!^" ;\
#		 /usr/bin/rm -i "\!^".was'
### also see: clnmaildir

