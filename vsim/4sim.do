############################################################
# Author:       Hong Jin (hong_jin@founder.com)
# Version:      1.0
# Last Change:  2010/07/08-19:51:37 .
# Project:      PLB5_LMC
#
#================ USAGE ================
# Load this file in ModelSim prompt
#    > do 4sim.do
#
############################################################

# Set log file
transcript file ""
transcript file sim.log
echo "Time: $now"

if [file exists work] {
  vdel -all
}

# Step 1: Library
# set local library
vlib work
# map vendor library
#vmap work <verdor_lib>

# Step 2: Compile design
vlog -novopt -incr -f PLB2LMC_sim.tree

# Step 3: Optimize
#vopt

# Step 4: Load design
vsim tb_test

# Step 5: Add wave
# DUT IO
add wave -divider "DUT"
#add wave -group DUT -color "light blue"  -hex sim:/tb_test/PLB5_2LMC/I_CLK_PLBCLK
#add wave -group DUT -color "light blue"  -hex sim:/tb_test/PLB5_2LMC/I_RST_PLBRST
# PLB IF
add wave -group DUT -group PLB_Slv -color "orange" -hex sim:/tb_test/PLB5_2LMC/*PLB*
# LMC IF
add wave -group DUT -group LMC_Mst -color "maroon" -hex sim:/tb_test/PLB5_2LMC/*LMC*
# DCR IF
add wave -group DUT -group DCR_IF -color "brown" -hex sim:/tb_test/PLB5_2LMC/I_OTHER_BASEADDR
add wave -group DUT -group DCR_IF -color "orchid" -hex sim:/tb_test/PLB5_2LMC/*DCR*
# Simulation model
add wave -divider "Simulation Model"
add wave -group PLB_Mst -color "light green"  -hex sim:/tb_test/plb_master/*
add wave -group LMC_Slv -color "purple"  -hex sim:/tb_test/lmc_slave/*
add wave -group DCR_Mst -color "red"  -hex sim:/tb_test/dcr_master/*
add wave -group clk_rst -color "light blue"  -hex sim:/tb_test/clk_rst/*

# Step 6: Run simulation
run -all

# Step 7: Debug
