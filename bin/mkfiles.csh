#!/bin/csh -f
#
## jul97, dec97, oct98(new version) 	for ares 
#
#### usage: mkfiles [ho usr]
#
## mkfiles: create listing of files for easy finding with script ffl
##	    creates ~/.MY/FILE.DATE.gz  <- /ho/.MY/FILE.gz

set EXT = "$1"
if( "$1" == "" ) then
  echo -n "   -------> Enter ho _OR_ usr:"
  set EXT = $<
endif

##----------- set the FILE name to operate on:
set FILE = "files.${EXT}"

chdir ~/.MY

if( -l "$FILE".gz ) then
	echo "	... unlinking the existing ${FILE}.gz ..."
	/bin/rm -f "$FILE".gz
endif
echo   		--- creating ~/.MY/"$FILE".gz ---

switch ( "$EXT" )
 case ho:
	echo ""
	echo " 		--- finding  /ho/* ---"
	find /ho/*      -print >  $FILE
	echo ""
	echo " 		--- finding  /ho/.MY/* ---"
	find /ho/.MY/*  -print >> $FILE
	echo ""
	echo " 		--- finding  /ho/.m/* ---"
	find /ho/.m/*   -print >> $FILE
 breaksw
 case usr:
	echo ""
	echo "		--- finding  /etc/* ---"
	find /etc/*   -print >  $FILE
	echo ""
	echo "		--- finding  /opt/* ---"
	find /opt/*   -print >> $FILE
	echo ""
	echo "		--- finding  /sbin/* ---"
	find /sbin/*  -print >> $FILE
	echo ""
	echo "		--- finding  /usr/* ---"
	find /usr/*   -print >> $FILE
 breaksw
endsw

chmod 600 $FILE
gzip  $FILE

#ls -o "$FILE".*
echo ""
echo "		--- DATE-stamping it ---"
set DATE = `date +%y-%m-%d`
mv     ${FILE}.gz         ${FILE}.${DATE}.gz
echo "		--- linking it to ${FILE}.gz ---"
ln -s  ${FILE}.${DATE}.gz ${FILE}.gz

ls -s  ${FILE}.${DATE}.gz

echo ""
echo "  --- done ---   To find a file do:  ffl filename "
exit


