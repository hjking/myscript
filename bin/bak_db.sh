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
#热备份数据库
cp /opt/mysql/my.cnf $bakdir/$dirname/db/my.cnf
cd /opt/mysql
mysqldump --opt -u zhy -p --password=1986 test>$bakdir/$dirname/db/test.sql
mysqldump --opt -u zhy -p --password=1986 phpwind>$bakdir/$dirname/db/phpwind.sql
#远程拷贝的目录要有可写权限
scp -r /backup/$dirname root@10.1.1.178:/backup

