#!/bin/bash -f

echo ">>>>> User Info <<<<<"
grep $1 /etc/passwd

user_name=`grep $1 /etc/passwd | cut -d':' -f1`

echo ">>>>> In Following Groups: <<<<<"
grep $user_name /etc/group | cut -d':' -f1

exit 0
