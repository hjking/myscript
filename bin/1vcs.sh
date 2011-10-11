#!/bin/bash

################################################################################
# Filename:     1vcs.sh
# Author:       Hong Jin
# Created:      2010-06-09 16:27:55 (+0900)
# Version:      1.3
# Last Change:  2010/06/30-15:40:51 .
# Copyright:    (C) 2010, Hong Jin
# License:      This program is free software: you can redistribute it and/or modify
#               it under the terms of the GNU General Public License as published by
#               the Free Software Foundation, either version 3 of the License, or
#               (at your option) any later version.
#
#               This program is distributed in the hope that it will be useful,
#               but WITHOUT ANY WARRANTY; without even the implied warranty of
#               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#               GNU General Public License for more details.
#
#               You should have received a copy of the GNU General Public License
#               along with this program. If not, see <http://www.gnu.org/licenses/>.
# Description:  run VCS
#
## USAGE
# 1. Run testcase one by one, generate separated log files
#       % ./1vcs.sh
# 2. Run all testcases in batch mode
#    + Generate a default log ${LOG_FILE}
#       % ./1vcs.sh -b or ./1vcs.sh --batch or ./1vcs.sh batch
# 3. Run all testcases in batch mode
#    + Generate a default log ${LOG_FILE}
#    + And generate coverage report
#       % ./1vcs.sh -c or ./1vcs.sh --cov or ./1vcs.sh cov
# 4. Display help of this script
#       % ./1vcs.sh -h or ./1vcs.sh --help
# 5. Run testcase one by one, generate separated log files
#       % ./1vcs.sh -s or ./1vcs.sh --single or ./1vcs.sh single
# 6. Archive and Compress current project
#       % ./1vcs.sh -t or ./1vcs.sh --tgz
# 7. Run all testcases in batch mode, generate URG coverage report
#       % ./1vcs.sh -u or ./1vcs.sh --urg or 1vcsh.sh urg
# 8. Developping....
#
## Change Log:
#     2010-06-09:
#       NEW: Created. First version.
#     2010-06-11:
#       NEW: Add generating coverage.
#     2010-06-22:
#       NEW: Add archive and compress function
#       NEW: Add color print
#     2010-06-23:
#       FIX: Modify cleanup function
#       NEW: Add generating URG coverage report
#     2010-06-28:
#       FIX: Update GPL License
################################################################################


################################################################################
## Variables Defination
################################################################################

SCRIPT_NAME=$(basename $0)
DIR_NAME=$(basename `pwd`)

#============================================
## LICENSE FILE
#============================================
if [ "$HOSTNAME" == "ratchet" ]
then
    export LM_LICENSE_FILE=27000@ratchet
    export VCS_VERSION=B-2008.12
    #export VCS_HOME=/home/synopsys/$VCS_VERSION
    export VCS_HOME=/EDA_Tools/vcs/$VCS_VERSION
    export VERDI_HOME=/EDA_Tools/Verdi
elif [ "$HOSTNAME" == "megatron" ] || [ "$HOSTNAME" == "asic-server" ]
then
    export LM_LICENSE_FILE=/usr/synopsys/license/license.dat
    export VCS_VERSION=vcs08
    export VCS_HOME=/home/synopsys/$VCS_VERSION
    export VERDI_HOME=/home/asic/Verdi
else
    export LM_LICENSE_FILE=27000@fusion1
    export VCS_VERSION=D-2010.06
    export VCS_HOME=/cadtools/vcs/$VCS_VERSION
    export VERDI_HOME=/cadtools/novas/Novas-201010
fi
#============================================
## Tools Environment
#============================================
# VCS_HOME=/usr/synopsys/$VCS_VERSION
# export VCS_HOME=/home/synopsys/$VCS_VERSION
# VCS_HOME=/cadtools/vcs/D-2010.06
export VCS_BIN=${VCS_HOME}/bin
PLATFORM=LINUX
# VERDI_HOME=/cadtools/novas/Novas-201010
# VERDI_HOME=/home/asic/Verdi
# LD_LIBRARY_PATH=${VERDI_HOME}/share/PLI/VCS/${PLATFORM}
LD_LIBRARY_PATH=${VERDI_HOME}/share/PLI/vcsd_latest/${PLATFORM}
# VERDI_LIB=${VERDI_HOME}/share/PLI/vcsd_latest/${PLATFORM}
# VERDI_PLI_VCSD=${VERDI_LIB}/vcsd.tab
# VERDI_PLI=${VERDI_LIB}/pli.a
VERDI_PLI_VCSD=${LD_LIBRARY_PATH}/vcsd.tab
VERDI_PLI=${LD_LIBRARY_PATH}/pli.a
# For SVA
#VERDI_PLI_VCSD = ${VERDI_HOME}/share/PLI/vcsd72/${PLATFORM}/vcsd.tab
#VERDI_PLI = ${VERDI_HOME}/share/PLI/vcsd72/${PLATFORM}/pli.a
PATH=${VCS_BIN}:$PATH

