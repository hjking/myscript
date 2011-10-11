#!/bin/csh -f
#--------- find location of "file" in dir /ho/ (much simpler than glimpse!)
#	   by searching thru ~/.MY/files.ho.gz
#	   which is created via script mkfiles
#   usage: ffl file

# echo " "
#echo "	---- looking in /ho/ ----"
echo "	----   found in /ho/ ---- Use q to end it" > /tmp/grep.files.ho
echo "" >> /tmp/grep.files.ho
gunzip -c ~/.MY/files.ho.gz | grep -i $1 >> /tmp/grep.files.ho 
more -i /tmp/grep.files.ho

echo ""
echo "	..... Done.  Removing /tmp/grep.files.ho ....."
/bin/rm -f /tmp/grep.files.ho

### replaces
# alias  ff 'gunzip -c ~/.MY/files.ho.gz | grep -i \!* | more'
# old version: 
# alias ff 'grep \!* ~/.MY/files.ho | more'

# also see scripts ffall , mkfiles

