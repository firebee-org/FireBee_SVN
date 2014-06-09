#**************************************************************
# Time Information
#**************************************************************

 set_time_format -unit ps



#**************************************************************
# Create Clock
#**************************************************************

# create_clock -name CLK -period 100.000 -waveform {0.000 50.000} [get_ports {CLK}]

create_clock -period 30.303 -name CLK_MAIN [get_ports {CLK_MAIN}]
create_clock -period 30.303 -name CLK_33M [get_ports {CLK_33M}]

derive_pll_clocks -use_net_name
derive_clock_uncertainty

#set_clock_groups -exclusive -group {CLK_2M0}
#set_clock_groups -exclusive -group {CLK_500K}
#set_clock_groups -exclusive -group {CLK_2M4576}
#set_clock_groups -exclusive -group {CLK_24M576}
#set_clock_groups -exclusive -group {CLK_FDC}
#set_clock_groups -exclusive -group {CLK_VIDEO}
#set_clock_groups -exclusive -group {CLK_25M}
#set_clock_groups -exclusive -group {CLK_48M}
#set_clock_groups -exclusive -group {CLK_PIXEL}

