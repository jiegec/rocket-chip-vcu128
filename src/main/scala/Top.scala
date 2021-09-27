package vcu128

import chisel3._
import freechips.rocketchip.config.{Parameters, Field}
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy.{LazyModule, LazyModuleImp}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._

class RocketChip(implicit val p: Parameters) extends Module {
  val config = p(ExtIn)
  val target = Module(LazyModule(new RocketTop).module)

  require(target.mem_axi4.size == 1)
  require(target.mmio_axi4.size == 1)
  require(target.debug.head.systemjtag.size == 1)

  val io = IO(new Bundle {
    val interrupts = Input(UInt(2.W))
    val mem_axi4 = target.mem_axi4.head.cloneType
    val mmio_axi4 = target.mmio_axi4.head.cloneType
  })

  io.mem_axi4 <> target.mem_axi4.head
  io.mmio_axi4 <> target.mmio_axi4.head

  target.interrupts := io.interrupts

  val boardJTAG = Module(new BscanJTAG)
  val jtagBundle = target.debug.head.systemjtag.head

  // set JTAG parameters
  jtagBundle.reset := reset
  jtagBundle.mfr_id := 0x233.U(11.W)
  jtagBundle.part_number := 0.U(16.W)
  jtagBundle.version := 0.U(4.W)
  // connect to BSCAN
  jtagBundle.jtag.TCK := boardJTAG.tck
  jtagBundle.jtag.TMS := boardJTAG.tms
  jtagBundle.jtag.TDI := boardJTAG.tdi
  boardJTAG.tdo := jtagBundle.jtag.TDO.data
  boardJTAG.tdoEnable := jtagBundle.jtag.TDO.driven

  target.dontTouchPorts()
}

class RocketTop(implicit p: Parameters)
    extends RocketSubsystem
    with HasHierarchicalBusTopology
    with HasPeripheryBootROM
    with HasAsyncExtInterrupts
    with CanHaveMasterAXI4MemPort
    with CanHaveMasterAXI4MMIOPort {
  override lazy val module = new RocketTopModule(this)
}

class RocketTopModule(outer: RocketTop)
    extends RocketSubsystemModuleImp(outer)
    with HasRTCModuleImp
    with HasExtInterruptsModuleImp
    with HasPeripheryBootROMModuleImp
    with DontTouch {
  lazy val mem_axi4 = outer.mem_axi4
  lazy val mmio_axi4 = outer.mmio_axi4
}
