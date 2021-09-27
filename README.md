# rocket-chip-vcu128

Port Rocket Chip to VCU128 platform. Based on [rocket2thinpad](https://github.com/jiegec/rocket2thinpad).

Memory mapping:

1. AXI Quad SPI XIP: 0x6000_0000
2. AXI Quad SPI Ctrl: 0x6010_0000
3. AXI UART16550: 0x6020_0000
4. HBM: 0x1_0000_0000 ~ 0x1_FFFF_FFFF