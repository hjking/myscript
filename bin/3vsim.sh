#!/bin/bash

################################################################################
# Filename:     3vsim.sh
# Author:       Hong Jin
# Created:      2010-06-10 16:27:55 (+0900)
# Version:      1.3
# Last Change:  2010/06/29-09:39:02 .
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
#
# Description:  run ModelSim
#
## USAGE
#     1. Run testcase one by one, generate separated log files
#          % ./3vsim
#     2. Run ModelSim with generating coverage
#        Generate a default log ${LOG_FILE}
#          % ./3vsim -c
#     3. Enter Debug Mode in CLI
#          % ./3vsim -d
#     4. Run ModelSim in GUI Mode
#        Generate a default log ${LOG_FILE}
#          % ./3vsim -g
#     5. Display help of this script
#          % ./3vsim -h
#     6. Run ModelSim with optimizing design
#          % ./3vsim -o
#     7. Archive and Compress current project
#          % ./3vsim -t
#     8. Developping...
#
## Change Log:
#     2010-06-10:
#       NEW: Created. First version.
#     2010-06-23:
#       NEW: Change structure, use function
#       NEW: Add Optimization;
#       NEW: Add Generating Coverage
#     2010-06-25:
#       NEW: Add Debug Mode
#     2010-06-28:
#       FIX: Update GPL License
################################################################################

################################################################################
## Variables Defination
################################################################################

SCRIPT_NAME=$(basename $0)
DIR_NAME=$(basename `pwd`)

# ============================================ #
#  Lincence Setup
# ============================================ #
#LM_LICENSE_FILE=1718@fusion1      # 1717@earth
LM_LICENSE_FILE=/license/license.dat

# ============================================ #
#  Environment Setup
# ============================================ #
# ModelSim installed dir
MODELSIM_HOME=/home/asic/modelsim_se65/modeltech
PLATFORM=LINUX
#MODELSIM_HOME=/cadtools/modelsim6.4/modeltech/
#PLATFORM=LINUX64
# NOVAS PLI
#NOVAS_HOME=/cadtools/novas/Novas-201001
NOVAS_HOME=/home/asic/Verdi
NOVAS_VLOG=${NOVAS_HOME}/share/PLI/modelsim_pli_latest/${PLATFORM}/novas_vlog.v
NOVAS_PLI=${NOVAS_HOME}/share/PLI/modelsim_pli_latest/${PLATFORM}/libpli.so
PATH=$MODELSIM_HOME/linux:$PATH

# ============================================ #
# User Simulation Environment Defination
#  + You can change the following variables
#  + as your need
# ============================================ #
PJ_NAME=P2L                     # project name
RTL_DIR=simlink_ti              # RTL dir
EXCLUDE_DIR=.svn                # exclude dir when archive
SIM_TREE=PLB2LMC_sim.tree       # sim tree including design and TB
LOG_FILE=./log/msim.log         # log file
WORK_LIB=work                   # logical library
TOP_MODULE=tb_test              # top-level module
OPT_TOP_MODULE=tb_test_opt      # optimized top-top module
VCD_FILE=${PJ_NAME}.vcd         # VCD file
DO_FILE=sim.do                  # DO file
MACRO_DEF=""                    # Macro defination
LIB_DEF=""                      # Resource Library defination
LIB_EXT=.v+.sv+.vp              # File extensions in the Source Library
VERDI_CACHE_DIR=verdiLog        # Novas dir
WAVE_DIR=wave                   # VCD/FSDB dir
UCDB_FILE=coverage.ucdb         # UCDB file
COV_RPT_DIR=covhtmlreport       # default

# ============================================ #
#  Checking Server
# ============================================ #
if [[ "fusion1" == `hostname` ]]
then
  echo "Do NOT use this server. It's not for simulation."
  exit
fi

# do NOT use high load server
if [[ `cat /proc/loadavg | /usr/bin/perl -lane 'print @F[0]'` > '2' ]]
then
cat <<- _WARNING_MSG_
            !! Warning !! 
       Do NOT use this server!
  This Server High Load: `cat /proc/loadavg`
