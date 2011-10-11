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

#����conf�����ͨ��
gzupload=upload.tgz
cp /opt/apache2/conf/httpd.conf $bakdir/$dirname/conf/httpd.conf
cd /opt/apache2/htdocs/php
tar -zcvf $bakdir/$dirname/web/$gzupload ./upload
#Զ�̿�����Ŀ¼Ҫ�п�дȨ��
scp -r /backup/$dirname root@10.1.1.178:/backup

