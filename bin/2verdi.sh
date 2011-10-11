#!/bin/bash
#####################################################
#
#####################################################

# setenv LM_LICENSE_FILE 5219@fusion1
if [ "$HOSTNAME" == "ratchet" ] || [ "$HOSTNAME" == "megatron" ]
then
    export VERDI_HOME=/EDA_Tools/Verdi/platform/LINUX/bin
elif [ "$HOSTNAME" == "asic-server" ]
then
    export VERDI_HOME=/home/asic/Verdi/platform/LINUX/bin
else
    export VERDI_HOME=/cadtools/novas/Novas-201010/platform/LINUX/bin
fi

#===================================
# 
#===================================
PATH=${VERDI_HOME}:$PATH:.

#Modify sim.tree and fsdb_file.fsdb
verdi                                   \
    -2001                               \
    -autoalias                          \
    +notimingcheck                      \
    -f ./sim.tree                       \
    -ssf ./gscu.fsdb &

#=============================================================
# END
#=============================================================
