#!/bin/bash
#ָ�����еĽű�shell
#���нű�Ҫ���û�ִ��Ȩ��
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
#�ȱ������ݿ�
cp /opt/mysql/my.cnf $bakdir/$dirname/db/my.cnf
cd /opt/mysql
mysqldump --opt -u zhy -p --password=1986 test>$bakdir/$dirname/db/test.sql
mysqldump --opt -u zhy -p --password=1986 phpwind>$bakdir/$dirname/db/phpwind.sql
#Զ�̿�����Ŀ¼Ҫ�п�дȨ��
scp -r /backup/$dirname root@10.1.1.178:/backup

