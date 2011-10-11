#! /bin/bash
#####################################################
# Auther:   Hong Jin(hong_jin@founder.com)
# Version:  1.0
# Date:     2011-03-11 15:17
#
# Delete dump files
#
#####################################################

for filename in *
do
    if [ -d $filename ]
    then
        echo $filename
        cd $filename
        for file in *
        do
            fname=`basename $file`
            # delete log file and FSDB
            if [ "$fname" == "vcs_sim.log" ] || [ "$fname" == "ddr3mc.fsdb" ] || [ "$fname" == "vcs.key" ] || [ "$fname" == ".vcsmx_rebuild" ]
            then
                echo "  ==> remove $fname"
                rm -rf $fname
            fi
            # delete VERDI file
            if [ "$fname" == "verdiLog" ] || [ "$fname" == "novas.rc" ]
            then
                echo "  ==> remove $fname"
                rm -rf $fname
            fi
            # unlink
            if [ "$fname" == "module" ] || [ "$fname" == "simlink" ]
            then
                echo "  ==> unlink $fname"
                unlink $fname
            fi
        done
        cd ..
    fi
done

