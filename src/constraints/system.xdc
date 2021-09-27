set_property -dict {PACKAGE_PIN BM29 IOSTANDARD LVCMOS12} [get_ports reset]

# below is taken from axi_quad_spi xdc

## IOB constraints ######

#####################################################################################################
# The following section list the board specific constraints (with/without STARTUPE2/E3 primitive)   #
# as per guidance given in product guide.                                                           #
# User should uncomment, update constraints based on board delays and use                           #
#####################################################################################################

#### All the delay numbers have to be provided by the user

#### CCLK max delay is 6.7 ns ; refer Data sheet
#### We need to consider the max delay for worst case analysis
set cclk_delay 6.7

#### Following are the SPI device parameters
#### Max Tco
set tco_max 7
#### Min Tco
set tco_min 1
#### Setup time requirement
set tsu 2
#### Hold time requirement
set th 3
#####################################################################################################
# STARTUPE3 primitive included inside IP for US+                                                             #
#####################################################################################################
set tdata_trace_delay_max 0.25
set tdata_trace_delay_min 0.25
set tclk_trace_delay_max 0.2
set tclk_trace_delay_min 0.2
create_generated_clock -name clk_sck -source [get_pins -hierarchical *axi_quad_spi_0/ext_spi_clk] [get_pins -hierarchical */CCLK] -edges {3 5 7}
create_generated_clock -name clk_sck -source [get_pins -filter {REF_PIN_NAME==ext_spi_clk} -of [get_cells -hier -filter {REF_NAME=~axi_quad_spi_0}]] [get_pins -hierarchical */CCLK] -edges {3 5 7}
set_input_delay -clock clk_sck -max [expr $tco_max + $tdata_trace_delay_max + $tclk_trace_delay_max] [get_pins -hierarchical *STARTUP*/DATA_IN[*]] -clock_fall;
set_input_delay -clock clk_sck -min [expr $tco_min + $tdata_trace_delay_min + $tclk_trace_delay_min] [get_pins -hierarchical *STARTUP*/DATA_IN[*]] -clock_fall;
set_multicycle_path 2 -setup -from clk_sck -to [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]]
set_multicycle_path 1 -hold -end -from clk_sck -to [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]]
set_output_delay -clock clk_sck -max [expr $tsu + $tdata_trace_delay_max - $tclk_trace_delay_min] [get_pins -hierarchical *STARTUP*/DATA_OUT[*]];
set_output_delay -clock clk_sck -min [expr $tdata_trace_delay_min -$th - $tclk_trace_delay_max] [get_pins -hierarchical *STARTUP*/DATA_OUT[*]];
set_multicycle_path 2 -setup -start -from [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] -to clk_sck
set_multicycle_path 1 -hold -from [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] -to clk_sck

# debug
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list system_i/clk_wiz_0/inst/clk_50M]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 64 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[0]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[1]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[2]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[3]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[4]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[5]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[6]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[7]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[8]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[9]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[10]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[11]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[12]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[13]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[14]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[15]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[16]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[17]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[18]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[19]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[20]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[21]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[22]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[23]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[24]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[25]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[26]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[27]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[28]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[29]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[30]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[31]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[32]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[33]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[34]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[35]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[36]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[37]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[38]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[39]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[40]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[41]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[42]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[43]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[44]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[45]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[46]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[47]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[48]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[49]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[50]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[51]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[52]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[53]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[54]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[55]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[56]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[57]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[58]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[59]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[60]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[61]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[62]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_pc[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[0]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[1]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[2]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[3]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[4]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[5]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[6]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[7]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[8]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[9]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[10]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[11]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[12]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[13]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[14]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[15]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[16]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[17]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[18]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[19]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[20]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[21]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[22]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[23]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[24]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[25]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[26]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[27]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[28]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[29]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[30]} {system_i/rocketchip_wrapper_0/inst/top/target/tile/core/coreMonitorBundle_inst[31]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]