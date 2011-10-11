#!/bin/ksh 
#(needs ksh, not sh, for arithmetic)
#
# cntduplines - count duplicate lines in a file
#		(same as clnduplines but don't rename the file)
#
if [ -z "$1" ]; then
 echo
 echo "syntax: cntduplines [filename]"
 echo
 exit
fi

file=$1

echo " --- cntduplines: Searching for duplicate lines in $file ---"
count=0
cat /dev/null > $file.clean
while read line
do
  found=`grep "$line" $file.clean`
  if [ -n "$found" ]; then
    echo  ".\c"
    (( count = count + 1 ))		## ksh arithmetic
  else
    echo "$line" >> $file.clean
  fi 
done < $file

echo ""
echo " 		$count dup lines found"

#---------- sh version, much too slow --------
#echo " ... counting lines ..."
## old=`wc -l $file | awk '{ print $1 }'`
#  old=`cat $file | wc -l`
## new=`wc -l $file.clean | awk '{ print $1 }'`
#  new=`cat $file.clean | wc -l`
## VERY slow: echo " ---> `expr $old - $new` dups found"
## that's why used ksh's arithmetic: ((  ))

echo ""

echo " --- cleaned file in $file.clean --- delete it ?"
/bin/rm -i $file.clean

### based on:
# Unix Tip #487- May  2, 1998 http://www.ugu.com/sui/ugu/show?tip.today

### see also: uniq file : eliminate adjacent lines which are identical

