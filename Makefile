NPROC = 16

GNU_CROSS_COMPILER_PREFIX := loongarch64-linux-gnu-
GNU_CROSS_COMPILER_GCC    := $(GNU_CROSS_COMPILER_PREFIX)gcc
GNU_STRIP := $(GNU_CROSS_COMPILER_PREFIX)strip


MUSL_CROSS_COMPILER_PREFIX := loongarch64-linux-musl-
MUSL_CROSS_COMPILER_GCC    := $(MUSL_CROSS_COMPILER_PREFIX)gcc

RAMDISK := sdcard

# Makefile for build oscomp testsuits on LoongArch platform

all: prepare busybox libc-bench lmbench unixbench interrupts-test libc-test lua netperf iperf rt-tests time-test true copy-file-range-test

prepare:
	mkdir -p $(RAMDISK)


busybox: .PHONY
	cp config/config.gnu.novec busybox/.config
	make -C busybox -j $(NPROC)
	cp busybox/busybox $(RAMDISK)/
	cp scripts/busybox/* $(RAMDISK)/


libc-bench: .PHONY
	make -C libc-bench CC="$(GNU_CROSS_COMPILER_GCC) -static" -j $(NPROC)
	$(GNU_STRIP) libc-bench/libc-bench
	cp libc-bench/libc-bench $(RAMDISK)/libc-bench


lmbench: .PHONY
	make -C lmbench build CC="$(GNU_CROSS_COMPILER_GCC) -static" OS=loongarch64 -j $(NPROC)
	$(GNU_STRIP) lmbench/bin/loongarch64/lmbench_all
	cp lmbench/bin/loongarch64/lmbench_all $(RAMDISK)/
	cp lmbench/bin/loongarch64/hello $(RAMDISK)/
	cp scripts/lmbench/* $(RAMDISK)/


unixbench: .PHONY
	make -C UnixBench CC="$(GNU_CROSS_COMPILER_GCC) -static" ARCH=loongarch64 -j $(NPROC) all
	mkdir -p $(RAMDISK)/unixbench
	cp UnixBench/pgms/* $(RAMDISK)/unixbench
	cp scripts/unixbench/*.sh $(RAMDISK)/unixbench


interrupts-test: .PHONY
	make CC=$(GNU_CROSS_COMPILER_GCC) -C interrupts-test
	$(GNU_STRIP) interrupts-test/interrupts-test-*
	cp interrupts-test/interrupts-test-* $(RAMDISK)/


libc-test: .PHONY
	make -C libc-test disk -j $(NPROC)
	cp -r libc-test/disk/* $(RAMDISK)/
	mv $(RAMDISK)/run-all.sh $(RAMDISK)/libctest_testcode.sh


lua: .PHONY
	make -C lua CC="$(GNU_CROSS_COMPILER_GCC) -static" -j $(NPROC)
	$(GNU_STRIP) lua/src/lua
	mkdir -p $(RAMDISK)/lua
	cp lua/src/lua $(RAMDISK)/lua
	cp scripts/lua/* $(RAMDISK)/lua


netperf: .PHONY
	cd netperf && ./autogen.sh
	cd netperf && ac_cv_func_setpgrp_void=yes ./configure --host loongarch64 CC=$(GNU_CROSS_COMPILER_GCC) CFLAGS="-static"
	cd netperf && make -j $(NPROC)
	cp netperf/src/netperf netperf/src/netserver $(RAMDISK)/
	cp scripts/netperf/* $(RAMDISK)/

iperf: .PHONY
	cd iperf &&	./configure --host=loongarch64-linux CC=$(GNU_CROSS_COMPILER_GCC) --enable-static-bin --without-sctp && make
	cp iperf/src/iperf3 $(RAMDISK)/
	cp scripts/iperf/iperf_testcode.sh $(RAMDISK)/

rt-tests: .PHONY
	make -C rt-tests CC="$(MUSL_CROSS_COMPILER_GCC) -static" cyclictest hackbench
	cp rt-tests/cyclictest rt-tests/hackbench $(RAMDISK)/
	cp scripts/cyclictest/cyclictest_testcode.sh $(RAMDISK)/


time-test: .PHONY
	make CC=$(GNU_CROSS_COMPILER_GCC) -C time-test all
	cp time-test/time-test $(RAMDISK)/


true: .PHONY
	make CC=$(GNU_CROSS_COMPILER_GCC) -C true
	$(GNU_STRIP) true/true
	mkdir -p $(RAMDISK)/bin
	cp true/true $(RAMDISK)/bin/


copy-file-range-test: .PHONY
	make CC=$(GNU_CROSS_COMPILER_GCC) -C $@
	$(GNU_STRIP) $@/$@-*
	cp $@/$@-* $(RAMDISK)/


clean: .PHONY
	rm -rf $(RAMDISK)/
	make -C busybox clean 
	make -C libc-bench clean 
	make -C lmbench clean 
	make -C UnixBench clean 
	make -C interrupts-test clean 
	make -C libc-test clean 
	make -C lua clean 
	make -C netperf clean 
	make -C iperf clean 
	make -C rt-tests clean 
	make -C time-test clean 
	make -C true clean 
	make -C copy-file-range-test clean


.PHONY:

