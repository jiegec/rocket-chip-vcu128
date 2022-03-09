set_property -dict {PACKAGE_PIN BM29 IOSTANDARD LVCMOS12} [get_ports reset]

# easy to confuse rxd/txd here
# uart0_txd
set_property -dict {PACKAGE_PIN BP26 IOSTANDARD LVCMOS18} [get_ports jtag_TCK]
# uart0_rxd
set_property -dict {PACKAGE_PIN BN26 IOSTANDARD LVCMOS18} [get_ports jtag_TDI]
# uart0_rts
set_property -dict {PACKAGE_PIN BP22 IOSTANDARD LVCMOS18} [get_ports jtag_TDO]
# uart0_cts
set_property -dict {PACKAGE_PIN BP23 IOSTANDARD LVCMOS18} [get_ports jtag_TMS]

# assume 10MHz jtag
# ref https://github.com/pulp-platform/pulp/blob/master/fpga/pulp-vcu118/constraints/vcu118.xdc
# intel jtag timing: https://www.intel.com/content/www/us/en/docs/programmable/683301/current/jtag-configuration-timing.html
# ft4232 timing: https://ftdichip.com/wp-content/uploads/2020/08/DS_FT4232H.pdf
create_clock -period 100.000 -name jtag_TCK [get_ports jtag_TCK]
set_input_jitter jtag_TCK 1.000
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF_inst/O]
set_input_delay -clock jtag_TCK -clock_fall 5.000 [get_ports jtag_TDI]
set_input_delay -clock jtag_TCK -clock_fall 5.000 [get_ports jtag_TMS]
set_output_delay -clock jtag_TCK 5.000 [get_ports jtag_TDO]
set_max_delay -to [get_ports jtag_TDO] 20.000
set_max_delay -from [get_ports jtag_TMS] 20.000
set_max_delay -from [get_ports jtag_TDI] 20.000
set_clock_groups -asynchronous -group [get_clocks jtag_TCK] -group [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT1]]
set_property ASYNC_REG TRUE [get_cells -hier -regexp "system_i/rocketchip_wrapper_0/.*/cdc_reg_reg.*"]

set_property MARK_DEBUG true [get_nets jtag_TDI]
set_property MARK_DEBUG true [get_nets jtag_TDO]
set_property MARK_DEBUG true [get_nets jtag_TCK]
set_property MARK_DEBUG true [get_nets jtag_TMS]