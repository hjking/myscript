#!/bin/csh -f

## display some information of a file
##
foreach i ($*)
    if ( -d $i ) then
        echo "=== Please input an file name ==="
    else if ( -e $i ) then
        echo "=================== FileName: $i ========================"
        set file_type = `file ${i}`
        echo "=== File Type: $file_type[2-] ==="
        set line_num = `wc -l ${i}`
        echo "=== $line_num[1] lines in this file ==="
        ls -lhF --time-style="long-iso" $i
        echo "======================================================================"
        echo ""
    else
        echo "=== Please input an existed file ==="
    endif
end
