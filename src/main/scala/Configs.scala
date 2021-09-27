package vcu128

import chisel3._
import freechips.rocketchip.config._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink.BootROMParams
import freechips.rocketchip.subsystem._
import freechips.rocketchip.subsystem.MemoryPortParams
import freechips.rocketchip.rocket.{
  RocketCoreParams,
  MulDivParams,
  DCacheParams,
  ICacheParams
}
import freechips.rocketchip.tile.{RocketTileParams, XLen}
import freechips.rocketchip.util._

class WithBootROM
    extends Config((site, here, up) => {
      case BootROMParams =>
        BootROMParams(
          hang = 0x10000, // entry point
          contentFileName = s"./bootrom/bootrom.rv${site(XLen)}.img"
        )
    })

class WithIDBits(n: Int)
    extends Config((site, here, up) => {
      case ExtMem =>
        up(ExtMem, site).map(x => x.copy(master = x.master.copy(idBits = n)))
      case ExtBus => up(ExtBus, site).map(x => x.copy(idBits = n))
    })

class WithCustomMMIOPort extends Config((site, here, up) => {
  case ExtBus => Some(MasterPortParams(
                      base = BigInt("60000000", 16),
                      size = BigInt("a0000000", 16),
                      beatBytes = site(MemoryBusKey).beatBytes,
                      idBits = 4))
})

class WithCustomMemPort extends Config((site, here, up) => {
  case ExtMem => Some(MemoryPortParams(MasterPortParams(
                      base = BigInt("100000000", 16),
                      size = BigInt("100000000", 16),
                      beatBytes = site(MemoryBusKey).beatBytes,
                      idBits = 4), 1))
})

class RocketConfig
    extends Config(new WithoutTLMonitors ++
    new WithJtagDTM ++
    new WithIDBits(5) ++
    new WithNSmallCores(1) ++
    new WithBootROM ++
    new WithCustomMemPort ++
    new WithCustomMMIOPort ++
    new freechips.rocketchip.system.BaseConfig)