#============================================
## User Simulation Environment Defination
#  + You can change the following variables
#  + as your need
#============================================
PJ_NAME=GSCU                              # project name
RTL_DIR=simlink_sapphire                  # RTL dir
EXCLUDE_DIR=.svn                          # exclude dir(s) when archive
USER_LOG_DIR=log                          # log dir
USER_VCS_DIR=vcs.sim                      # vcs cache dir
USER_OBJECT_DIR=${USER_VCS_DIR}/object
SIMV_FILE=${USER_VCS_DIR}/simv            # specify the executable file
USER_WAVE_DIR=wave                        # wave dir
FSDB_FILE=gscu.fsdb                       # wave dir
LOG_FILE=vcs_sim.log                      # log file
SIM_TREE_FILE=./sim.tree                  # tree file including design and tb
SIM_LIST=./sim.list                       # list including testcases to be ran
TESTCASE_LIST=tc.list                     # list including all testcases
# For coverage
COV_CM_DIR=simv.cm                        # Code coverage data dir
COV_TRIG="OFF"                            # coverage trigger
COV_DEF=""                                # coverage options
COV_METRICS_OPT="line+branch+cond+fsm+tgl" # coverage metrics
COV_TREE_FILE=cov.conf                    # file including design
# URG coverage
URG_COV_DIR=simv.vdb                      # Group and Asseration coverage data dir
URG_RPT_DIR=urgReport                     # Report dir
URG_RPT_FMT="text"                        # Report format
URG_METRICS_OPT="line+branch+cond+fsm+tgl+assert+group" # coverage metrics
# Macros for compilation
MACRO_DEF=""                              # macro for simulation
# Library for compilation
LIB_DIR=""                                # library directory
LIB_NAME=""                               # specify a library name
LIB_DEF=""                                # resource library defination
# verdi cache
VERDI_CACHE_DIR=verdiLog
# Color Defination
fg_RED='\e[1;31m'
fg_GREEN='\e[1;32m'
fg_CYAN='\e[1;36m'
NC='\e[0m'

###########################################################################
# Function Defination
###########################################################################
#============================================
## Function for trigger running vcs
#  + with generating coverage report
#  + put the design modules in the cov.conf
#  + default logs in ${COV_CM_DIR}
#    -cm line+branch+fsm+cond+tgl+path \
#    -cm_name vcov \
#    -cm_cond std \
#    -cm_tgl mda \
#  Set the COV_TRIG as the argument
#============================================
COV_SETTING () {
  if [ -z $1 ]
  then
    COV_DEF=
  elif [ $1 == "ON" ]
  then
    COV_DEF="-cm ${COV_METRICS_OPT}
    -cm_dir ${COV_CM_DIR}"
#    -cm_hier ${COV_TREE_FILE}"
  else
    COV_DEF=""
  fi

  return
}

#============================================
## Write coverage reports
#  + after run 'simv'
#============================================
COV_CMVIEW () {
  vcs -cm_pp \
      -cm ${COV_METRICS_OPT} \
      -cm_log ${COV_CM_DIR}/cmView.log

  return
}

#============================================
## URG coverage reports
#  + Default coverage dir is "urgReport"
#  +  change ${URG_RPT_DIR} as you need
#  + Coverage type: line+cond+fsm+tgl+assert+group
#  +  change ${URG_METRICS_OPT} as you need
#  + Database dir(-dir db_dir)
#  +  or use -f db_list to specify DB dirs
#============================================
URG_COV () {
  urg -dir ${COV_CM_DIR}
#  urg -dir ${COV_CM_DIR} \
#      -format ${URG_RPT_FMT} \
#      -metric ${URG_METRICS_OPT} \
#      -report ${URG_RPT_DIR}

  return
}

#============================================
## Function for defining macro
#  Set the macros you gonna define as the arguments
#============================================
MACRO_SETTING () {
  while [[ -n $1 ]]; do
    MACRO_DEF=`echo ${MACRO_DEF}+$1`
    shift
  done

  return
}

#============================================
## Function for setting library
#  Set the library name for the argument
#============================================
LIB_SETTING () {
  if [ -z $1 ]
  then
    LIB_DEF=""
  else
    case $1 in
      "IBM_LIB")
        LIB_DEF=\
        "-y ./liblink/STANDARD_LIB/ibm_cu08/v7.0fix/verilog \
        -y ./liblink/STANDARD_LIB/ibm_cu08/v7.0/verilog \
        -y ./liblink/CUSTOM_LIB/verilog \
        -y ./liblink/CUSTOM_LIB/verilog_wrapper"
        ;;
      *)
        LIB_DEF=
        ;;
    esac
  fi

  return
}

