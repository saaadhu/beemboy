PRJ_PATH=./

# Target device flash memory details (used by the avr32program programming
# tool: [cfi|internal]@address
FLASH = internal@0x80000000

# Clock source to use when programming; xtal, extclk or int
PROG_CLOCK = int

PART=uc3a0512

# Application target name. Given with suffix .a for library and .elf for a
# standalone application.
TARGET = beemboy.elf

# List of C source files.
CSRCS = \
	   main.c \
	   intc.c \
       freertos-7.0.0/source/croutine.c \
       freertos-7.0.0/source/list.c   \
       freertos-7.0.0/source/portable/gcc/avr32_uc3/port.c \
       freertos-7.0.0/source/portable/memmang/heap_3.c \
       freertos-7.0.0/source/queue.c  \
       freertos-7.0.0/source/tasks.c  \
       freertos-7.0.0/source/timers.c

# List of assembler source files.
ASSRCS = \
       freertos-7.0.0/source/portable/gcc/avr32_uc3/exception.S

# List of include paths.
INC_PATH = \
	   $(PRJ_PATH) \
	   $(PRJ_PATH)/avr32 \
       freertos-7.0.0/source/include  \
       freertos-7.0.0/source/portable/gcc/avr32_uc3 \

# Additional search paths for libraries.
LIB_PATH = 

# List of libraries to use during linking.
LIBS = 

# Path relative to top level directory pointing to a linker script.
LINKER_SCRIPT = ./link_uc3a0512.lds

# Additional options for debugging. By default the common Makefile.in will
# add -g3.
DBGFLAGS = 

# Application optimization used during compilation and linking:
# -O0, -O1, -O2, -O3 or -Os
OPTIMIZATION = -O0

# Extra flags to use when archiving.
ARFLAGS = 

# Extra flags to use when assembling.
ASFLAGS = 

# Extra flags to use when compiling.
CFLAGS = 

# Extra flags to use when preprocessing.
#
# Preprocessor symbol definitions
#   To add a definition use the format "-D name[=definition]".
#   To cancel a definition use the format "-U name".
#
# The most relevant symbols to define for the preprocessor are:
#   BOARD      Target board in use, see boards/board.h for a list.
#   EXT_BOARD  Optional extension board in use, see boards/board.h for a list.
CPPFLAGS = \
       -D BOARD=EVK1105                                   \
       -D __FREERTOS__

# Extra flags to use when linking
LDFLAGS = \
        -Wl,-e,_trampoline

# Pre- and post-build commands
PREBUILD_CMD = 
POSTBUILD_CMD = 

# Look for source files relative to the top-level source directory
VPATH           := $(PRJ_PATH)

# Output target file
target          := $(TARGET)

# Output project name (target name minus suffix)
project         := $(basename $(target))

# Output target file (typically ELF or static library)
ifeq ($(suffix $(target)),.a)
target_type     := lib
else
ifeq ($(suffix $(target)),.elf)
target_type     := elf
else
$(error "Target type $(target_type) is not supported")
endif
endif

# Allow override of operating system detection. The user can add OS=Linux or
# OS=Windows on the command line to explicit set the host OS.
#
# This allows to work around broken uname utility on certain systems.
ifdef OS
  ifeq ($(strip $(OS)), Linux)
    os_type     := Linux
  endif
  ifeq ($(strip $(OS)), Windows)
    os_type     := windows32_64
  endif
endif

os_type         ?= $(strip $(shell uname))

ifeq ($(os_type),windows32)
os              := Windows
else
ifeq ($(os_type),windows64)
os              := Windows
else
ifeq ($(os_type),windows32_64)
os              ?= Windows
else
ifeq ($(os_type),)
os              := Windows
else
# Default to Linux style operating system. Both Cygwin and mingw are fully
# compatible (for this Makefile) with Linux.
os              := Linux
endif
endif
endif
endif

CROSS           ?= avr32-
AR              := $(CROSS)ar
AS              := $(CROSS)as
CC              := $(CROSS)gcc
CPP             := $(CROSS)gcc -E
CXX             := $(CROSS)g++
LD              := $(CROSS)gcc
NM              := $(CROSS)nm
OBJCOPY         := $(CROSS)objcopy
OBJDUMP         := $(CROSS)objdump
SIZE            := $(CROSS)size

RM              := rm
ifeq ($(os),Windows)
RMDIR           := rmdir /S /Q
else
RMDIR           := rmdir -p --ignore-fail-on-non-empty
endif

# On Windows, we need to override the shell to force the use of cmd.exe
ifeq ($(os),Windows)
SHELL           := cmd
endif

