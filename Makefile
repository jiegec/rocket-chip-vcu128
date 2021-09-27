JOBS = 16
TOP_MODULE_PROJECT ?= vcu128
TOP_MODULE ?= RocketChip
CONFIG ?= RocketConfig

BASE_DIR = $(abspath .)
BUILD = $(BASE_DIR)/build
SRC = $(BASE_DIR)/src

SHELL := /bin/bash

SBT ?= sbt

all: $(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).v

CHISEL_ARGS := $(BUILD)

LOOKUP_SCALA_SRCS = $(shell find $(1)/. -iname "*.scala" 2> /dev/null)
BOOTROM := $(shell find bootrom -iname "*.img" 2> /dev/null)

$(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).fir: $(call LOOKUP_SCALA_SRCS,$(SRC)) $(BOOTROM)
	mkdir -p $(@D)
	$(SBT) "runMain freechips.rocketchip.system.Generator $(CHISEL_ARGS) $(TOP_MODULE_PROJECT) $(TOP_MODULE) $(TOP_MODULE_PROJECT) $(CONFIG)"

$(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).v: $(BUILD)/$(TOP_MODULE_PROJECT).$(CONFIG).fir
	$(SBT) "runMain firrtl.stage.FirrtlMain -i $< -o $@ -X verilog"
	cp $@ $@.bak
	cp prologue.v $@
	sed 's/wire \[..:0\] coreMonitorBundle/(* mark_debug="true" *) \0/g' $@.bak >> $@

clean:
	rm -rf build/*

.PHONY:  all clean
