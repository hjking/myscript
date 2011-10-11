#!/bin/csh -f
##none under tcsh
#
#---------- view man pages with more in a new xterm
#	    and optionally save the filtered manpage in $dirpath
#	    (uses ls-F; if not in tcsh, change it to ls -F)
#    usage: manmo command

set dirpath = /usr/local/man/cat1
echo " "
set cmd = $1

if( "$1" == "" ) then
  echo    ' ---  Usage: manmo command  ---'
  echo -n ' ---> Enter command : '
  set cmd = $<
endif

set cmdpath = $dirpath/$cmd
set catpath = "$cmdpath".cat

if ( -f "$catpath".gz ) then
#	# gunzip -c "$catpath".gz | more 
	gunzip "$catpath".gz
	xterm -fn 8x13bold -g 80x30 -e more -i $catpath
	sleep 1
	gzip $catpath
else
	echo " --- filtering: man $cmd | col -b > "$cmd".cat ---"
	man $cmd | col -b > $catpath
	sleep 1
	xterm -fn 8x13bold -g 80x40 -e more -i $catpath
	sleep 1
	gzip $catpath
endif

echo ""
echo "		gzip'd size: "  `ls-F -s "$catpath".gz`
echo -n " --->  enter  y  to remove "$cmd".cat.gz : "
	set yes = $<
	if ( $yes == "y" ) then
		/bin/rm -f "$catpath".gz
	endif

