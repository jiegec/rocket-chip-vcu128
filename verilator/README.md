# Simulation

You can simulate the dual core system in verilator:

```shell
# generate verilog for simulation
make -C .. CONFIG=SimConfig
# compile simulator
make
# boot to uboot
./Vtestbench_rocketchip ~/opensbi/build/platform/rocket-chip-vcu128-dual-core/firmware/fw_payload.bin 2>/dev/null
# boot to uboot & linux
# you need to run `bootm 0x80100000` in u-boot shell
./Vtestbench_rocketchip ~/opensbi/build/platform/rocket-chip-vcu128-dual-core/firmware/fw_payload.bin ~/linux/arch/riscv/boot/image-dual-core.itb 2>/dev/null
```