PROGRAM         := avr32program
GDBPROXY        := avr32gdbproxy
BATCHISP        := batchisp
ispflags-y      := -device at32$(PART) -hardware usb -operation

# Strings for beautifying output
MSG_CLEAN_FILES         = "RM      *.o *.d"
MSG_CLEAN_DIRS          = "RMDIR   $(strip $(clean-dirs))"
MSG_MKDIR               = "MKDIR   $(dir $@)"

MSG_INFO                = "INFO    "
MSG_PREBUILD            = "PREBUILD  $(PREBUILD_CMD)"
MSG_POSTBUILD           = "POSTBUILD $(POSTBUILD_CMD)"

MSG_ARCHIVING           = "AR      $@"
MSG_ASSEMBLING          = "AS      $@"
MSG_BINARY_IMAGE        = "OBJCOPY $@"
MSG_COMPILING           = "CC      $@"
MSG_COMPILING_CXX       = "CXX     $@"
MSG_EXTENDED_LISTING    = "OBJDUMP $@"
MSG_IHEX_IMAGE          = "OBJCOPY $@"
MSG_LINKING             = "LN      $@"
MSG_PREPROCESSING       = "CPP     $@"
MSG_SIZE                = "SIZE    $@"
MSG_SYMBOL_TABLE        = "NM      $@"

MSG_GETTING_CPU_INFO    = "JTAG    cpuinfo"
MSG_HALTING             = "JTAG    halt"
MSG_ERASING_CHIP        = "JTAG    chiperase"
MSG_ERASING             = "JTAG    erase"
MSG_PROGRAMMING         = "JTAG    program $(target)"
MSG_SECURING_FLASH      = "JTAG    secure flash"
MSG_RESETTING           = "JTAG    reset"
MSG_DEBUGGING           = "JTAG    debug"
MSG_RUNNING             = "JTAG    run"
MSG_READING_CPU_REGS    = "JTAG    readregs"


# Don't use make's built-in rules and variables
MAKEFLAGS       += -rR

# Don't print 'Entering directory ...'
MAKEFLAGS       += --no-print-directory

# Function for reversing the order of a list
reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

# Hide command output by default, but allow the user to override this
# by adding V=1 on the command line.
#
# This is inspired by the Kbuild system used by the Linux kernel.
ifdef V
  ifeq ("$(origin V)", "command line")
    VERBOSE = $(V)
  endif
endif
ifndef VERBOSE
  VERBOSE = 0
endif

ifeq ($(VERBOSE), 1)
  Q =
else
  Q = @
endif

arflags-gnu-y           := $(ARFLAGS)
asflags-gnu-y           := $(ASFLAGS)
cflags-gnu-y            := $(CFLAGS)
cxxflags-gnu-y          := $(CXXFLAGS)
cppflags-gnu-y          := $(CPPFLAGS)
cpuflags-gnu-y          :=
dbgflags-gnu-y          := $(DBGFLAGS)
libflags-gnu-y          := $(foreach LIB,$(LIBS),-l$(LIB))
ldflags-gnu-y           := $(LDFLAGS)
clean-files             :=
clean-dirs              :=

clean-files             += $(wildcard $(target) $(project).map)
clean-files             += $(wildcard $(project).hex $(project).bin)
clean-files             += $(wildcard $(project).lss $(project).sym)
clean-files             += $(wildcard $(build))

# Use pipes instead of temporary files for communication between processes
cflags-gnu-y    += -pipe
asflags-gnu-y   += -pipe
ldflags-gnu-y   += -pipe

# Archiver flags.
arflags-gnu-y   += rcs

# Always enable warnings. And be very careful about implicit
# declarations.
cflags-gnu-y    += -Wall -Wstrict-prototypes -Wmissing-prototypes
cflags-gnu-y    += -Werror-implicit-function-declaration
cxxflags-gnu-y  += -Wall
# IAR doesn't allow arithmetic on void pointers, so warn about that.
cflags-gnu-y    += -Wpointer-arith
cxxflags-gnu-y  += -Wpointer-arith

# Preprocessor flags.
cppflags-gnu-y  += $(foreach INC,$(addprefix $(PRJ_PATH)/,$(INC_PATH)),-I$(INC))
asflags-gnu-y   += $(foreach INC,$(addprefix $(PRJ_PATH)/,$(INC_PATH)),'-Wa,-I$(INC)')

# CPU specific flags.
cpuflags-gnu-y  += -march=ucr2 -mpart=$(PART)

# Dependency file flags.
depflags        = -MD -MP -MQ $@

# Debug specific flags.
ifdef BUILD_DEBUG_LEVEL
dbgflags-gnu-y  += -g$(BUILD_DEBUG_LEVEL)
else
dbgflags-gnu-y  += -g3
endif

