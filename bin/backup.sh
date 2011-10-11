
#!/bin/bash
#author:        InBi
#date:          2011-07-28
#role:          backup files periodically.
#website:       http://www.itwhy.org/2011/07-28/707.html
##################################################
LogFile=/backup/log/`date +"%Y-%m"`.log
DATE=`date +"%Y-%m-%d"`
SourceDir=/var/RDfile
BakDir=/backup
RetainDay=20
ProjectLst=/backup/project.lst
##################################################
echo "backup start at $(date +"%Y-%m-%d %H:%M:%S")" > $LogFile
echo "--------------------------------------------------" >> $LogFile
cd $BakDir
PROJECTLIST=`cat $ProjectLst`
for Project in $PROJECTLIST
do
	ProjectData=$SourceDir/$Project
	DestDir=$BakDir/$Project
	PackFile=$DATE.$Project.tgz
	if [ -f $BakDir/$PackFile ]
	then
		echo "backup file have exist !" >>$LogFile
	else
		cp -RHpf $ProjectData $DestDir > /dev/null
		tar -zcvf $PackFile $Project > /dev/null
		echo "backup $Project done into $PackFile ">>$LogFile
		rm -rf $Project
	fi
	OldFile="$BakDir/"$(date --date="$RetainDay days ago" +"%Y-%m-%d").$Project.tgz
	if [ -f $OldFile ]
	then
		rm -f $OldFile > /dev/null
		echo "[$OldFile],Delete Old File Success!" >> $LogFile
	fi
	echo " " >> $LogFile
done
echo "--------------------------------------------------" >> $LogFile
echo "backup end at $(date +"%Y-%m-%d %H:%M:%S")" >> $LogFile
echo " " >> $LogFile
exit 0
