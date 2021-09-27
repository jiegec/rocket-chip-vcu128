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