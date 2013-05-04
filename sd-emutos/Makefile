# Makefile for the EmuTOS to BaS_gcc SD-card "driver connector"
#
# The driver actually resides within BaS_gcc. All we need to do within the AUTO-folder program is to find the driver
# entry point and put its address into the respective cookie

TOOLCHAIN_PREFIX=m68k-atari-mint-
CC=$(TOOLCHAIN_PREFIX)gcc

CFLAGS=-mcpu=68030 \
	-Os \
	-fomit-frame-pointer \
	-g \
	-Wno-multichar\
	-Wall
EMUSD=emusd
APP=$(EMUSD).prg

all: $(APP)

SOURCES=$(EMUSD).c \
		cookie.c \
		xhdi.c
		
OBJECTS=$(SOURCES:.c=.o)

$(APP): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(APP)

test: xhdi_test.c
	$(CC) $(CFLAGS)	-Wl,-traditional-format xhdi_test.c -o xhditest.prg
		
.PHONY clean:
	- rm -rf *.o xhditest.prg