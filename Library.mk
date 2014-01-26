# Generic makefile for both core and non-core Arduino libraries
# Defined externally: BOARD, LIBRARY, DEPENDENCIES
# To make the core library, use LIBRARY = core
# DEPENDENCIES should be a space separated list of library names.

CC = avr-gcc
CXX = avr-g++

BOARD_C_FLAGS ?= $(shell imp get cflags $(BOARD))
C_FLAGS = $(BOARD_C_FLAGS) -Os -w -ffunction-sections -fdata-sections

SRC_DIRS ?= $(shell imp get src $(LIBRARY) $(DEPENDENCIES) --board $(BOARD))
INCLUDES ?= $(shell imp get src $(LIBRARY) $(DEPENDENCIES) -I --board $(BOARD))

VPATH = $(SRC_DIRS)

LIBOBJS ?= $(shell imp get obj $(LIBRARY))

# Use the lowercased library name for the archive
LIBARCHIVE ?= lib$(shell echo $(LIBRARY) | tr '[:upper:]' '[:lower:]').a

$(LIBARCHIVE): $(LIBOBJS)
	@echo Creating $(LIBARCHIVE) archive.
	@avr-ar rcs $@ $^

%.o: %.cpp
	@echo Compiling $@
	@$(CXX) $(C_FLAGS) -c -o $@ $< $(INCLUDES)

%.o: %.c
	@echo Compiling $@
	@$(CC) $(C_FLAGS) -c -o $@ $< $(INCLUDES)
