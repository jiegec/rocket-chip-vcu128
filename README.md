# rocket-chip-vcu128

Port Rocket Chip to VCU128 platform. Based on [rocket2thinpad](https://github.com/jiegec/rocket2thinpad). Tested with Vivado 2020.2.

CAVEAT: You can use either BOOM Core or Rocket Core. Change configuration at `src/main/scala/Configs.scala` before building.

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

External interrupt:

1. AXI UART16550
2. AXI Quad SPI
3. AXI Ethernet
4. AXI Ethernet DMA RX
5. AXI Ethernet DMA TX
6. AXI I2C

Access uart from USB at /dev/ttyUSB2, baudrate 115200. A virtual reset is available at VIO.

Software modifications:

- [Custom OpenSBI](https://github.com/jiegec/opensbi/tree/rocket-chip-vcu128) [Changes](https://github.com/jiegec/opensbi/compare/master...jiegec:opensbi:rocket-chip-vcu128?expand=1)
- [Custom U-Boot](https://github.com/jiegec/u-boot/tree/rocket-chip-vcu128) [Changes](https://github.com/jiegec/u-boot/compare/master...jiegec:u-boot:rocket-chip-vcu128?expand=1)
- [Custom Linux](https://github.com/jiegec/linux/tree/rocket-chip-vcu128) [Changes](https://github.com/jiegec/linux/compare/master...jiegec:linux:rocket-chip-vcu128?expand=1)
- [Custom Buildroot](https://github.com/jiegec/buildroot/tree/rocket-chip-vcu128)
- [Custom Buildroot External](https://github.com/jiegec/buildroot-external/tree/master/rocket-chip-vcu128)

Boot custom OpenSBI in M-mode with custom U-Boot in S-mode:

```shell
# place custom opensbi at ~/opensbi, custom uboot at ~/u-boot
# in u-boot
$ ./build.sh
# in this repo
$ python3 boot.py ~/opensbi/build/platform/rocket-chip-vcu128-dual-core/firmware/fw_payload.bin /dev/ttyUSB2
Boot HART ID              : 1
Boot HART Domain          : root
Boot HART Priv Version    : v1.11
Boot HART Base ISA        : rv64imafdcx
Boot HART ISA Extensions  : sdtrig
Boot HART PMP Count       : 8
Boot HART PMP Granularity : 2 bits
Boot HART PMP Address Bits: 30
Boot HART MHPM Info       : 0 (0x00000000)
Boot HART Debug Triggers  : 1 triggers
Boot HART MIDELEG         : 0x0000000000000222
Boot HART MEDELEG         : 0x000000000000b109


U-Boot 2024.10-g33523922a4ac (Nov 16 2024 - 11:29:29 +0800)

CPU:   sifive,rocket0
Model: freechips,rocketchip-unknown
DRAM:  512 MiB
Core:  16 devices, 12 uclasses, devicetree: board
Loading Environment from nowhere... OK
In:    serial@60200000
Out:   serial@60200000
Err:   serial@60200000
Net:   AXI EMAC: 60400000, phyaddr 3, interface sgmii
eth0: eth0@60400000
=>
```

Run bare-metal executable from TFTP:

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

Boot custom Linux with custom [Buildroot external repo](https://github.com/jiegec/buildroot-external/tree/master/rocket-chip-vcu128):

```shell
# in buildroot-external
$ cd rocket-chip-vcu128
$ ./build.sh
# in linux
$ ./build.sh
# in this repo
$ python3 boot.py ~/opensbi/build/platform/rocket-chip-vcu128-dual-core/firmware/fw_payload.bin /dev/ttyUSB2
=> run boot_dual
Using eth0@60400000 device
TFTP from server 10.0.0.1; our IP address is 10.0.0.2
Filename 'image.itb'.
Load address: 0x80100000
[    1.757872] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.778840] printk: console [ttyS0] disabled
[    1.782014] 60200000.serial: ttyS0 at MMIO 0x60201000 (irq = 1, base_baud = 6250000) is a 16550A
[    1.787402] printk: console [ttyS0] enabled
[    1.787402] printk: console [ttyS0] enabled
[    1.792138] printk: bootconsole [sbi0] disabled
[    1.792138] printk: bootconsole [sbi0] disabled

[    1.847546] Freeing unused kernel image (initmem) memory: 2116K
[    1.851446] Run /init as init process
Starting syslogd: OK
Starting klogd: OK
Running sysctl: OK

Welcome to Buildroot
buildroot login: root
Jan  1 00:00:28 login[82]: root login on 'ttyS0'
```

Launch OpenOCD & GDB for debugging:

```shell
$ openocd -f openocd.cfg
Open On-Chip Debugger 0.12.0
Licensed under GNU GPL v2
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
1
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : clock speed 10000 kHz
Info : JTAG tap: riscv.cpu tap/device found: 0x10000913 (mfg: 0x489 (SiFive Inc), part: 0x0000, ver: 0x1)
Info : datacount=2 progbufsize=16
Info : Disabling abstract command reads from CSRs.
Info : Examined RISC-V core; found 2 harts
Info :  hart 0: XLEN=64, misa=0x800000000094112d
Info : starting gdb server for riscv.cpu.0 on 3333
Info : Listening on port 3333 for gdb connections
$ riscv64-unknown-elf-gdb
GNU gdb (GDB) 12.0.50.20220308-git
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "--host=x86_64-pc-linux-gnu --target=riscv64-unknown-elf".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word".
(gdb) target extended-remote localhost:3333
Remote debugging using localhost:3333
warning: No executable has been specified and target does not support
determining executable automatically.  Try using the "file" command.
0x0000000000010106 in ?? ()
(gdb) 
```

Boot process:

1. Run BootROM in 0x10000, load opensbi+uboot from serial
2. Run OpenSBI @ 0x80000000, jump to U-Boot at 0x80040000
3. U-Boot relocates to high address, load Linux kernel + dts from network at 0x80100000
4. Copy Linux kernel to 0x82000000 and jump to Linux kernel

Performance of one big Rocket Chip running Linux @ 50MHz:

- Dhrystone(-O2): 122850.1 per second, `122850.1 / 1757 / 50 = 1.40 DMIPS/MHz`
- Coremark(-O2): 104.2 per second, `104.2 / 50 = 2.08 Coremark/MHz`
- Whetstone: 33.3 MIPS

Performance of one medium BOOM core running Linux @ 50MHz:

- Dhrystone(-O2): 197238.7 per second, `197238.7 / 1757 / 50 = 2.25 DMIPS/MHz`
- Coremark(-O2): 171.0 per second, `171.0 / 50 = 3.42 Coremark/MHz`
- Whetstone: 50.0/100.0 MIPS
