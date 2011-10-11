#!/bin/bash

# functions library

########
# $var: string
# ${#var} : length of string
# ${#*}, ${#@} : number of argument
# ${#array[*]}, ${#array[@]} : number of elements in the array



##################################################
## Useful Variables Definations
##################################################

ROOT_UID=0
E_NOT_ROOT=101
MAX_RETVAL=255
SUCCESS=0
FAILURE=-1
E_WRONG_DIR=73

########
# $FUNCNAME: is the name of the current function
# $LINENO: record the line number where this variable is in
# $REPLY: when no variable is specified for 'read' command, this is the default
# $SECONDS: the seconds which the script already ran


########
# if not specified any dir, use current dir
DIR=${1-`pwd`}


##################################################
## Useful Function Definations
##################################################

# Print usage of script
Usage ()
{
  if [ -z "$1" ]
  then
      msg=filename
  else
      msg=$@
  fi

  echo "Usage: `basename $0` "$msg""
}


# Check the user if it's root
Check_If_Root ()
{
  if [ "$UID" -ne "ROOT_UID" ]
  then
      echo "Must be root to run this script!"
      exit $E_NOT_ROOT
  fi
}


# Create a uniqe temp file
Create_Temp_File ()
{
  prefix=temp
  suffix=`eval date +%s`
  Temp_File_Name=$prefix.$suffix
}


# Check all the chars in a string are letters
Is_Alpha2 ()
{
  [ $# -eq 1 ] || return $FAILURE

  case $1 in
      *[!a-zA-Z]*|"") return $FAILURE ;;
      *) return $SUCCESS ;;
  esac
}


# Check all the chars in a string are letters
Is_Digit ()
{
  [ $# -eq 1 ] || return $FAILURE

  case $1 in
      *[!0-9]*|"") return $FAILURE
      *) return $SUCCESS
  esac
}


# abs
abs ()
{
  E_ARG_ERR=-999999

  if [ -z "$1" ]
  then
      return $E_ARG_ERR
  fi

  if [ "$1" -ge 0 ]
  then
      absval=$1
  else
      let "absval = (( 0 - $1 ))"
  fi

  return $absval
}


# Change letters to lower case
To_Lower ()
{
  if [ -z "$1" ]
  then
      echo "(null)"
      return
  fi

  echo "$@" | tr A-Z a-z

  return
}

File_To_Upper ()
{
  tr a-z A-Z < $1  # $1 is a file
}

# check the arguments
Check_Arg ()
{
    while [ $# -gt 0 ]
    do
        case "$1" in
            -d|--debug)
                        DEBUG=1
                        ;;
            -c|--conf)
                        CONFFILE="$2"
                        ;;
            -h|--help)
                        Usage()
                        ;;
        esac
        shift     # check other arguments
    done
}


# Check arrow key
Check_Arr0w_Key ()
{
  OTHER=65
  arrowup='\[A'
  arrowdown='\[B'
  arrowrt='\[C'
  arrowleft='\[D'
  insert='\[2'
  delete='\[3'

  echo -n "Press a key... "
  read -n3 key   # read 3 chars

  echo -n "$key" | grep "$arrowup"
  if [ "$?" -eq $SUCCESS ]
  then
      echo "Up-arrow key pressed"
      exit $SUCCESS
  fi

  echo -n "$key" | grep "$arrowdown"
  if [ "$?" -eq $SUCCESS ]
  then
      echo "Down-arrow key pressed"
      exit $SUCCESS
  fi

  echo -n "$key" | grep "$arrowrt"
  if [ "$?" -eq $SUCCESS ]
  then
      echo "Right-arrow key pressed"
      exit $SUCCESS
  fi

  echo -n "$key" | grep "$arrowleft"
  if [ "$?" -eq $SUCCESS ]
  then
      echo "Left-arrow key pressed"
      exit $SUCCESS
  fi
  
  echo -n "$key" | grep "$insert"
  if [ "$?" -eq $SUCCESS ]
  then
      echo "Insert key pressed"
      exit $SUCCESS
  fi
  
  echo -n "$key" | grep "$delete"
  if [ "$?" -eq $SUCCESS ]
  then
      echo "Delete key pressed"
      exit $SUCCESS
  fi

  echo "Some other key pressed."
  exit $OTHER
}


# delete core dump
Delete-Core-Dump-Files ()
{
DIR=~

find $DIR -name 'core*' -exec rm {} \;

}


# Search ip address in /etc dir
Search-IP-Addr ()
{
  find /etc -exec grep '[0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*' {} \;
}

#################
##  xargs
# copy files in current dir to specified dir
ls . | xargs -i -t cp ./{} $1

# kill process by name
PROCESS_NAME="$1"
ps aux | grep "$PROCESS_NAME" | awk '{print $1}' | xargs -i kill {} 2&>/dev/null

# split files into word
cat "$1" | xargs -n1


#################
##  sed

# delete '.', ',', ' ' in files
sed -e 's/\.//g' -e 's/\,//g' -e 's/ //g' $1

# delete first line
ls -l | sed 1d

#################
##  tr

# transite A-Z to a-z
tr "A-Z" "a-z"

# transite A-Z --> *
tr "A-Z" "*" < $1

# delete 0-9 in file
tr -d 0-9 < $1

# Dos file to UNIX file(new)
CR='\015'
tr -d $CR < $1 > $NEW_FILE

# rot13 encryption
cat "$@" | tr 'a-zA-Z' 'n-za-mN-ZA-M'

# change filename in dir to upper case
Tr_Filename_To_Upper ()
{
  for filename in *
  do
      fname=`basename $filename`
      n=`echo $fname | tr a-z A-Z`
      if [ "$fname" != "$n" ]
      then
          mv $fname $n
      fi
  done

  exit $?
}

Tr_Filename_To_Upper_2 ()
{
  for filename in *
  do
      n=`echo "$filename/" | tr '[:lower:]' '[:upper:]'`
      n=${n%/}
      [[ $filename == $n ]] || mv "$filename" "$n"
  done

  exit $?
}


###########################
## nmap
## scanner for network ports

Scan_Port ()
{
  SERVER=$HOST
  PORT_NO=25

  nmap $SERVER | grep -w "$PORT_NO"

  exit 0
}


# backup the files which changed at last 24 hours
Backup-24-files ()
{
  # set default backup file
  BACKUP_FILE=backup-$(data +%Y-%m-%d)

  archive=${1:-$BACKUP_FILE}

#tar cvf - `find . -mtime -1 -type f -print` > ${archive}.tar
  find . -mtime -1 -type f -print0 | xargs -0 tar rvf "$archive.tar"
  gzip ${archive}.tar
  echo "Directory $PWD backed up in archive file \"${archive}.tar.gz\"."

  exit 0
}

# search `define    _LMC_256_ in sub-dirs
Find-define ()
{
    grep "^\s*\`define.*_LMC_256_" */* >> 256_2.v
    exit 0
}

# copy file to sub-dirs
Copy-file ()
{
    for filename in *
    do
        if [ -d $filename ]
        then
            echo $filename
            cp -f 1vcs.csh $filename/
            cp -f 2verdi.csh $filename/
        fi
    done
}

# Add files in sub-dirs
add-file ()
{
    for filename in *
    do
        if [ -d $filename ]
        then
            echo $filename

            cd $filename
            if [ -z time.def ]
            then
                echo "time.def exists"
            else
                touch time.def
            fi
            cd ..
        fi
    done
}