#============================================
## Function for creating dir
#============================================
CREATE_DIR () {
  if [[ -n $1 ]]
  then
    if [[ ! -d $1 ]]
    then
      echo "------------------------------------"
      echo "          Creating $1 ..."
      echo "------------------------------------"
      mkdir -p $1
    else
      echo "    Dir $1 already existed!"
    fi
  fi

  return
}

#============================================
## Function for printing script usage
#============================================
SCRIPT_USAGE () {
cat <<- _USAGE_
    ---------------------------------------------------------------
                    Usage of ${SCRIPT_NAME}
    ---------------------------------------------------------------

      1. Run testcase one by one, generate separated log files
            % ./1vcs
      2. Run all testcases in batch mode
         Generate a default log ${LOG_FILE}
            % ./1vcs -b or ./1vcs --batch or ./1vcs batch
      3. Run all testcases in batch mode
         Generate a default log ${LOG_FILE}
         And generate coverage report in ${COV_CM_DIR}
            % ./1vcs -c or ./1vcs --cov or ./1vcs cov
      4. Display help of this script
            % ./1vcs -h or ./1vcs --help
      5. Run testcase one by one, generate separated log files
            % ./1vcs -s or ./1vcs --single or ./1vcs single
      6. Archive and Compress current project
            % ./1vcs -t or ./1vcs --tgz
      7. Run all testcases in batch mode
         Generate URG coverage report in ${URG_RPT_DIR}
            % ./1vcs -u or ./1vcs --urg or 1vcsh urg
      8. Developping...

    ---------------------------------------------------------------
_USAGE_

return
}

#============================================
## Function for running VCS
#  VCS Simulation options:
#    -R: exexute simulation after compile
#    -l: put output to log file
#    +incdir: files directories
#    +libext: search files with these extension in Lib
#    -y: Lib link folder
#    -f: tree file
#============================================
RUN_VCS () {
  vcs \
    +vcs+lic+wait                       \
    -R -PP -Mupdate                     \
    +libverbose                         \
    +define+${MACRO_DEF}                \
    -P ${VERDI_PLI_VCSD}                \
    ${VERDI_PLI}                        \
    +lint=PCWM                          \
    -l ${USER_LOG_DIR}/${LOG_FILE}      \
    -Mdir=${USER_OBJECT_DIR}            \
    -o ${SIMV_FILE}                     \
    +v2k                                \
    -sverilog                           \
    +memcbk                             \
    +vcsd                               \
    +vpi                                \
    +error+100                          \
    -notice                             \
    +notimingcheck                      \
    ${COV_DEF}                          \
    ${LIB_DEF}                          \
    -timescale=1ps/1ps                  \
    +incdir+.                           \
    +libext+.v+.vcs+.vp+.sv             \
    -f ${SIM_TREE_FILE}

  return
}

#============================================
## Run all the testcase together
#  + generate one default log
#============================================
RUN_TOGETHER () {
  # remove those comment lines and empty lines
  grep -v '\/\/' ${TESTCASE_LIST} | sed '/^\s*$/d' > ${SIM_LIST}
  # remove those comment lines, empty lines and repeated lines
  # grep -v '\/\/' ${TESTCASE_LIST} | sed '/^\s*$/d' | sort | uniq > ${SIM_LIST}
  # backup previous default log file
  if [ -e ${USER_LOG_DIR}/${LOG_FILE} ]
  then
    cp ${USER_LOG_DIR}/${LOG_FILE} ${USER_LOG_DIR}/${LOG_FILE}_bak
  fi
  # set library
  LIB_SETTING ${LIB_NAME}
  # macro setting
  MACRO_SETTING
  # Call VCS running
  RUN_VCS

  return
}

#============================================
## Run each testcase at one time
#  + generate independent logs
#============================================
RUN_ONE_BY_ONE () {
  # Separate each testcase from the testcase list file
  # + run each testacse independently
  # + generate log file for each testcase
  # Remove those comment lines, empty lines and repeated lines
  # for i in `grep -v '\/\/' ${TESTCASE_LIST} | sed '/^\s*$/d' | sort | uniq | cut -d ';' -f 1`
  for i in `grep -v '\/\/' ${TESTCASE_LIST} | sed '/^\s*$/d' | cut -d ';' -f 1`
  do
    echo ${i}';' > ${SIM_LIST}
    # set library
    LIB_SETTING ${LIB_NAME}
    # macro setting
    MACRO_SETTING
    # set coverage
    COV_SETTING ${COV_TRIG}
    # set log file
    LOG_FILE=${i}.log
    # cleanup
    LITE_CLEANUP
    # run vcs
    RUN_VCS
    #mv ${USER_WAVE_DIR}/${FSDB_FILE} ${USER_WAVE_DIR}/${i}.fsdb
    mv ${FSDB_FILE} ${USER_WAVE_DIR}/${i}.fsdb
  done

  return
}

