# This is an automatically generated file used by digilent_vivado_checkout.tcl to set project options
proc set_project_properties_post_create_project {proj_name} {
    set project_obj [get_projects $proj_name]
    set_property "part" "xcvu37p-fsvh2892-2L-e" $project_obj
    set_property "board_part" "xilinx.com:vcu128:part0:1.0" $project_obj
    set_property "default_lib" "xil_defaultlib" $project_obj
    set_property "simulator_language" "Mixed" $project_obj
    set_property "target_language" "Verilog" $project_obj
}

proc set_project_properties_pre_add_repo {proj_name} {
    set project_obj [get_projects $proj_name]
    # default nothing
}

proc set_project_properties_post_create_runs {proj_name} {
    set project_obj [get_projects $proj_name]
	#Custom directives for synthesis and implementation
	set_property STEPS.WRITE_BITSTREAM.ARGS.READBACK_FILE 0 [get_runs impl_1]
	set_property STEPS.WRITE_BITSTREAM.ARGS.VERBOSE 0 [get_runs impl_1]
}
