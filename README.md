# rocket-chip-vcu128

Port Rocket Chip to VCU128 platform. Based on [rocket2thinpad](https://github.com/jiegec/rocket2thinpad).

AXI Interconnect memory mapping:

1. AXI Quad SPI XIP: 0x6000_0000
2. AXI Quad SPI Ctrl: 0x6010_0000
3. AXI UART16550: 0x6020_0000
4. HBM: 0x8000_0000 ~ 0x8FFF_FFFF

Rocket Chip memory mapping:

1. Boot ROM: 0x0001_0000
2. CLINT: 0x0200_0000
3. MMIO: 0x6000_0000 ~ 0x7FFF_FFFF
4. Memory: 0x8000_0000 ~ 0xFFFF_FFFF

Access uart from USB at /dev/ttyUSB1, baudrate 115200. A virtual reset is available at VIO.

Can boot [Custom U-Boot](https://github.com/jiegec/u-boot/tree/rocket-chip-vcu128):

```shell
# in u-boot
$ make rocket-chip-vcu128_defconfig
$ make CROSS_COMPILE=riscv64-linux-gnu- -j4
# in this repo
$ python3 bootrom/boot.py /path/to/u-boot/u-boot.bin /dev/ttyUSB1
U-Boot 2021.07-00003-gfb1465705b (Sep 28 2021 - 15:53:56 +0800)

CPU:   rv64imafdc
Model: freechips,rocketchip-unknown
DRAM:  256 MiB
Loading Environment from nowhere... OK
In:    serial@60200000
Out:   serial@60200000
Err:   serial@60200000
=> 
```