# Optimization specific flags.
ifdef BUILD_OPTIMIZATION
optflags-gnu-y  = -O$(BUILD_OPTIMIZATION)
else
optflags-gnu-y  = $(OPTIMIZATION)
endif

# Relax compilation and linking.
cflags-gnu-y    += -mrelax
cxxflags-gnu-y  += -mrelax
asflags-gnu-y   += -mrelax
ldflags-gnu-y   += -Wl,--relax,--direct-data

# Patch for compiler bug
cflags-gnu-y    += -mno-cond-exec-before-reload 
cxxflags-gnu-y  += -mno-cond-exec-before-reload

# Always preprocess assembler files.
asflags-gnu-y   += -x assembler-with-cpp
# Compile C files using the GNU99 standard.
cflags-gnu-y    += -std=gnu99
# Compile C++ files using the GNU++98 standard.
cxxflags-gnu-y  += -std=gnu++98

# Use signed character type when compiling.
cflags-gnu-y    += -funsigned-char
cxxflags-gnu-y  += -funsigned-char

# Don't use strict aliasing (very common in embedded applications).
cflags-gnu-y    += -fno-strict-aliasing
cxxflags-gnu-y  += -fno-strict-aliasing

# Separate each function and data into its own separate section to allow
# garbage collection of unused sections.
cflags-gnu-y    += -ffunction-sections -fdata-sections
cxxflags-gnu-y  += -ffunction-sections -fdata-sections

# Garbage collect unreferred sections when linking.
ldflags-gnu-y   += -Wl,--gc-sections

# Use the linker script if provided by the project.
ifneq ($(strip $(LINKER_SCRIPT)),)
ldflags-gnu-y   += -Wl,-T $(PRJ_PATH)/$(LINKER_SCRIPT)
endif

# Output a link map file and a cross reference table
ldflags-gnu-y   += -Wl,-Map=$(project).map,--cref

# Add library search paths relative to the top level directory.
ldflags-gnu-y   += $(foreach _LIB_PATH,$(addprefix $(PRJ_PATH)/,$(LIB_PATH)),-L$(_LIB_PATH))

a_flags  = $(cpuflags-gnu-y) $(depflags) $(cppflags-gnu-y) $(asflags-gnu-y) -D__ASSEMBLY__
c_flags  = $(cpuflags-gnu-y) $(dbgflags-gnu-y) $(depflags) $(optflags-gnu-y) $(cppflags-gnu-y) $(cflags-gnu-y)
cxx_flags= $(cpuflags-gnu-y) $(dbgflags-gnu-y) $(depflags) $(optflags-gnu-y) $(cppflags-gnu-y) $(cxxflags-gnu-y)
l_flags  = $(cpuflags-gnu-y) $(optflags-gnu-y) $(ldflags-gnu-y)
ar_flags = $(arflags-gnu-y)

# Source files list and part informations must already be included before
# running this makefile

# If a custom build directory is specified, use it -- force trailing / in directory name.
ifdef BUILD_DIR
	build-dir       := $(dir $(BUILD_DIR))$(if $(notdir $(BUILD_DIR)),$(notdir $(BUILD_DIR))/)
else
	build-dir        =
endif

# Create object files list from source files list.
obj-y                   := $(addprefix $(build-dir), $(addsuffix .o,$(basename $(CSRCS) $(ASSRCS))))
# Create dependency files list from source files list.
dep-files               := $(wildcard $(foreach f,$(obj-y),$(basename $(f)).d))

clean-files             += $(wildcard $(obj-y))
clean-files             += $(dep-files)

clean-dirs              += $(call reverse,$(sort $(wildcard $(dir $(obj-y)))))

# Default target.
.PHONY: all
all: prebuild $(target) $(project).lss $(project).sym $(project).hex $(project).bin postbuild

prebuild:
ifneq ($(strip $(PREBUILD_CMD)),)
	@echo $(MSG_PREBUILD)
	$(Q)$(PREBUILD_CMD)
endif

postbuild:
ifneq ($(strip $(POSTBUILD_CMD)),)
	@echo $(MSG_POSTBUILD)
	$(Q)$(POSTBUILD_CMD)
endif

# Clean up the project.
.PHONY: clean
clean:
	@$(if $(strip $(clean-files)),echo $(MSG_CLEAN_FILES))
	$(if $(strip $(clean-files)),$(Q)$(RM) $(clean-files),)
	@$(if $(strip $(clean-dirs)),echo $(MSG_CLEAN_DIRS))
# Remove created directories, and make sure we only remove existing
# directories, since recursive rmdir might help us a bit on the way.
ifeq ($(os),Windows)
	$(Q)$(if $(strip $(clean-dirs)),                        \
			$(RMDIR) $(strip $(subst /,\,$(clean-dirs))))
