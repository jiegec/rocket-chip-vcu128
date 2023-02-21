#define DRAM_TOP 0x80800000
#define DRAM_BASE 0x80000000

.section .text.start, "ax", @progbits
.globl _start
_start:
  csrwi 0x7c1, 0 // disable chicken bits
  li sp, DRAM_TOP
  la s0, bootloader
  csrr a0, mhartid
  bnez a0, boot_other_hart

  la a1, _dtb
  jr s0

.section .text.hang, "ax", @progbits
.globl _hang
_hang:
  csrwi 0x7c1, 0 // disable chicken bits
  csrr a0, mhartid
  la a1, _dtb
  csrwi mie, 0
1:
  wfi
  j 1b

boot_other_hart:
  la s0, trap
  csrw mtvec, s0
  // enable m-mode software interrupt
  csrsi mie, 0x8
  // enable m-mode interrupt
  csrsi mstatus, 0x8
  j 1b

  .p2align 2
trap:
  csrr a0, mhartid
  li s0, DRAM_BASE
  jr s0


.section .rodata.dtb, "a", @progbits
.globl _dtb
.align 5, 0
_dtb:
.ascii "DTB goes here"
