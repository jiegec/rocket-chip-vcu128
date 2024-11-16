JOBS = 16
TOP_MODULE_PROJECT ?= vcu128
TOP_MODULE ?= RocketChip
CONFIG ?= RocketConfig

BASE_DIR = $(abspath .)
BUILD = $(BASE_DIR)/build
SRC = $(BASE_DIR)/src

SHELL := /bin/bash

MILL ?= mill

all: $(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).sv

LOOKUP_SCALA_SRCS = $(shell find $(1)/. -iname "*.scala" 2> /dev/null)
BOOTROM := $(shell find bootrom -iname "*.img" 2> /dev/null)

$(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).fir: $(call LOOKUP_SCALA_SRCS,$(SRC)) $(BOOTROM)
	mkdir -p $(@D)
	rm -f $(BUILD)/RocketChip.anno.json $(BUILD)/RocketChip.fir
	$(MILL) vcu128.runMain freechips.rocketchip.diplomacy.Main --dir $(BUILD) --top $(TOP_MODULE_PROJECT).$(TOP_MODULE) --config $(TOP_MODULE_PROJECT).$(CONFIG)
	mv $(BUILD)/RocketChip.fir $@

$(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).sv: $(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).fir
# scala firrtl compiler
# $(MILL) vcu128.runMain firrtl.stage.FirrtlMain --emission-options disableMemRandomization,disableRegisterRandomization -i $< -o $@ -X verilog
# vivado cannot infer sram in dcache
# firtool --disable-all-randomization $< -o $@
	firtool --lower-memories --disable-all-randomization $< -o $@

clean:
	rm -rf build/*

.PHONY:  all clean
