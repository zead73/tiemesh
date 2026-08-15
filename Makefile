# Makefile for tiemesh — a terminal Meshtastic client in Free Pascal.
#
# Common targets:
#   make            build the native binary AND the Windows .exe (the repo
#                   ships both, so this keeps them in sync)
#   make linux      build only the native binary            -> ./tiemesh
#   make windows    build only the Windows binary (-Twin64) -> ./tiemesh.exe
#   make ble        native BLE build (-dMESH_BLE)            -> ./tiemesh-ble
#   make run        build native, then run it (pass args:  make run ARGS="--serial /dev/ttyACM0")
#   make clean      remove build artefacts (*.o *.ppu, the binaries, keytest)
#   make help       list these targets
#
# The Windows build needs the win64 RTL units installed once from the FPC
# sources (see README, "Cross-compiling for Windows from Linux"); no MinGW is
# required. Override the compiler or add flags from the environment, e.g.:
#   make FPC=/opt/fpc/bin/fpc FPCFLAGS=-O3

FPC      ?= fpc
FPCFLAGS ?=

MAIN     := tiemesh.pas
UNITS    := meshproto.pas meshtransport.pas meshclient.pas
BLEUNIT  := meshble.pas

LINUX    := tiemesh
WINDOWS  := tiemesh.exe
BLEBIN   := tiemesh-ble

.PHONY: all linux windows ble run clean help
.DEFAULT_GOAL := all

all: linux windows

linux: $(LINUX)

$(LINUX): $(MAIN) $(UNITS)
	$(FPC) $(FPCFLAGS) $(MAIN)

windows: $(WINDOWS)

# Each full fpc invocation recompiles the units for its own target, so the
# native and win64 builds can share this directory without clobbering each
# other (fpc will not reuse a .ppu compiled for a different target).
$(WINDOWS): $(MAIN) $(UNITS)
	$(FPC) -Twin64 $(FPCFLAGS) $(MAIN)

# Built as a distinct binary (tiemesh-ble) so it never collides with the plain
# native build: both would otherwise be named "tiemesh", and make's timestamp
# check would skip rebuilding one after the other.
ble: $(BLEBIN)

$(BLEBIN): $(MAIN) $(UNITS) $(BLEUNIT)
	$(FPC) -dMESH_BLE $(FPCFLAGS) -o$(BLEBIN) $(MAIN)

run: linux
	./$(LINUX) $(ARGS)

clean:
	rm -f -- *.o *.ppu *.a $(LINUX) $(WINDOWS) $(BLEBIN) keytest

help:
	@echo 'targets: all (default), linux, windows, ble, run, clean, help'
	@echo '  make run ARGS="--serial /dev/ttyACM0"'
