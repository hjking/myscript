#!/bin/bash

# backup the files which changed at last 24 hours

# set default backup file
BACKUP_FILE=backup-$(data +%Y-%m-%d)

archive=${1:-$BACKUP_FILE}

#tar cvf - `find . -mtime -1 -type f -print` > ${archive}.tar
find . -mtime -1 -type f -print0 | xargs -0 tar rvf "$archive.tar"
gzip ${archive}.tar
echo "Directory $PWD backed up in archive file \"${archive}.tar.gz\"."

exit 0
