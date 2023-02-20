open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE {./proj/rocket-chip-vcu128.runs/impl_1/system_wrapper.bit} [lindex [get_hw_devices] 0]
set_property PROBES.FILE {./proj/rocket-chip-vcu128.runs/impl_1/system_wrapper.ltx} [lindex [get_hw_devices] 0]
refresh_hw_device

set_property OUTPUT_VALUE 1 [get_hw_probes system_i/vio_0_probe_out0]
commit_hw_vio [get_hw_probes {system_i/vio_0_probe_out0}]
set_property OUTPUT_VALUE 0 [get_hw_probes system_i/vio_0_probe_out0]
commit_hw_vio [get_hw_probes {system_i/vio_0_probe_out0}]
set_property OUTPUT_VALUE 1 [get_hw_probes system_i/vio_0_probe_out0]
commit_hw_vio [get_hw_probes {system_i/vio_0_probe_out0}]
