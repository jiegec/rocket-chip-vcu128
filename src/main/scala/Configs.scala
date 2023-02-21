package vcu128

import chisel3._
import freechips.rocketchip.config._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink.BootROMParams
import freechips.rocketchip.devices.tilelink.BootROMLocated
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

class WithBootROMResetAddress(resetAddress: BigInt)
    extends Config((_, _, up) => { case BootROMLocated(x) =>
      up(BootROMLocated(x)).map(_.copy(hang = resetAddress))
    })

class WithIDBits(n: Int)
    extends Config((site, here, up) => {
      case ExtMem =>
        up(ExtMem, site).map(x => x.copy(master = x.master.copy(idBits = n)))
      case ExtBus => up(ExtBus, site).map(x => x.copy(idBits = n))
    })

class WithCustomMMIOPort
    extends Config((site, here, up) => { case ExtBus =>
      Some(
        MasterPortParams(
          base = BigInt("60000000", 16),
          size = BigInt("20000000", 16),
          beatBytes = site(MemoryBusKey).beatBytes,
          idBits = 4
        )
      )
    })

class WithCustomMemPort
    extends Config((site, here, up) => { case ExtMem =>
      Some(
        MemoryPortParams(
          MasterPortParams(
            base = BigInt("80000000", 16),
            size = BigInt("80000000", 16),
            beatBytes = site(MemoryBusKey).beatBytes,
            idBits = 4
          ),
          1
        )
      )
    })

class WithCFlush
    extends Config((site, here, up) => { case RocketTilesKey =>
      up(RocketTilesKey, site).map(x =>
        x.copy(core = x.core.copy(haveCFlush = true))
      )
    })

class WithCustomJtag
    extends Config((site, here, up) => { case JtagDTMKey =>
      new JtagDTMConfig(
        idcodeVersion = 1,
        idcodePartNum = 0,
        idcodeManufId = 0x489, // SiFive
        debugIdleCycles = 5
      )
    })

class RocketConfig
    extends Config(
      new WithCoherentBusTopology ++
        new WithoutTLMonitors ++
        new WithIDBits(5) ++
        new WithCFlush ++
        new WithCustomJtag ++
        new WithJtagDTM ++
        new WithNBigCores(2) ++
        new WithBootROMResetAddress(0x10000) ++
        new WithNExtTopInterrupts(6) ++ // UART(1) + ETH(1+2) + I2C(1) + SPI(1)
        new WithCustomMemPort ++
        new WithCustomMMIOPort ++
        new WithDefaultSlavePort ++
        new freechips.rocketchip.system.BaseConfig
    )
