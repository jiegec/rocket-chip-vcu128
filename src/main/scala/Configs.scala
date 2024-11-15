package vcu128

import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink.BootROMLocated
import freechips.rocketchip.subsystem._
import freechips.rocketchip.subsystem.MemoryPortParams
import freechips.rocketchip.subsystem.WithInclusiveCache
import org.chipsalliance.cde.config.Config
import boom.common.BoomTileAttachParams
import boom.common.WithNMediumBooms

class WithBootROMResetAddress(resetAddress: BigInt)
    extends Config((_, _, up) => { case BootROMLocated(x) =>
      up(BootROMLocated(x)).map(_.copy(hang = resetAddress))
    })

class WithIDBits(n: Int)
    extends Config((_, _, up) => {
      case ExtMem =>
        up(ExtMem).map(x => x.copy(master = x.master.copy(idBits = n)))
      case ExtBus => up(ExtBus).map(x => x.copy(idBits = n))
    })

class WithCustomMMIOPort
    extends Config((site, _, _) => { case ExtBus =>
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
    extends Config((site, _, _) => { case ExtMem =>
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
    extends Config((_, _, up) => { case TilesLocated(InSubsystem) =>
      up(TilesLocated(InSubsystem)) map {
        case tp: RocketTileAttachParams =>
          tp.copy(tileParams =
            tp.tileParams.copy(
              core = tp.tileParams.core.copy(
                haveCFlush = true
              )
            )
          )
        case tp: BoomTileAttachParams =>
          tp.copy(tileParams =
            tp.tileParams.copy(
              core = tp.tileParams.core.copy(
                haveCFlush = true
              )
            )
          )
        case t => t
      }
    })

class WithCustomJtag
    extends Config((_, _, _) => { case JtagDTMKey =>
      new JtagDTMConfig(
        idcodeVersion = 1,
        idcodePartNum = 0,
        idcodeManufId = 0x489, // SiFive
        debugIdleCycles = 5
      )
    })

class BaseConfig
    extends Config(
      new WithInclusiveCache ++
        new WithBootROMResetAddress(0x10000) ++
        new WithNExtTopInterrupts(6) ++ // UART(1) + ETH(1+2) + I2C(1) + SPI(1)
        new WithCustomMemPort ++
        new WithCustomMMIOPort ++
        new WithDefaultSlavePort ++
        new freechips.rocketchip.system.BaseConfig
    )

class RocketConfig
    extends Config(
      new WithCoherentBusTopology ++
        new WithoutTLMonitors ++
        new WithIDBits(5) ++
        new WithCFlush ++
        new WithBitManip ++
        new WithBitManipCrypto ++
        new WithCryptoNIST ++
        new WithCryptoSM ++
        new WithCustomJtag ++
        new WithJtagDTM ++
        // Rocket Core
        new WithNBigCores(2) ++
        // BOOM Core
        // new WithNMediumBooms(2) ++
        new BaseConfig
    )

class BOOMConfig
    extends Config(
      new WithCoherentBusTopology ++
        new WithoutTLMonitors ++
        new WithIDBits(5) ++
        new WithCFlush ++
        new WithBitManip ++
        new WithBitManipCrypto ++
        new WithCryptoNIST ++
        new WithCryptoSM ++
        new WithCustomJtag ++
        new WithJtagDTM ++
        // BOOM Core
        new WithNMediumBooms(2) ++
        new BaseConfig
    )

// set reset address to 0x80000000 for simulation
class SimConfig
    extends Config(
      new WithBootROMResetAddress(0x80000000L) ++
        new RocketConfig
    )
