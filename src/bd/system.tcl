
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# rocketchip_wrapper

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu37p-fsvh2892-2L-e
   set_property BOARD_PART xilinx.com:vcu128:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_ethernet:7.2\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:axi_iic:2.0\
xilinx.com:ip:axi_quad_spi:3.2\
xilinx.com:ip:axi_uart16550:2.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:hbm:1.0\
xilinx.com:ip:jtag_axi:1.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:vio:3.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
rocketchip_wrapper\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set default_100mhz_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 default_100mhz_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $default_100mhz_clk

  set iic_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_0 ]

  set mdio_mdc [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_mdc ]

  set rs232_uart_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 rs232_uart_0 ]

  set sgmii_lvds [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_lvds ]

  set sgmii_phyclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sgmii_phyclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {625000000} \
   ] $sgmii_phyclk


  # Create ports
  set dummy_port_in [ create_bd_port -dir I -type rst dummy_port_in ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $dummy_port_in
  set jtag_TCK [ create_bd_port -dir I jtag_TCK ]
  set jtag_TDI [ create_bd_port -dir I jtag_TDI ]
  set jtag_TDO [ create_bd_port -dir O jtag_TDO ]
  set jtag_TMS [ create_bd_port -dir I jtag_TMS ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset

  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.2 axi_ethernet_0 ]
  set_property -dict [ list \
   CONFIG.DIFFCLK_BOARD_INTERFACE {sgmii_phyclk} \
   CONFIG.ENABLE_LVDS {true} \
   CONFIG.ETHERNET_BOARD_INTERFACE {sgmii_lvds} \
   CONFIG.InstantiateBitslice0 {true} \
   CONFIG.MDIO_BOARD_INTERFACE {mdio_mdc} \
   CONFIG.PHYADDR {0} \
   CONFIG.PHYRST_BOARD_INTERFACE {Custom} \
   CONFIG.PHYRST_BOARD_INTERFACE_DUMMY_PORT {dummy_port_in} \
   CONFIG.PHY_TYPE {SGMII} \
   CONFIG.RXCSUM {Full} \
   CONFIG.TXCSUM {Full} \
   CONFIG.lvdsclkrate {625} \
   CONFIG.rxlane0_placement {DIFF_PAIR_2} \
   CONFIG.rxnibblebitslice0used {false} \
   CONFIG.txlane0_placement {DIFF_PAIR_1} \
 ] $axi_ethernet_0

  # Create instance: axi_ethernet_0_dma, and set properties
  set axi_ethernet_0_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_ethernet_0_dma ]
  set_property -dict [ list \
   CONFIG.c_addr_width {64} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_m_axi_mm2s_data_width {32} \
   CONFIG.c_m_axis_mm2s_tdata_width {32} \
   CONFIG.c_mm2s_burst_size {16} \
   CONFIG.c_sg_length_width {16} \
   CONFIG.c_sg_use_stsapp_length {1} \
 ] $axi_ethernet_0_dma

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_0 ]
  set_property -dict [ list \
   CONFIG.IIC_BOARD_INTERFACE {iic_0} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_iic_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {4} \
 ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axi_interconnect_1

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list \
   CONFIG.NUM_MI {6} \
   CONFIG.NUM_SI {1} \
 ] $axi_mem_intercon

  # Create instance: axi_quad_spi_0, and set properties
  set axi_quad_spi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_0 ]
  set_property -dict [ list \
   CONFIG.C_FIFO_DEPTH {256} \
   CONFIG.C_SCK_RATIO {2} \
   CONFIG.C_SPI_MEMORY {2} \
   CONFIG.C_SPI_MEM_ADDR_BITS {24} \
   CONFIG.C_SPI_MODE {0} \
   CONFIG.C_TYPE_OF_AXI4_INTERFACE {1} \
   CONFIG.C_USE_STARTUP {1} \
   CONFIG.C_USE_STARTUP_INT {1} \
   CONFIG.C_XIP_MODE {0} \
   CONFIG.C_XIP_PERF_MODE {0} \
 ] $axi_quad_spi_0

  # Create instance: axi_uart16550_0, and set properties
  set axi_uart16550_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_0 ]
  set_property -dict [ list \
   CONFIG.UART_BOARD_INTERFACE {rs232_uart_1} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uart16550_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT2_JITTER {132.683} \
   CONFIG.CLKOUT2_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {50} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {default_100mhz_clk} \
   CONFIG.CLK_OUT1_PORT {clk_100M} \
   CONFIG.CLK_OUT2_PORT {clk_50M} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {24} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_0

  # Create instance: hbm_0, and set properties
  set hbm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm_0 ]
  set_property -dict [ list \
   CONFIG.USER_APB_EN {false} \
   CONFIG.USER_CLK_SEL_LIST0 {AXI_00_ACLK} \
   CONFIG.USER_SAXI_01 {false} \
   CONFIG.USER_SAXI_02 {false} \
   CONFIG.USER_SAXI_03 {false} \
   CONFIG.USER_SAXI_04 {false} \
   CONFIG.USER_SAXI_05 {false} \
   CONFIG.USER_SAXI_06 {false} \
   CONFIG.USER_SAXI_07 {false} \
   CONFIG.USER_SAXI_08 {false} \
   CONFIG.USER_SAXI_09 {false} \
   CONFIG.USER_SAXI_10 {false} \
   CONFIG.USER_SAXI_11 {false} \
   CONFIG.USER_SAXI_12 {false} \
   CONFIG.USER_SAXI_13 {false} \
   CONFIG.USER_SAXI_14 {false} \
   CONFIG.USER_SAXI_15 {false} \
 ] $hbm_0

  # Create instance: jtag_axi_0, and set properties
  set jtag_axi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag_axi_0 ]
  set_property -dict [ list \
   CONFIG.M_AXI_ADDR_WIDTH {64} \
   CONFIG.M_AXI_DATA_WIDTH {64} \
 ] $jtag_axi_0

  # Create instance: rocketchip_wrapper_0, and set properties
  set block_name rocketchip_wrapper
  set block_cell_name rocketchip_wrapper_0
  if { [catch {set rocketchip_wrapper_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $rocketchip_wrapper_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: rst_clk_wiz_0_100M, and set properties
  set rst_clk_wiz_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_0_100M ]

  # Create instance: vio_0, and set properties
  set vio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0 ]
  set_property -dict [ list \
   CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
   CONFIG.C_NUM_PROBE_IN {0} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {0x1} \
 ] $vio_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {6} \
 ] $xlconcat_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins rocketchip_wrapper_0/M_AXI_MMIO]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins rocketchip_wrapper_0/M_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXIS_CNTRL [get_bd_intf_pins axi_ethernet_0/s_axis_txc] [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_CNTRL]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXIS_MM2S [get_bd_intf_pins axi_ethernet_0/s_axis_txd] [get_bd_intf_pins axi_ethernet_0_dma/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXI_MM2S [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXI_S2MM [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_dma_M_AXI_SG [get_bd_intf_pins axi_ethernet_0_dma/M_AXI_SG] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxs [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins axi_ethernet_0_dma/S_AXIS_STS]
  connect_bd_intf_net -intf_net axi_ethernet_0_mdio [get_bd_intf_ports mdio_mdc] [get_bd_intf_pins axi_ethernet_0/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_0_sgmii [get_bd_intf_ports sgmii_lvds] [get_bd_intf_pins axi_ethernet_0/sgmii]
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_ports iic_0] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins rocketchip_wrapper_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins hbm_0/SAXI_00]
  connect_bd_intf_net -intf_net axi_mem_intercon_M01_AXI [get_bd_intf_pins axi_mem_intercon/M01_AXI] [get_bd_intf_pins axi_quad_spi_0/AXI_FULL]
  connect_bd_intf_net -intf_net axi_mem_intercon_M02_AXI [get_bd_intf_pins axi_mem_intercon/M02_AXI] [get_bd_intf_pins axi_uart16550_0/S_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_M03_AXI [get_bd_intf_pins axi_ethernet_0/s_axi] [get_bd_intf_pins axi_mem_intercon/M03_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_M04_AXI [get_bd_intf_pins axi_ethernet_0_dma/S_AXI_LITE] [get_bd_intf_pins axi_mem_intercon/M04_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_M05_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins axi_mem_intercon/M05_AXI]
  connect_bd_intf_net -intf_net axi_uart16550_0_UART [get_bd_intf_ports rs232_uart_0] [get_bd_intf_pins axi_uart16550_0/UART]
  connect_bd_intf_net -intf_net default_100mhz_clk_1 [get_bd_intf_ports default_100mhz_clk] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]
  connect_bd_intf_net -intf_net jtag_axi_0_M_AXI [get_bd_intf_pins axi_interconnect_0/S03_AXI] [get_bd_intf_pins jtag_axi_0/M_AXI]
  connect_bd_intf_net -intf_net sgmii_phyclk_1 [get_bd_intf_ports sgmii_phyclk] [get_bd_intf_pins axi_ethernet_0/lvds_clk]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins rst_clk_wiz_0_100M/interconnect_aresetn]
  connect_bd_net -net axi_ethernet_0_dma_mm2s_cntrl_reset_out_n [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins axi_ethernet_0_dma/mm2s_cntrl_reset_out_n]
  connect_bd_net -net axi_ethernet_0_dma_mm2s_introut [get_bd_pins axi_ethernet_0_dma/mm2s_introut] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net axi_ethernet_0_dma_mm2s_prmry_reset_out_n [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins axi_ethernet_0_dma/mm2s_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_0_dma_s2mm_introut [get_bd_pins axi_ethernet_0_dma/s2mm_introut] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net axi_ethernet_0_dma_s2mm_prmry_reset_out_n [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins axi_ethernet_0_dma/s2mm_prmry_reset_out_n]
  connect_bd_net -net axi_ethernet_0_dma_s2mm_sts_reset_out_n [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0_dma/s2mm_sts_reset_out_n]
  connect_bd_net -net axi_ethernet_0_interrupt [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins xlconcat_0/In5]
  connect_bd_net -net axi_quad_spi_0_ip2intc_irpt [get_bd_pins axi_quad_spi_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_uart16550_0_ip2intc_irpt [get_bd_pins axi_uart16550_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net clk_wiz_0_clk_50M [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_quad_spi_0/ext_spi_clk] [get_bd_pins clk_wiz_0/clk_50M] [get_bd_pins rocketchip_wrapper_0/clk] [get_bd_pins rst_clk_wiz_0_100M/slowest_sync_clk]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins axi_ethernet_0_dma/m_axi_mm2s_aclk] [get_bd_pins axi_ethernet_0_dma/m_axi_s2mm_aclk] [get_bd_pins axi_ethernet_0_dma/m_axi_sg_aclk] [get_bd_pins axi_ethernet_0_dma/s_axi_lite_aclk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_0/S02_ACLK] [get_bd_pins axi_interconnect_0/S03_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/M01_ACLK] [get_bd_pins axi_mem_intercon/M02_ACLK] [get_bd_pins axi_mem_intercon/M03_ACLK] [get_bd_pins axi_mem_intercon/M04_ACLK] [get_bd_pins axi_mem_intercon/M05_ACLK] [get_bd_pins axi_quad_spi_0/s_axi4_aclk] [get_bd_pins axi_uart16550_0/s_axi_aclk] [get_bd_pins clk_wiz_0/clk_100M] [get_bd_pins hbm_0/APB_0_PCLK] [get_bd_pins hbm_0/AXI_00_ACLK] [get_bd_pins hbm_0/HBM_REF_CLK_0] [get_bd_pins jtag_axi_0/aclk] [get_bd_pins vio_0/clk]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins rst_clk_wiz_0_100M/dcm_locked]
  connect_bd_net -net dummy_port_in_1 [get_bd_ports dummy_port_in] [get_bd_pins axi_ethernet_0/dummy_port_in]
  connect_bd_net -net jtag_TCK_0_1 [get_bd_ports jtag_TCK] [get_bd_pins rocketchip_wrapper_0/jtag_TCK]
  connect_bd_net -net jtag_TDI_0_1 [get_bd_ports jtag_TDI] [get_bd_pins rocketchip_wrapper_0/jtag_TDI]
  connect_bd_net -net jtag_TMS_0_1 [get_bd_ports jtag_TMS] [get_bd_pins rocketchip_wrapper_0/jtag_TMS]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins rst_clk_wiz_0_100M/ext_reset_in]
  connect_bd_net -net rocketchip_wrapper_0_jtag_TDO [get_bd_ports jtag_TDO] [get_bd_pins rocketchip_wrapper_0/jtag_TDO]
  connect_bd_net -net rst_clk_wiz_0_100M_mb_reset [get_bd_pins rocketchip_wrapper_0/reset] [get_bd_pins rst_clk_wiz_0_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_0_100M_peripheral_aresetn [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins axi_ethernet_0_dma/axi_resetn] [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_0/S02_ARESETN] [get_bd_pins axi_interconnect_0/S03_ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/M01_ARESETN] [get_bd_pins axi_mem_intercon/M02_ARESETN] [get_bd_pins axi_mem_intercon/M03_ARESETN] [get_bd_pins axi_mem_intercon/M04_ARESETN] [get_bd_pins axi_mem_intercon/M05_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_quad_spi_0/s_axi4_aresetn] [get_bd_pins axi_uart16550_0/s_axi_aresetn] [get_bd_pins hbm_0/APB_0_PRESET_N] [get_bd_pins hbm_0/AXI_00_ARESET_N] [get_bd_pins jtag_axi_0/aresetn] [get_bd_pins rst_clk_wiz_0_100M/peripheral_aresetn]
  connect_bd_net -net vio_0_probe_out0 [get_bd_pins rst_clk_wiz_0_100M/aux_reset_in] [get_bd_pins vio_0/probe_out0]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins rocketchip_wrapper_0/interrupts] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins clk_wiz_0/reset] [get_bd_pins xlconstant_0/dout]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00010000000000000000 -target_address_space [get_bd_addr_spaces axi_ethernet_0_dma/Data_SG] [get_bd_addr_segs rocketchip_wrapper_0/S_AXI/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000000000000000 -target_address_space [get_bd_addr_spaces axi_ethernet_0_dma/Data_MM2S] [get_bd_addr_segs rocketchip_wrapper_0/S_AXI/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000000000000000 -target_address_space [get_bd_addr_spaces axi_ethernet_0_dma/Data_S2MM] [get_bd_addr_segs rocketchip_wrapper_0/S_AXI/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000000000000000 -target_address_space [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs rocketchip_wrapper_0/S_AXI/reg0] -force
  assign_bd_address -offset 0x60400000 -range 0x00040000 -target_address_space [get_bd_addr_spaces rocketchip_wrapper_0/M_AXI_MMIO] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x60300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces rocketchip_wrapper_0/M_AXI_MMIO] [get_bd_addr_segs axi_ethernet_0_dma/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x60500000 -range 0x00010000 -target_address_space [get_bd_addr_spaces rocketchip_wrapper_0/M_AXI_MMIO] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x60100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces rocketchip_wrapper_0/M_AXI_MMIO] [get_bd_addr_segs axi_quad_spi_0/aximm/MEM0] -force
  assign_bd_address -offset 0x60200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces rocketchip_wrapper_0/M_AXI_MMIO] [get_bd_addr_segs axi_uart16550_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces rocketchip_wrapper_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM08] -force
  assign_bd_address -offset 0x90000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces rocketchip_wrapper_0/M_AXI] [get_bd_addr_segs hbm_0/SAXI_00/HBM_MEM09] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


