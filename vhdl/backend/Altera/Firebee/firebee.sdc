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
## VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"

## DATE    "Mon Jun  9 15:23:23 2014"

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

create_generated_clock -name {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]} -source [get_pins {I_PLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 16 -divide_by 215 -master_clock {CLK_MAIN} [get_pins {I_PLL1|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[1]} -source [get_pins {I_PLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 32 -divide_by 43 -master_clock {CLK_MAIN} [get_pins {I_PLL1|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[2]} -source [get_pins {I_PLL1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 16 -divide_by 11 -master_clock {CLK_MAIN} [get_pins {I_PLL1|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]} -source [get_pins {I_PLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 97 -divide_by 1600 -master_clock {CLK_MAIN} [get_pins {I_PLL3|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]} -source [get_pins {I_PLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 97 -divide_by 200 -master_clock {CLK_MAIN} [get_pins {I_PLL3|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]} -source [get_pins {I_PLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 97 -divide_by 128 -master_clock {CLK_MAIN} [get_pins {I_PLL3|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]} -source [get_pins {I_PLL3|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 97 -divide_by 6416 -master_clock {CLK_MAIN} [get_pins {I_PLL3|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]} -source [get_pins {I_PLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -phase 240.000 -master_clock {CLK_MAIN} [get_pins {I_PLL2|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]} -source [get_pins {I_PLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {CLK_MAIN} [get_pins {I_PLL2|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]} -source [get_pins {I_PLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -phase 180.000 -master_clock {CLK_MAIN} [get_pins {I_PLL2|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]} -source [get_pins {I_PLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -phase 105.000 -master_clock {CLK_MAIN} [get_pins {I_PLL2|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]} -source [get_pins {I_PLL2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -phase 270.000 -master_clock {CLK_MAIN} [get_pins {I_PLL2|altpll_component|auto_generated|pll1|clk[4]}] 
create_generated_clock -name {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]} -source [get_pins {I_PLL4|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 32 -divide_by 11 -master_clock {CLK_MAIN} [get_pins {I_PLL4|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {CLK_33M}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {CLK_33M}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {CLK_MAIN}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {CLK_MAIN}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {CLK_33M}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {CLK_33M}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {CLK_MAIN}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {CLK_MAIN}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_33M}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {CLK_MAIN}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {CLK_MAIN}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {CLK_MAIN}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {CLK_MAIN}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLK_MAIN}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[1]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_33M}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_33M}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[4]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_33M}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_33M}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_33M}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_33M}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {altpll4:I_PLL4|altpll:altpll_component|altpll4_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {altpll2:I_PLL2|altpll:altpll_component|altpll_da13:auto_generated|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[2]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_33M}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_33M}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -rise_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}] -fall_to [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll3:I_PLL3|altpll:altpll_component|altpll_66t2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[2]}] -rise_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[2]}] -fall_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[1]}] -rise_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[1]}] -fall_to [get_clocks {CLK_33M}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -rise_to [get_clocks {CLK_MAIN}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {altpll1:I_PLL1|altpll:altpll_component|altpll_dnn2:auto_generated|clk[0]}] -fall_to [get_clocks {CLK_MAIN}] -hold 0.090  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_DRQn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_INTn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {AMKB_RX}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CF_WP}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_33M}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_MAIN}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CTS}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DACK0n}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DACK1n}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DCD}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[8]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[9]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[10]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[11]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[12]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[13]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[14]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[15]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[16]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[17]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[8]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[9]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[10]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[11]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[12]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[13]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[14]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[15]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DVI_INT}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {E0_INT}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[8]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[9]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[10]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[11]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[12]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[13]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[14]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[15]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[16]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[17]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[18]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[19]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[20]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[21]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[22]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[23]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[24]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[25]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[26]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[27]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[28]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[29]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[30]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[31]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_ALE}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_BURSTn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_CSn[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_CSn[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_CSn[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_OEn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_SIZE[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_SIZE[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_WRn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_DCHGn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_HD_DD}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_INDEXn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_RDn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_TRACK00}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_WPn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IDE_INT}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IDE_RDY}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_BUSY}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {MASTERn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {MIDI_IN}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {PCI_INTAn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {PCI_INTBn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {PCI_INTCn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {PCI_INTDn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {PIC_AMKB_RX}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {PIC_INT}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {RI}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {RSTO_MCFn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {RxD}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_BUSYn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_CDn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_DRQn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_IOn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_MSGn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_PAR}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_RSTn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_SELn}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_CARD_DETECT}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_CMD_D1}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_D0}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_D1}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_D2}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_D3}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_WP}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {TOUT0n}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[8]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[9]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[10]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[11]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[12]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[13]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[14]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[15]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[16]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[17]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[18]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[19]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[20]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[21]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[22]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[23]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[24]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[25]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[26]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[27]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[28]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[29]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[30]}]
set_input_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[31]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_A1}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_ACKn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_CSn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_DIR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_D[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ACSI_RESETn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {AMKB_TX}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {BA[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {BA[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {BLANKn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CF_CSn[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CF_CSn[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_24M576}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_25M}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_DDR_OUT}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_DDR_OUTn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_PIXEL}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {CLK_USB}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DREQ1n}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSA_D}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[8]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[9]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[10]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[11]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[12]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[13]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[14]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[15]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[16]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_IO[17]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRBHEn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRBLEn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRCSn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[8]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[9]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[10]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[11]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[12]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[13]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[14]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRD[15]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SROEn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DSP_SRWEn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {DTR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[8]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[9]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[10]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[11]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[12]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[13]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[14]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[15]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[16]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[17]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[18]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[19]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[20]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[21]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[22]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[23]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[24]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[25]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[26]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[27]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[28]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[29]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[30]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_AD[31]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FB_TAn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_MOT_ON}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_SDSELn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_STEP}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_STEP_DIR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_WDn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {FDD_WR_GATE}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {HSYNC}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IDE_CSn[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IDE_CSn[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IDE_RDn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IDE_RES}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IDE_WRn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IRQn[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IRQn[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IRQn[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IRQn[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IRQn[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {IRQn[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LED_FPGA_OK}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_DIR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_D[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {LP_STR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {MIDI_OLR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {MIDI_TLR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {PD_VGAn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {RESERVED_1}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ROM3n}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {ROM4n}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {RP_LDSn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {RP_UDSn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {RTS}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_ACKn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_ATNn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_BUSYn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_DIR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_D[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_PAR}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_RSTn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SCSI_SELn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_CLK}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_CMD_D1}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SD_D3}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {SYNCn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {TIN0}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {TxD}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[8]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[9]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[10]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[11]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VA[12]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VB[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VCASn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VCKE}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VCSn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VDM[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VDM[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VDM[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VDM[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[8]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[9]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[10]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[11]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[12]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[13]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[14]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[15]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[16]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[17]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[18]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[19]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[20]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[21]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[22]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[23]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[24]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[25]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[26]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[27]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[28]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[29]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[30]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD[31]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD_QS[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD_QS[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD_QS[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VD_QS[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VG[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VRASn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VR[7]}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VSYNC}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {VWEn}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {YM_QA}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {YM_QB}]
set_output_delay -add_delay -max -clock [get_clocks {CLK_33M}]  5.000 [get_ports {YM_QC}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_id9:dffpipe17|dffe18a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_hd9:dffpipe12|dffe13a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_kd9:dffpipe15|dffe16a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_jd9:dffpipe12|dffe13a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe19|dffe20a*}]
set_false_path -from [get_registers {*dcfifo*delayed_wrptr_g[*]}] -to [get_registers {*dcfifo*rs_dgwp*}]
set_false_path -from [get_registers {*dcfifo*rdptr_g[*]}] -to [get_registers {*dcfifo*ws_dgrp*}]


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

