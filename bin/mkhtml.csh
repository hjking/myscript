#!/bin/csh -f
#### usage: mkhtml [out]
########### create $out.html page, listing all files in ./

set dir = .
ls $dir > files

set listing = "files"
set out = $1

echo " ==== create a HTML page listing files in a specified directory ==== "
echo ""

if ( "$listing" == "" ) then
  echo " --- mkhtml out.html ---  ls > files failed, try again ..."
  echo " ... after you create list_file with:  ls > files"
  echo ""
  exit
endif

if ( "$out" == "" ) then
  echo " --> enter output (base)name  [ blank for index] :"
  set out = $<
  if ( "$out" != "" ) then
    echo " out = $out  will strip off .html ..."
    set outt = `basename $out .html`
    set html = '${outt}.html'
  else
    set html = "index.html"
  endif
endif

echo " This script will create: $html"

echo ""
echo -n " ... enter title in quotes: "
set title = $<

#################### now create the $html file ####################
./html-body.csh  $listing $title >> $html

#------------------- clean up -------------------#

#sed '/href="files"/d' $html > tmp
#rm -f  $html 
#mv tmp $html 
rm -f files