_WARNING_MSG_

  exit
fi

# ============================================ #
#  Function Defination
# ============================================ #

#### Function for printing script usage
SCRIPT_USAGE () {
cat <<- _USAGE_
    ---------------------------------------------------------------
                      Usage of ${SCRIPT_NAME}
    ---------------------------------------------------------------

      1. Run testcase one by one, generate separated log files
           % ./3vsim
      2. Run ModelSim with generating coverage
         Generate a default log ${LOG_FILE}
           % ./3vsim -c
      3. Enter Debug Mode in CLI
           % ./3vsim -d
      4. Run ModelSim in GUI Mode
         Generate a default log ${LOG_FILE}
           % ./3vsim -g
      5. Display help of this script
           % ./3vsim -h
      6. Run ModelSim with optimizing design
           % ./3vsim -o
      7. Archive and Compress current project
           % ./3vsim -t
      8. Developping...

    ---------------------------------------------------------------
_USAGE_

  return
}

#### define macro
# set macros as the arguments
# eg: MACRO_SETTING one=r1 two=r2
#   ==> +define+one=r1+two=r2
MACRO_SETTING () {
  while [[ -n $1 ]]; do
    MACRO_DEF=`echo ${MACRO_DEF}+$1`
    shift
  done

  if [[ ${MACRO_DEF} == "" ]]
  then
      MACRO_DEF=""
  else
    MACRO_DEF=`echo +define+${MACRO_DEF}`
  fi

  return
}

#### Resource Library Setting
# set lib dirs as the arguments
LIB_SETTING () {
  while [[ -n $1 ]]; do
      temp_lib=`echo -y\ $1`
      LIB_DEF=`echo ${LIB_DEF}\ ${temp_lib}`
      shift
  done

  if [[ ${LIB_DEF} == "" ]]
  then
      LIB_DEF=""
  else
      LIB_DEF=`echo ${LIB_DEF}\ +libext+${LIB_EXT}`
  fi

  return
}

#### set local library
CREATE_WORK_LIB () {
  if [ -e ${WORK_LIB} ]
  then
    vdel -all
  fi
  vlib ${WORK_LIB}

  return
}

#### Compile
# no optimization
NORMAL_COMPILE () {
  vlog -novopt -incr ${MACRO_DEF} ${LIB_DEF} ${NOVAS_VLOG} -f ${SIM_TREE}

  return
}

#### Compile with optimization
COMPILE_WITH_OPTIMIZE () {
  vlog -incr ${MACRO_DEF} ${LIB_DEF} ${NOVAS_VLOG} -f ${SIM_TREE}

  return
}

#### optimize design
OPTIMIZE () {
  vopt +acc ${TOP_MODULE} -o ${OPT_TOP_MODULE}

  return
}

#### Coverage setting
# b:Branch; c:Condition; 
# s:Statement; x:Toggle;
# e:Expression; f:FSM
OPTIMIZE_WITH_COVERAGE () {
  vopt +cover=bcesxf +acc ${TOP_MODULE} -o ${OPT_TOP_MODULE}

  return
}

#### Load design
# no optimization
NORMAL_RUN () {
  vsim -c -do "run -all;quit" \
       -l ${LOG_FILE} -novopt -pli ${NOVAS_PLI} ${TOP_MODULE}

  return
}

#### Load design and optimize
RUN_WITH_OPTIMIZE () {
  vsim -c -do "run -all;quit" \
       -l ${LOG_FILE} -pli ${NOVAS_PLI} ${OPT_TOP_MODULE}

  return
}

#### Load design with coverage
RUN_WITH_COVERAGE () {
  rm ${UCDB_FILE} # remove old one
  
  vsim -c -coverage -do "run -all;\
                         coverage save ${UCDB_FILE};\
                         quit" \
       -l ${LOG_FILE} \
       -pli ${NOVAS_PLI} ${OPT_TOP_MODULE}
# Generaete coverage in simulation
#  vsim -c -coverage -do "run -all;\
#                         coverage report -html;\
#                         coverage save cov.ucdb;quit" \
#       -l ${LOG_FILE} \
#       -pli ${NOVAS_PLI} ${OPT_TOP_MODULE}

# or use -voptargs when not using vopt step
#  vsim -c -coverage -do "run -all;quit" \
#       -voptargs="+cover=bcesfx" \
#       -l ${LOG_FILE} \
#       -pli ${NOVAS_PLI} ${TOP_MODULE}

  return
}

