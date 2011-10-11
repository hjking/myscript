#! /bin/csh -f
#		7Xdc - design compiler launcher
#
#	Revision History:
#	Rev.	Date		Author		Description
#	-----------------------------------------------------------------------
#	1.00	2009/04/01	Hong Jin	First Release
#	1.10	2009/04/02	Hong Jin	add log dir
#									add dc_test.tcl to de_shell-xg-t
#===================================
# LICENSE FILE
#===================================
setenv LM_LICENSE_FILE /usr/synopsys/license/license.dat

#===================================
# DC Environment
#===================================
setenv DC_VERSION DC_A-2007.12-SP5
setenv DC_HOME /usr/synopsys/$DC_VERSION

set path = ( $DC_HOME/bin $path )
set path = ( $DC_HOME/linux/bin $path )
set path = ( $DC_HOME/linux/lib $path )
set path = ( ./ $path)
#===================================
# SYN Location
#===================================
setenv SYNTH_PATH /home/asic/SYN/COMMON

#===================================
# PJ Location
#===================================

#################################################################
#source ./synth_params.csh
setenv TARGET_MODULE    AMC_PLUS
setenv TARGET_DCSCRIPT  ./dc_test.tcl
setenv TARGET_FMSCRIPT  ./fm_test.tcl

unsetenv LANG

#===============================================
# Log
#===============================================
setenv LOG_DIR						./logs
if (! -d ${LOG_DIR}) then
	mkdir -p ${LOG_DIR}
endif
set logf = ${LOG_DIR}/dc_$TARGET_MODULE:r.log
set logf_pic = ${LOG_DIR}/dc_$TARGET_MODULE:r_pic.log

date > $logf
echo "=====================================================================================" >> $logf
echo "" >> $logf

#Selects XG mode for dctcl for try, fast and reducing memories while compiling
setenv DC_SHELL 1
#cvs_syn dc_shell-xg-t $TARGET_DCSCRIPT GALILEO2_CVS dummy dummy | tee -a $logf
dc_shell-xg-t -f $TARGET_DCSCRIPT | tee -a $logf

# link info
#echo "======< link information >============================================================" >> $logf
#echo 'ls -l `find . -type l`' >> $logf
#ls -l `find . -type l` >> $logf
#echo "======================================================================================" >> $logf
#echo "" >> $logf

#grep  Latch				$logf	>  $logf_pic
#grep  loop					$logf	>> $logf_pic
#grep  wired				$logf	>> $logf_pic
#grep  multiple-driver		$logf	>> $logf_pic
#grep  Error				$logf	>> $logf_pic
#grep "Redefining macro"	$logf	>> $logf_pic


date >> $logf
echo "" >> $logf

#END
