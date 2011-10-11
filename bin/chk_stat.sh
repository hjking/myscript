#!/bin/bash

#####################################################
# Auther:   Hong Jin(hong_jin@founder.com)
# Version:  1.0
# Date:     2011-07-21 16:24
#
# Check state of important dirs/files
#
#####################################################

DIRS="/etc /home /bin /sbin /usr/bin /usr/sbin /usr/local /var"

ADMIN="email@you.domain.com"
FROM="admin@your.domain.com"
MAIL_FILE=/tmp/today.mail

# head of email
echo "Subject:$HOSTNAME filesystem check" > $MAIL_FILE
echo "From:$FROM" >> $MAIL_FILE
echo "To:$ADMIN" >> $MAIL_FILE
echo "This is filesystem report comes from $HOSTNAME" >> $MAIL_FILE

# check current process
ps axf >> $MAIL_FILE

# check filesystem
echo "File System Check" >> $MAIL_FILE
ls -alR $DIR | gzip -p > /tmp/today.gz
zdiff /tmp/today.gz /tmp/yesterday.gz >> $MAIL_FILE
mv -f /tmp/today.gz /tmp/yesterday.gz

# send the email
sendmail -t < $MAIL_FILE

