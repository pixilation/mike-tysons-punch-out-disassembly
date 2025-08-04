red=$(shell tput setaf 1)
green=$(shell tput setaf 2)
magenta=$(shell tput setaf 6)
reset=$(shell tput sgr0)

AS65 ?= ca65
LD65 ?= ld65
CFLAGS65 ?= -g
LDFLAGS65 ?=

MD5 ?= $(CURDIR)/helper_programs/md5sum

# Define the source and output directories
SRC_DIR := source_files
OUT_DIR := output_files
OBJ_DIR := output_files/obj
ORIG_DIR := original_files

# Dependencies that affect all other source files
INCLUDES := $(SRC_DIR)/Mike_Tysons_Punchout_Defines.asm

# Find assembly source files for all PRG Banks
PRG_SOURCES := $(wildcard $(SRC_DIR)/PRG_Bank*.asm)

# Generate corresponding output file names
PRG_NAMES := $(patsubst $(SRC_DIR)/%.asm,%,$(PRG_SOURCES))
OBJ_NAMES := $(PRG_NAMES)
OBJS := $(patsubst %,$(OBJ_DIR)/%.o,$(OBJ_NAMES))
BIN_FILES := $(patsubst %,$(OUT_DIR)/%.bin,$(OBJ_NAMES))
ORIG_FILES := $(patsubst %,$(ORIG_DIR)/%.bin,$(OBJ_NAMES))

ROM := $(OUT_DIR)/mtpo.nes
DBG := $(OUT_DIR)/mtpo.dbg
MAP := $(OUT_DIR)/mtpo-map.txt
ROM_CFG := $(SRC_DIR)/mtpo-unrom.cfg
BIN_CFG := $(SRC_DIR)/mtpo-bin.cfg

# Default target
all: rom

rom: $(ROM)
obj: $(OBJS)
prg: $(BIN_FILES)

# Rule to generate .o files from .asm files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm $(INCLUDES) $(SRC_DIR)/main.asm
	@mkdir -p $(OBJ_DIR)
	@echo "${magenta}Assembling $<${reset}"
	@$(AS65) $(CFLAGS65) $< -o $@

# Rule to generate .bin files from .o files
$(BIN_FILES): $(BIN_CFG) $(OBJS)
	@mkdir -p $(OUT_DIR)
	@echo "${magenta}Linking $@${reset}"
	@$(LD65) -o $(OUT_DIR)/PRG -m $(OUT_DIR)/map.txt -C $^

# Rule to generate .nes file from .o files
$(ROM): $(ROM_CFG) $(OBJS) $(OBJ_DIR)/main.o
	@$(LD65) -o $@ --dbgfile $(DBG) -m $(MAP) -C $^

# One-time computation of reference checksums
$(OUT_DIR)/checksums.md5: $(ORIG_FILES)
	@mkdir -p $(OUT_DIR)
	@echo "${magenta}Computing reference checksums...${reset}"
	@(cd $(ORIG_DIR); $(MD5) PRG_Bank*.bin) > $@

# Check the assembled binaries against the reference checksums
check: $(OUT_DIR)/checksums.md5 $(BIN_FILES)
	@echo "${magenta}Verifying checksums of PRG banks...${reset}"
	@(cd $(dir $<); $(MD5) -c $(notdir $<)) 2>&1 |\
	  sed -E 's/(.*OK)/${green}\1${reset}/;s/(.*FAILED)/${red}\1${reset}/'


clean:
	@$(RM) -r $(OUT_DIR) $(ORIG_DIR)/mtpo.nes

.PHONY: all clean check rom obj
