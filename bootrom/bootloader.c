#include <stdint.h>
#include <stdlib.h>

const size_t UART_BASE = 0x60600000;
volatile uint8_t *UART_RBR = (uint8_t *)(UART_BASE + 0x1000);
volatile uint8_t *UART_THR = (uint8_t *)(UART_BASE + 0x1000);
volatile uint8_t *UART_DLL = (uint8_t *)(UART_BASE + 0x1000); // LCR(7)=1
volatile uint8_t *UART_IER = (uint8_t *)(UART_BASE + 0x1004);
volatile uint8_t *UART_DLM = (uint8_t *)(UART_BASE + 0x1004); // LCR(7)=1
volatile uint8_t *UART_FCR = (uint8_t *)(UART_BASE + 0x1008);
volatile uint8_t *UART_LCR = (uint8_t *)(UART_BASE + 0x100C);
volatile uint8_t *UART_MCR = (uint8_t *)(UART_BASE + 0x1010);
volatile uint8_t *UART_LSR = (uint8_t *)(UART_BASE + 0x1014);

void init_serial() { 
  // Enable 8 bytes FIFO
  *UART_FCR = 0x81;
  // LCR(7) = 1
  *UART_LCR = 0x80;
  // 115200: 50M / 16 / 115200 = 27
  *UART_DLL = 27;
  *UART_DLM = 0;
  // LCR(7) = 0, 8N1
  *UART_LCR = ~0x80 & 0x03;
  *UART_MCR = 0;
  *UART_IER = 0;
}

void putc(char ch) {
  while (!(*UART_LSR & 0x40))
    ;
  *UART_THR = ch;
}

uint8_t getc() {
  while (!(*UART_LSR & 0x1))
    ;
  return *UART_RBR;
}

uint32_t getlen() {
  uint32_t len = 0;
  len |= getc();
  len = len << 8;
  len |= getc();
  len = len << 8;
  len |= getc();
  len = len << 8;
  len |= getc();
  return len;
}

void puts(char *s) {
  while (*s) {
    putc(*s++);
  }
}

void puthex(uint32_t num) {
  int i, temp;
  for (i = 7; i >= 0; i--) {
    temp = (num >> (i * 4)) & 0xF;
    if (temp <= 10) {
      putc('0' + temp);
    } else if (temp < 16) {
      putc('A' + temp - 10);
    } else {
      putc('.');
    }
  }
}

void bootloader() {
  init_serial();
  puts("NO BOOT FAIL\r\n");
  uint32_t len = getlen();
  puts("LEN ");
  puthex(len);
  puts("\r\n");
  volatile uint8_t *MEM = (uint8_t *)0x80000000;
  for (uint32_t i = 0; i < len; i++) {
    *MEM = getc();
    MEM++;
  }
  puts("BOOT\r\n");
  void (*boot)() = (void(*)())0x80000000;
  boot();
}

void halt(uint32_t epc) {
  puts("HALT ");
  puthex(epc);
}
