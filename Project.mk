# Makefile template for Arduino projects
CC = avr-gcc
CXX = avr-g++

PROJECT = {PROJECT}
BOARD = {BOARD}
LIBRARIES = # List of libraries to use (case sensitive)

BOARD_C_FLAGS ?= $(shell imp get cflags $(BOARD))
BOARD_MCU ?= $(shell imp get property $(BOARD).build.mcu)
DEFAULT_C_FLAGS = -Os -w -ffunction-sections -fdata-sections
CFLAGS = $(BOARD_C_FLAGS) $(DEFAULT_C_FLAGS)
LINK_FLAGS = -mmcu=$(BOARD_MCU) -Wl,--gc-sections

SRC_DIRS ?= $(shell imp get src $(LIBRARIES) --board $(BOARD))
HEADER_INCLUDES ?= $(shell imp get src $(LIBRARIES) --board $(BOARD) -I)
LIB_INCLUDES ?= $(shell imp get lib $(LIBRARIES) --board $(BOARD) -L -l)

# Add the header folders to the virtual path
VPATH = $(SRC_DIRS)

# Board details for uploading
UPLOAD_BAUD ?= $(shell imp get property $(BOARD).upload.speed)
UPLOAD_PROTOCOL ?= $(shell imp get property $(BOARD).upload.protocol)
USB_DEVICE = /dev/ttyUSB0

# List your object files here
OBJECTS = $(PROJECT).o

$(PROJECT).hex: $(PROJECT).elf
	@echo Making $@
	@avr-objcopy -O ihex $< $@

$(PROJECT).elf: $(OBJECTS)
	@echo Linking $@
	@$(CC) $(LINK_FLAGS) -o $@ $^ $(LIB_INCLUDES)

upload: $(PROJECT).hex
	@avrdude -c $(UPLOAD_PROTOCOL) -p $(BOARD_MCU) \
	-b $(UPLOAD_BAUD) -U flash:w:$< -P$(USB_DEVICE)

serial:
	picocom $(USB_DEVICE)

%.o: %.ino
	@echo Compiling $@
	@$(CXX) -x c++ $(CFLAGS) -c -o $@ $< $(HEADER_INCLUDES)

%.o: %.cpp
	@echo Compiling $@
	@$(CXX) $(CFLAGS) -c -o $@ $< $(HEADER_INCLUDES)

%.o: %.c
	@echo Compiling $@
	@$(CC) $(CFLAGS) -c -o $@ $< $(HEADER_INCLUDES)

clean:
	rm -f *.o *.hex *.elf
