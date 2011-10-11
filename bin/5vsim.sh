#!/bin/bash

###########################################################################
# Filename:    3vsim.sh
# Author:      Hong Jin
# Created:     2010-06-10 16:27:55 (+0900)
# Version:     1.2
# Last Change: 2010/07/13-13:47:07 .
# Copyright:   (C) 2010, Hong Jin, all rights reserved.
# License:     This program is free software. It comes without any warranty,
#              to the extent permitted by applicable law. You can 
#              redistribute it and/or modify it under the terms of the 
#              GNU General Public License, either version 2, or later version
# Description: run ModelSim
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
###########################################################################

###########################################################################
## Variables Defination
###########################################################################

# ============================================ #
#  Lincence Setup
# ============================================ #
LM_LICENSE_FILE=/license/license.dat

# ============================================ #
#  Environment Setup
# ============================================ #
# ModelSim installed dir
MODELSIM_HOME=/home/asic/modelsim_se65/modeltech
PLATFORM=LINUX
# NOVAS PLI
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
TOP_MODULE=tb_test		        # top-level module
EXCLUDE_DIR=.svn                # exclude dir when archive
SIM_TREE=PLB2LMC_sim.tree      # sim tree including design and TB
LOG_FILE=./log/msim.log         # log file
WORK_LIB=work                   # logical library
OPT_TOP_MODULE=PLB2LMC_tb_opt  # optimized top-top module
DO_FILE=sim.do                  # DO file
MACRO_DEF=""                    # Macro defination
LIB_DEF=""                      # Resource Library defination
LIB_EXT=.v+.sv+.vp              # File extensions in the Source Library
WAVE_DIR=wave                   # VCD/FSDB dir

# ============================================ #
#  Checking Server
# ============================================ #

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

# mkdir log
# mkdir wave

#### set local library
if [ -e work ]
then
  vdel -all
fi
vlib work


#### Compile
# no optimization
vlog -novopt -incr ${NOVAS_VLOG} -f ${SIM_TREE}


#### Compile with optimization
# vlog -incr ${MACRO_DEF} ${LIB_DEF} ${NOVAS_VLOG} -f ${SIM_TREE}
#### optimize design
# vopt +acc ${TOP_MODULE} -o ${OPT_TOP_MODULE}

#### Load design
# no optimization
vsim -c -do "run -all;quit" \
       -l ${LOG_FILE} -novopt -pli ${NOVAS_PLI} ${TOP_MODULE}

#### Load design and optimize
# vsim -c -do "run -all;quit" \
#       -l ${LOG_FILE} -pli ${NOVAS_PLI} ${OPT_TOP_MODULE}

# debug run
# vsim -c -l ${LOG_FILE} -pli ${NOVAS_PLI} ${TOP_MODULE}


exit

#=============================================================
# END of SCRIPT
# /bin/bash
#=============================================================
