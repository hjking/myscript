#!/bin/bash
#指定运行的脚本shell
#运行脚本要给用户执行权限
bakdir=/backup
month=`date +%m`
day=`date +%d`
year=`date +%Y`
hour=`date +%k`
min=`date +%M`
dirname=$year-$month-$day-$hour-$min

mkdir $bakdir/$dirname
mkdir $bakdir/$dirname/conf
mkdir $bakdir/$dirname/web
mkdir $bakdir/$dirname/db

#备份conf，检测通过
gzupload=upload.tgz
cp /opt/apache2/conf/httpd.conf $bakdir/$dirname/conf/httpd.conf
cd /opt/apache2/htdocs/php
tar -zcvf $bakdir/$dirname/web/$gzupload ./upload
#远程拷贝的目录要有可写权限
scp -r /backup/$dirname root@10.1.1.178:/backup

