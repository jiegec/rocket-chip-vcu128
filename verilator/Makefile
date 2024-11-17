CFLAGS ?= --std=c++14 -O3
GMP_CFLAGS = $(shell pkg-config --cflags gmp)
GMP_LDFLAGS = $(shell pkg-config --libs gmp)
GMPXX_CFLAGS = $(shell pkg-config --cflags gmpxx)
GMPXX_LDFLAGS = $(shell pkg-config --libs gmpxx)
NCURSES_CFLAGS = $(shell pkg-config --cflags ncurses)
NCURSES_LDFLAGS = $(shell pkg-config --libs ncurses)
VERILATOR ?= verilator
VERILATOR_FLAGS ?= -threads 4 -O3 -Wall -Wno-fatal -trace -CFLAGS "$(CFLAGS) $(GMP_CFLAGS) $(GMPXX_CFLAGS) $(NCURSES_CFLAGS)" -LDFLAGS "$(GMP_LDFLAGS) $(GMP_LDFLAGS) $(NCURSES_LDFLAGS)" --timescale-override 1ns/1ns

all: Vtestbench_rocketchip

Vtestbench_rocketchip: *.v top.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --cc testbench_rocketchip.v --exe top.cpp
	make -j -C obj_dir -f Vtestbench_rocketchip.mk Vtestbench_rocketchip
	cp obj_dir/Vtestbench_rocketchip .

.PHONY: clean disasm all
clean:
	rm -f Vtestbench_rocketchip
	rm -rf obj_dir
