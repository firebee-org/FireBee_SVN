## Generated SDC file "firebee.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Fri Aug  8 11:08:03 2014"

##
## DEVICE  "EP3C40F484C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLK_MAIN} -period 30.303 -waveform { 0.000 15.151 } [get_ports {CLK_MAIN}]
create_clock -name {CLK_33M} -period 30.303 -waveform { 0.000 15.151 } [get_ports {CLK_33M}]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks -create_base_clocks

#**************************************************************
# Set Clock Latency
#**************************************************************
derive_clock_uncertainty

#**************************************************************
# Set Clock Uncertainty
#**************************************************************

#**************************************************************
# Set Input Delay
#**************************************************************

#**************************************************************
# Set Output Delay
#**************************************************************

#**************************************************************
# Set Clock Groups
#**************************************************************

#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_clocks {I_PLL4|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {I_PLL3|altpll_component|auto_generated|pll1|clk[2]}]
set_false_path -from [get_clocks {CLK_33M}] -to [get_clocks {I_PLL3|altpll_component|auto_generated|pll1|clk[2]}]
set_false_path -from [get_clocks {CLK_33M}] -to [get_clocks {I_PLL4|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path -from [get_clocks {I_PLL4|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {CLK_33M}]
set_false_path -from [get_clocks {I_PLL4|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {CLK_MAIN}]

# decouple video clock from rest of design
set_false_path -from [get_clocks] -to [get_clocks {I_PLL4|altpll_component|auto_generated|pll1|*}]
set_false_path -from [get_clocks {I_PLL4|altpll_component|auto_generated|pll1|*}] -to [get_clocks]

# decouple ST clocks from rest of design
set_false_path -from [get_clocks] -to [get_clocks {I_PLL3|altpll_component|auto_generated|pll1|*}]
set_false_path -from [get_clocks {I_PLL3|altpll_component|auto_generated|pll1|*}] -to [get_clocks]

# decouple CLK_MAIN and CLK_33M from DDR clocks
set_false_path -from [get_clocks {CLK_*}] -to [get_clocks {I_PLL3|altpll_component|auto_generated|pll1|clk[2]}]
set_false_path -from [get_clocks {I_PLL3|altpll_component|auto_generated|pll1|clk[2]}] -to [get_clocks {CLK_*}]
set_false_path -from [get_clocks {I_PLL2|altpll_component|auto_generated|pll1|clk[4]}] -to [get_clocks]
set_false_path -from [get_clocks] -to [get_clocks {I_PLL2|altpll_component|auto_generated|pll1|clk[4]}]

# decouple CLK_MAIN from CLK_33M
set_false_path -from [get_clocks {CLK_MAIN}] -to [get_clocks {CLK_33M}]
set_false_path -from [get_clocks {CLK_33M}] -to [get_clocks {CLK_MAIN}]
#**************************************************************
# Set Multicycle Path
#**************************************************************

#**************************************************************
# Set Maximum Delay
#**************************************************************

#**************************************************************
# Set Minimum Delay
#**************************************************************

#**************************************************************
# Set Input Transition
#**************************************************************

