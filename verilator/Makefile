CFLAGS ?= --std=c++14 -O3
VERILATOR ?= verilator
VERILATOR_FLAGS ?= -threads -O3 -Wall -Wno-fatal -trace -CFLAGS $(CFLAGS) --timescale-override 1ns/1ns

all: Vtestbench_rocketchip

Vtestbench_rocketchip: *.v top.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --cc testbench_rocketchip.v --exe top.cpp
	make -j -C obj_dir -f Vtestbench_rocketchip.mk Vtestbench_rocketchip
	cp obj_dir/Vtestbench_rocketchip .

.PHONY: clean disasm all
clean:
	rm -f Vtestbench_rocketchip
	rm -rf obj_dir
