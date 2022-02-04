package vcu128

// Taken from https://github.com/KireinaHoro/rocket-zcu102/blob/master/src/main/scala/BscanJTAG.scala

import chisel3._
import chisel3.util._
import chisel3.experimental.ExtModule

class BUFGCE extends ExtModule {
  val O = IO(Output(Bool()))
  val CE = IO(Input(Bool()))
  val I = IO(Input(Bool()))
}

class BSCANE2 extends ExtModule(Map("JTAG_CHAIN" -> 4)) {
  val TDO = IO(Input(Bool()))
  val CAPTURE = IO(Output(Bool()))
  val DRCK = IO(Output(Bool()))
  val RESET = IO(Output(Bool()))
  val RUNTEST = IO(Output(Bool()))
  val SEL = IO(Output(Bool()))
  val SHIFT = IO(Output(Bool()))
  val TCK = IO(Output(Bool()))
  val TDI = IO(Output(Bool()))
  val TMS = IO(Output(Bool()))
  val UPDATE = IO(Output(Bool()))
}

class BscanJTAG extends MultiIOModule {
  val tck: Clock = IO(Output(Clock()))
  val tms: Bool = IO(Output(Bool()))
  val tdi: Bool = IO(Output(Bool()))
  val tdo: Bool = IO(Input(Bool()))
  val tdoEnable: Bool = IO(Input(Bool()))

  val bscane2 = Module(new BSCANE2)
  tdi := bscane2.TDI
  bscane2.TDO := Mux(tdoEnable, tdo, true.B)
  val bufgce = Module(new BUFGCE)
  bufgce.I := bscane2.TCK
  bufgce.CE := bscane2.SEL
  tck := bufgce.O.asClock

  val posClock: Clock = bscane2.TCK.asClock
  val negClock: Clock = (!bscane2.TCK).asClock

  /** This two wire will cross two clock domain, generated at [[posClock]], used
    * in [[negClock]]
    */
  val tdiRegisterWire = Wire(Bool())
  val shiftCounterWire = Wire(UInt(7.W))
  withReset(!bscane2.SHIFT) {
    withClock(posClock) {
      val shiftCounter = RegInit(0.U(7.W))
      val posCounter = RegInit(0.U(8.W))
      val tdiRegister = RegInit(false.B)
      posCounter := posCounter + 1.U
      when(posCounter >= 1.U && posCounter <= 7.U) {
        shiftCounter := Cat(bscane2.TDI, shiftCounter.head(6))
      }
      when(posCounter === 0.U) {
        tdiRegister := !bscane2.TDI
      }
      tdiRegisterWire := tdiRegister
      shiftCounterWire := shiftCounter
    }
    withClock(negClock) {
      val negCounter = RegInit(0.U(8.W))
      negCounter := negCounter + 1.U
      tms := MuxLookup(
        negCounter,
        false.B,
        Array(
          4.U -> tdiRegisterWire,
          5.U -> true.B,
          shiftCounterWire + 7.U -> true.B,
          shiftCounterWire + 8.U -> true.B
        )
      )
    }
  }
}
