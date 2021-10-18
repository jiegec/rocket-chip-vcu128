# rocket-chip-vcu128

Port Rocket Chip to VCU128 platform. Based on [rocket2thinpad](https://github.com/jiegec/rocket2thinpad).

AXI Interconnect memory mapping:

1. AXI Quad SPI: 0x6010_0000
2. AXI UART16550: 0x6020_0000
3. AXI Ethernet DMA: 0x6030_0000
4. AXI Ethernet: 0x6040_0000
5. AXI I2C: 0x6050_0000
6. HBM: 0x8000_0000 ~ 0x9FFF_FFFF

Rocket Chip memory mapping:

1. Boot ROM: 0x0001_0000
2. CLINT: 0x0200_0000
3. MMIO: 0x6000_0000 ~ 0x7FFF_FFFF
4. Memory: 0x8000_0000 ~ 0xFFFF_FFFF

Access uart from USB at /dev/ttyUSB1, baudrate 115200. A virtual reset is available at VIO.

Boot [Custom OpenSBI](https://github.com/jiegec/opensbi/tree/rocket-chip-vcu128):

```shell
# in opensbi
$ make CROSS_COMPILE=riscv64-linux-gnu- -j4 PLATFORM=rocket-chip-vcu128
# in this repo
$ python3 bootrom/boot.py ~/opensbi/build/platform/rocket-chip-vcu128/firmware/fw_jump.bin /dev/ttyUSB1
Firmware Base             : 0x80000000
Firmware Size             : 68 KB
Runtime SBI Version       : 0.2

Boot HART ID              : 0
Boot HART Domain          : root
Boot HART ISA             : rv64imafdcsux
Boot HART Features        : scounteren,mcounteren
```

Boot [Custom U-Boot](https://github.com/jiegec/u-boot/tree/rocket-chip-vcu128) in M-mode:

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
Net:   AXI EMAC: 60400000, phyaddr 3, interface sgmii
eth0: eth0@60400000
=> 
```

Boot custom OpenSBI in M-mode with U-Boot in S-mode:

```shell
# in u-boot
$ make rocket-chip-vcu128-smode_defconfig
$ make CROSS_COMPILE=riscv64-linux-gnu- -j4
# in opensbi
$ make CROSS_COMPILE=riscv64-linux-gnu- -j4 PLATFORM=rocket-chip-vcu128 FW_PAYLOAD_PATH=$HOME/u-boot/u-boot.bin all
# in this repo
$ python3 boot.py ~/opensbi/build/platform/rocket-chip-vcu128/firmware/fw_payload.bin /dev/ttyUSB1
# same as above
```

Run executable from TFTP:

```shell
# build and launch tftp server
$ sudo pip3 install -U py3tftp
$ cd software
$ make
$ sudo python3 -m py3tftp -p 69
# in u-boot
=> tftpboot 0x80200000 10.0.0.1:uart.img
Using eth0@60400000 device
TFTP from server 10.0.0.1; our IP address is 10.0.0.2
Filename 'uart.img'.
Load address: 0x80200000
Loading: #
         929.7 KiB/s
done
Bytes transferred = 952 (3b8 hex)
=> go 0x80200000
## Starting application at 0x80200000 ...
test
```

Run custom [Linux](https://github.com/jiegec/linux/tree/rocket-chip-vcu128):

```shell
# in Linux
# build arch/riscv/boot/image.itb
$ ./build.sh
# launch tftp server in arch/riscv/boot
$ cd arch/riscv/boot
$ sudo python3 -m py3tftp -p 69
# in U-Boot
# build opensbi with u-boot.bin payload
$ ./build_smode.sh
# in this repo
$ python3 boot.py ~/opensbi/build/platform/rocket-chip-vcu128/firmware/fw_payload.bin /dev/ttyUSB1
# in U-Boot shell
=> tftpboot 0x82000000 10.0.0.1:image.itb
Using eth0@60400000 device
TFTP from server 10.0.0.1; our IP address is 10.0.0.2
Filename 'image.itb'.
Load address: 0x82000000
=> bootm 0x82000000
## Loading kernel from FIT Image at 82000000 ...
   Using 'conf' configuration
[    0.334581] Run /sbin/init as init process
[    0.339225] Run /etc/init as init process
[    0.343753] Run /bin/init as init process
[    0.348635] Run /bin/sh as init process
[    0.353252] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
[    0.361108] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.14.0-00002-gbdc6f5f9d850-dirty #39
[    0.365621] Hardware name: freechips,rocket-chip-vcu128 (DT)
[    0.368620] Call Trace:
[    0.369994] [<ffffffff80002d46>] dump_backtrace+0x1c/0x24
[    0.372992] [<ffffffff8011d0c2>] dump_stack_lvl+0x34/0x48
[    0.375968] [<ffffffff8011d0ea>] dump_stack+0x14/0x1c
[    0.378738] [<ffffffff8011b1e6>] panic+0xee/0x264
[    0.381320] [<ffffffff8011d59e>] kernel_init+0xe8/0xf4
[    0.384192] [<ffffffff80001814>] ret_from_exception+0x0/0xc
[    0.387351] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance. ]---
```