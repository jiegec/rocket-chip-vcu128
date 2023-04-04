package vcu128

import chisel3._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy.{LazyModule, LazyModuleImp}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.devices.debug.HasPeripheryDebug
import freechips.rocketchip.jtag.JTAGIO
import freechips.rocketchip.devices.debug.Debug
import freechips.rocketchip.devices.debug.JtagDTMKey
import org.chipsalliance.cde.config.Parameters

class RocketChip(implicit val p: Parameters) extends Module {
  val config = p(ExtIn)
  val top = LazyModule(new RocketTop)
  val target = Module(top.module)

  // ndreset can reset all harts
  val childReset = reset.asBool | top.debug.map(_.ndreset).getOrElse(false.B)
  target.reset := childReset

  require(target.mem_axi4.size == 1)
  require(target.mmio_axi4.size == 1)
  require(target.slave_axi4.size == 1)

  val io = IO(new Bundle {
    val interrupts = Input(UInt(p(NExtTopInterrupts).W))
    val mem_axi4 = target.mem_axi4.head.cloneType
    val mmio_axi4 = target.mmio_axi4.head.cloneType
    val slave_axi4 = Flipped(target.slave_axi4.head.cloneType)
    val jtag = Flipped(new JTAGIO())
  })

  val systemJtag = top.debug.get.systemjtag.get
  systemJtag.jtag.TCK := io.jtag.TCK
  systemJtag.jtag.TMS := io.jtag.TMS
  systemJtag.jtag.TDI := io.jtag.TDI
  io.jtag.TDO := systemJtag.jtag.TDO
  systemJtag.mfr_id := p(JtagDTMKey).idcodeManufId.U(11.W)
  systemJtag.part_number := p(JtagDTMKey).idcodePartNum.U(16.W)
  systemJtag.version := p(JtagDTMKey).idcodeVersion.U(4.W)
  // MUST use async reset here
  // otherwise the internal logic(e.g. TLXbar) might not function
  // if reset deasserted before TCK rises
  systemJtag.reset := reset.asAsyncReset
  top.resetctrl.foreach { rc =>
    rc.hartIsInReset.foreach { _ := childReset }
  }

  Debug.connectDebugClockAndReset(top.debug, clock)

  io.mem_axi4 <> target.mem_axi4.head
  io.mmio_axi4 <> target.mmio_axi4.head
  io.slave_axi4 <> target.slave_axi4.head

  target.interrupts := io.interrupts

  target.dontTouchPorts()
}

class RocketTop(implicit p: Parameters)
    extends RocketSubsystem
    with HasAsyncExtInterrupts
    with HasPeripheryDebug
    with CanHaveMasterAXI4MemPort
    with CanHaveMasterAXI4MMIOPort
    with CanHaveSlaveAXI4Port {
  override lazy val module = new RocketTopModule(this)

  // from freechips.rocketchip.system.ExampleRocketSystem
  val bootROM = p(BootROMLocated(location)).map {
    BootROM.attach(_, this, CBUS)
  }
}

class RocketTopModule(outer: RocketTop)
    extends RocketSubsystemModuleImp(outer)
    with HasRTCModuleImp
    with HasExtInterruptsModuleImp
    with DontTouch {
  lazy val mem_axi4 = outer.mem_axi4
  lazy val mmio_axi4 = outer.mmio_axi4
  lazy val slave_axi4 = outer.l2_frontend_bus_axi4
}
