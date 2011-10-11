#!/bin/bash

#Archive files in dir, excluding subdirs
cd ..
find bin -type f -maxdepth 1 | tar czvf bin.tgz --exclude=bin.tgz -T -


