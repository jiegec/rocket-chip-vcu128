#define DRAM_TOP 0x88000000

.section .text.start, "ax", @progbits
.globl _start
_start:
  li sp, DRAM_TOP // setup stack
  jal main

_hang:
  j _hang