#============================================
## Do some preparation before run VCS
#============================================
PREPARATION () {
## Change file format to Unix format
  if [[ -e ${TESTCASE_LIST} ]]
  then
    dos2unix ${TESTCASE_LIST}
  fi
  
  if [[ -e ${SIM_LIST} ]]
  then
    dos2unix ${SIM_LIST}
  fi
    
## Check those dirs exist or not
  CREATE_DIR ${USER_LOG_DIR}
  CREATE_DIR ${USER_VCS_DIR}
  CREATE_DIR ${USER_OBJECT_DIR}
  CREATE_DIR ${USER_WAVE_DIR}

  return
}

#============================================
## Do some cleaning job after run VCS
#============================================
LITE_CLEANUP () {
  rm -rf ${USER_VCS_DIR}/*

  return
}

DEEP_CLEANUP () {
  rm -f ${USER_LOG_DIR}/*
  rm -f ${USER_WAVE_DIR}/*
  rm -rf ${USER_VCS_DIR}
  rm -rf ${COV_CM_DIR}

  return
}

#============================================
## Analyze simulation logs after run VCS
#============================================
ANALYZE_LOGS () {

  return
}

#============================================
## Archive and Compress current project
#============================================
TAR_GZ () {
  DEEP_CLEANUP
  cd ..
  tar czvf ${PJ_NAME}.tgz ${DIR_NAME}
      --exclude=${DIR_NAME}/${EXCLUDE_DIR} \
      --exclude=${DIR_NAME}/*/${EXCLUDE_DIR} \
      ${DIR_NAME}
      # --exclude=${DIR_NAME}/${RTL_DIR} \
      # --exclude=${DIR_NAME}/${VERDI_CACHE_DIR} \
      # --exclude=${DIR_NAME}/${USER_WAVE_DIR} \
      # --exclude=${DIR_NAME}/$0 \

  return
}

###########################################################################
## Let's Rock and Roll
###########################################################################

## Check arguments
# If no argument, then run testcases one by one
if [ $# -lt 1 ]
then
  echo -e "${fg_CYAN}>>>>> Run VCS ...${NC}"
#  LITE_CLEANUP
  PREPARATION
  RUN_VCS
#  RUN_ONE_BY_ONE
# If have 1 argument, check argument
elif [ $# == 1 ]; then
  case $1 in
    -b | --batch | batch)  # batch mode
        echo -e "${fg_CYAN}>>>>> Run Testcase in Batch Mode ...${NC}"
        LITE_CLEANUP
        PREPARATION
        RUN_TOGETHER
        ;;
    -c | --cov | cov) # generate coverage report
        echo -e "${fg_CYAN}>>>>> Run Testcase in Batch Mode with generating coverage report ...${NC}"
        LITE_CLEANUP
        PREPARATION
        COV_TRIG="ON"
        COV_SETTING ${COV_TRIG}
        RUN_TOGETHER
        COV_CMVIEW
        ;;
    -h | --help)  # help
        SCRIPT_USAGE
        exit
        ;;
    -s | --single | single)  # batch mode
        echo -e "${fg_CYAN}>>>>> Run Testcase one by one ...${NC}"
        PREPARATION
        RUN_ONE_BY_ONE
        ;;
    -t | --tgz) # archive project
        echo -e "${fg_CYAN}>>>>> Archive and Compress current project ...${NC}"
        TAR_GZ
        exit
        ;;
    -u | --urg | urg) # generate URG coverage report
        echo -e "${fg_CYAN}>>>>> Run Testcase in Batch Mode with generating URG coverage report ...${NC}"
        LITE_CLEANUP
        PREPARATION
        COV_TRIG="ON"
        COV_SETTING ${COV_TRIG}
        RUN_TOGETHER
        URG_COV
        ;;
    [[:digit:]][[:digit:]][[:digit:]][[:digit:]])
        echo -e "${fg_CYAN}>>>>> Run Testcase $1 ...${NC}"
        PREPARATION
        MACRO_SETTING CASE_ID=$1
        RUN_VCS
        ;;
    *)  # other value
        echo -e "${fg_RED}Please follow the usage of this script!${NC}"
        SCRIPT_USAGE
        exit 1
        ;;
  esac
#elif [ $# == 2 ]
#then
else
  echo -e "${fg_RED}Please follow the usage of this script!${NC}"
  SCRIPT_USAGE
fi

#CREATE_DIR  log/$1
# mkdir -p log/$1
#echo "Moving logs to log/$1 ... "
#mv log/*.log log/$1/
mv ${USER_LOG_DIR}/${LOG_FILE} ${USER_LOG_DIR}/$1.log

exit

#=============================================================
# END of SCRIPT
# /bin/bash
#=============================================================
