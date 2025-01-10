SRC_DIR = src
BIN=bin
DEVELOPER_LIB="$(BIN)/Toolchains/XcodeDefault.xctoolchain/usr/lib"
THIRD_PARTY=../3rd-party

LIBINJ = ../libinj/injector.c

FISH = fishhook/fishhook.c
FISH := $(FISH:%=$(THIRD_PARTY)/%)

DYLIB_SRCS = kextd.m patch.m symbols.m
DYLIB_HDRS = patch.h
SRCS = exploit.m rootless.m kickstart.m 
HDRS = exploit.h
SWIFT_SRC = taylor.swift

DYLIB_SRCS := $(DYLIB_SRCS:%=$(SRC_DIR)/%)
DYLIB_HDRS := $(DYLIB_HDRS:%=$(SRC_DIR)/%)

SRCS := $(SRCS:%=$(SRC_DIR)/%)
HDRS := $(HDRS:%=$(SRC_DIR)/%)
SWIFT_SRC := $(SWIFT_SRC:%=$(SRC_DIR)/%)

CC := clang
LDFLAGS := -g -mmacosx-version-min=10.13
CFLAGS := -g -mmacosx-version-min=10.13 -I$(THIRD_PARTY) -I../libinj

.PHONY: all

all: prepare demangle launcher blankspace misc
dylib: prepare demangle
exp: prepare launcher

misc: prepare jail.sb
	cp jail.sb bin/
	cp fruit/symbols bin/

launcher: $(SRCS) $(HDRS)
	$(CC) $(SRCS) $(CFLAGS) \
		-framework Foundation \
		-o $(BIN)/exp
run: all
	$(BIN)/exp

demangle: $(DYLIB_SRCS) $(DYLIB_HDRS)
	$(CC) $(DYLIB_SRCS) $(CFLAGS) $(FISH) $(LIBINJ) \
		-dynamiclib -framework Foundation \
		-o $(DEVELOPER_LIB)/libswiftDemangle.dylib

clean:
	rm -rf $(BIN)/*

format:
	clang-format -i $(DYLIB_SRCS) $(SRCS)

prepare:
	@mkdir -p $(BIN) $(OBJ) $(DEVELOPER_LIB)

blankspace: prepare
	swiftc -static-stdlib -o $(BIN)/taytay $(SWIFT_SRC)