bootrom_img = bootrom.img

GCC=riscv64-unknown-elf-gcc
OBJCOPY=riscv64-unknown-elf-objcopy

all: $(bootrom_img)

%.img: %.elf
	$(OBJCOPY) -O binary $< $@

%.elf: %.S bootloader.c linker.ld
	$(GCC) -Tlinker.ld $< bootloader.c -ffreestanding -nostdlib -static -Wl,--no-gc-sections -o $@