DEBUG_RUN () {
  vsim -c -l ${LOG_FILE} -pli ${NOVAS_PLI} ${TOP_MODULE}
}

#### Generate coverage report after simulation
# In simulation, generate a UCDB file
# Here use that UCDB file to generate coverage
# + report offline in "covhtmlreport" dir
VCOVER_REPORT () {
  rm -rf ${COV_RPT_DIR}   # remove old one
  vcover report -html ${UCDB_FILE}
}

#### Run GUI
GUI_SIM () {
  vsim -do ${DO_FILE} -pli ${NOVAS_PLI} ${OPT_TOP_MODULE}

  return
}

#### Generate vcd file
# ToDo: To be fixed
GEN_VCD () {
    vcd file ${WAVE_DIR}/${VCD_FILE}
    vcd add -r -file ${WAVE_DIR}/${VCD_FILE} /${TOP_MODULE}/*
}

#### if no Novas PLI, convert VCD file to FSDB
VCD2FSDB () {
  vcd2fsdb ${VCD_FILE}

  return
}

# Clean up
CLEANUP () {
  rm -rf ${WORK_LIB}

  return
}

#### Archive and compress
# exclude unnecessary dirs and files
TAR_GZ () {
  CLEANUP
  cd ..
  tar czvf ${PJ_NAME}.tgz \
      --exclude=${DIR_NAME}/${EXCLUDE_DIR} \
      --exclude=${DIR_NAME}/*/${EXCLUDE_DIR} \
      --exclude=${DIR_NAME}/${RTL_DIR} \
      --exclude=${DIR_NAME}/${VERDI_CACHE_DIR} \
      --exclude=${DIR_NAME}/${WAVE_DIR} \
      --exclude=${DIR_NAME}/*.cr.mti \
      --exclude=${DIR_NAME}/*.mpf \
      --exclude=${DIR_NAME}/*.wlf \
      --exclude=${DIR_NAME}/$0 \
      ${DIR_NAME}

  return
}

########## Let's Rock and Roll #################
# ============================================ #
#  Start  ModelSim
# ============================================ #

# set macro
MACRO_SETTING
# set library
LIB_SETTING

if [ $# -lt 1 ]
then
  echo " Run ModelSim in CLI Mode ..."
  CREATE_WORK_LIB
  NORMAL_COMPILE
  NORMAL_RUN
elif [ $# == 1 ]
then
  case $1 in
    -c) # generate coverage
        CREATE_WORK_LIB
        COMPILE_WITH_OPTIMIZE
        OPTIMIZE_WITH_COVERAGE
        RUN_WITH_COVERAGE
        VCOVER_REPORT
        ;;
    -d) # generate coverage
        CREATE_WORK_LIB
        COMPILE_WITH_OPTIMIZE
        DEBUG_RUN # optimized
        ;;
    -g) # GUI
        echo " Run ModelSim in GUI Mode ..."
        CREATE_WORK_LIB
        COMPILE_WITH_OPTIMIZE
        OPTIMIZE
        GUI_SIM
        ;;
    -h) # display help
        SCRIPT_USAGE
        exit
        ;;
    -o) # optimize design
        CREATE_WORK_LIB
        COMPILE_WITH_OPTIMIZE
        OPTIMIZE
        RUN_WITH_OPTIMIZE
        ;;
    -t) # archive and compress
        TAR_GZ
        exit
        ;;
    *)
        echo "Please follow the usage of this script!"
        SCRIPT_USAGE
        exit 1
        ;;
  esac
#elif [ $# == 2 ]
#then
else
  echo "Please follow the usage of this script!"
  SCRIPT_USAGE
fi

exit

#=============================================================
# END of SCRIPT
# /bin/bash
#=============================================================