else
	$(Q)$(if $(strip $(clean-dirs)),                        \
		for directory in $(strip $(clean-dirs)); do     \
			if [ -d "$$directory" ]; then           \
				$(RMDIR) $$directory;           \
			fi                                      \
		done                                            \
	)
endif

# Rebuild the project.
.PHONY: rebuild
rebuild: clean all

.PHONY: objfiles
objfiles: $(obj-y)

# Create object files from C source files.
$(build-dir)%.o: %.c $(MAKEFILE_PATH) 
	$(Q)test -d $(dir $@) || echo $(MSG_MKDIR)
ifeq ($(os),Windows)
	$(Q)test -d $(patsubst %/,%,$(dir $@)) || mkdir $(subst /,\,$(dir $@))
else
	$(Q)test -d $(dir $@) || mkdir -p $(dir $@)
endif
	@echo $(MSG_COMPILING)
	$(Q)$(CC) $(c_flags) -c $< -o $@

# Create object files from C++ source files.
$(build-dir)%.o: %.cpp $(MAKEFILE_PATH)
	$(Q)test -d $(dir $@) || echo $(MSG_MKDIR)
ifeq ($(os),Windows)
	$(Q)test -d $(patsubst %/,%,$(dir $@)) || mkdir $(subst /,\,$(dir $@))
else
	$(Q)test -d $(dir $@) || mkdir -p $(dir $@)
endif
	@echo $(MSG_COMPILING_CXX)
	$(Q)$(CXX) $(cxx_flags) -c $< -o $@

# Preprocess and assemble: create object files from assembler source files.
$(build-dir)%.o: %.s $(MAKEFILE_PATH) 
	$(Q)test -d $(dir $@) || echo $(MSG_MKDIR)
ifeq ($(os),Windows)
	$(Q)test -d $(patsubst %/,%,$(dir $@)) || mkdir $(subst /,\,$(dir $@))
else
	$(Q)test -d $(dir $@) || mkdir -p $(dir $@)
endif
	@echo $(MSG_ASSEMBLING)
	$(Q)$(CC) $(a_flags) -c $< -o $@

# Preprocess and assemble: create object files from assembler source files.
$(build-dir)%.o: %.S $(MAKEFILE_PATH) 
	$(Q)test -d $(dir $@) || echo $(MSG_MKDIR)
ifeq ($(os),Windows)
	$(Q)test -d $(patsubst %/,%,$(dir $@)) || mkdir $(subst /,\,$(dir $@))
else
	$(Q)test -d $(dir $@) || mkdir -p $(dir $@)
endif
	@echo $(MSG_ASSEMBLING)
	$(Q)$(CC) $(a_flags) -c $< -o $@

# Include all dependency files to add depedency to all header files in use.
include $(dep-files)

ifeq ($(target_type),lib)
# Archive object files into an archive
$(target): $(MAKEFILE_PATH) $(obj-y)
	@echo $(MSG_ARCHIVING)
	$(Q)$(AR) $(ar_flags) $@ $(obj-y)
	@echo $(MSG_SIZE)
	$(Q)$(SIZE) -Bxt $@
else
ifeq ($(target_type),elf)
# Link the object files into an ELF file. Also make sure the target is rebuilt
# if the common Makefile.in or project config.mk is changed.
$(target): $(PRJ_PATH)/$(LINKER_SCRIPT) $(MAKEFILE_PATH) $(obj-y)
	@echo $(MSG_LINKING)
	$(Q)$(LD) $(l_flags) $(obj-y) -Wl,--start-group $(libflags-gnu-y) -Wl,--end-group -o $@
	@echo $(MSG_SIZE)
	$(Q)$(SIZE) -Ax $@
	$(Q)$(SIZE) -Bx $@
endif
endif

# Create extended function listing from target output file.
%.lss: $(target)
	@echo $(MSG_EXTENDED_LISTING)
	$(Q)$(OBJDUMP) -h -S $< > $@

# Create symbol table from target output file.
%.sym: $(target)
	@echo $(MSG_SYMBOL_TABLE)
	$(Q)$(NM) -n $< > $@

# Create Intel HEX image from ELF output file.
%.hex: $(target)
	@echo $(MSG_IHEX_IMAGE)
	$(Q)$(OBJCOPY) -O ihex $< $@

# Create binary image from ELF output file.
%.bin: $(target)
	@echo $(MSG_BINARY_IMAGE)
	$(Q)$(OBJCOPY) -O binary $< $@

# Provide information about the detected host operating system.
.SECONDARY: info-os
info-os:
	@echo $(MSG_INFO)$(os) build host detected
