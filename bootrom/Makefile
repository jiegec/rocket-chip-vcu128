bootrom_img = bootrom.rv64.img bootrom.rv32.img
bootrom_dump = bootrom.rv64.dump bootrom.rv32.dump

GCC=riscv64-unknown-elf-gcc
CFLAGS_RV64=-mabi=lp64 -march=rv64ima
CFLAGS_RV32=-mabi=ilp32 -march=rv32ima
CFLAGS=-g
OBJCOPY=riscv64-unknown-elf-objcopy
OBJDUMP=riscv64-unknown-elf-objdump

img: $(bootrom_img)

dump: $(bootrom_dump)

%.img: %.elf
	$(OBJCOPY) -O binary --change-addresses=-0x10000 $< $@

%.rv32.elf: %.S bootloader.c linker.ld
	$(GCC) $(CFLAGS_RV32) $(CFLAGS) -Tlinker.ld $^ -nostdlib -ffreestanding -static -o $@

%.rv64.elf: %.S bootloader.c linker.ld
	$(GCC) $(CFLAGS_RV64) $(CFLAGS) -Tlinker.ld $^ -nostdlib -ffreestanding -static -o $@

%.dump: %.elf
	$(OBJDUMP) -D $< -j .text.start -j .text.hang -j .text -j .srodata -j .rodata -j .sdata > $@

clean:
	rm -f *.elf *.dump *.img
