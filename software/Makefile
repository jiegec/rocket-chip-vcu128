GCC=riscv64-unknown-elf-gcc
OBJCOPY=riscv64-unknown-elf-objcopy

all: img

img: uart.img

%.img: %.elf
	$(OBJCOPY) -O binary --change-addresses=-0x80200000 $< $@

%.elf: %.c linker.ld
	$(GCC) -mcmodel=medany -mabi=lp64 -march=rv64ima -Tlinker.ld init.S $^ -nostdlib -ffreestanding -static -o $@