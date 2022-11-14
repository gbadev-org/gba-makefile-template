.SUFFIXES:

ifeq ($(and $(strip $(DEVKITPRO)),$(strip $(DEVKITARM))),)
$(error Make sure DEVKITPRO and DEVKITARM are correctly set in your environment.)
endif

# Name of your ROM
PROJECT		:= devkitarm-template

# Options for gbafix (optional)
#
# Title:        12 characters
# Game code:     4 characters
# Maker code:    2 characters
# Version:       1 character
ROM_TITLE	:=
ROM_GAMECODE	:=
ROM_MAKERCODE	:=
ROM_VERSION	:=

# Source files
SOURCE_FILES	:= src/main.c

# Source directories
SOURCE_DIRS	:=

# Source file extensions, for use with SOURCE_DIRS
SOURCE_EXTS	:=

# Include directories
INCLUDES	:=

# Library directories, with /include and /lib
LIBDIRS		:= $(DEVKITPRO)/libgba $(DEVKITPRO)/libtonc

# Libraries to link
LIBS		:= tonc

# All build output goes here
BUILDDIR	:= build

# Compiler flags (all languages)
ALLFLAGS	:= -g3 -gdwarf-4 -O2 -ffunction-sections -fdata-sections \
		   -D_DEFAULT_SOURCE

# C compiler flags
CFLAGS		:= -std=c99

# C++ compiler flags
CXXFLAGS	:= -std=c++20 -fno-rtti -fno-exceptions

# Assembler flags (as passed to GCC)
ASFLAGS		:=

# Linker flags (as passed to GCC)
LDFLAGS		:= -mthumb \
		$(if $(filter %_mb,$(PROJECT)),-specs=gba_mb.specs,-specs=gba.specs)

# Uncomment this if you want to use Link Time Optimization
#
# USE_LTO		:= yes

# Toolchain prefix
#
# Only change this if you want to use a different compiler
TOOLCHAIN	:= $(DEVKITARM)/bin/arm-none-eabi

#
# Internal Functions
#

# String equality
eq	= $(if $(and $(findstring x$(1),x$(2)),$(findstring x$(2),x$(1))),y,)

# Map relative directory names into build tree
pathmap	= $(1)$(subst $(subst ,, ),/,$(foreach component,$(subst /, ,$(2)),$(if $(call eq,$(component),..),__,$(component))))$(3)

# Object and dependency filename functions
obj	= $(call pathmap,$(BUILDDIR)/obj/,$(1),.o)
dep	= $(call pathmap,$(BUILDDIR)/dep/,$(1),.d)

# Language detection by filenames (taken from GCC docs)
is-c	= $(if $(filter %.c %.i %.h,$(1)),y,)
is-cxx	= $(if $(filter %.ii %.cc %.cp %.cxx %.cpp %.CPP %.c++ %.C \
	%.hh %.H %.hp %.hxx %.hpp %.HPP %.h++ %.tcc,$(1)),y,)
is-asm	= $(if $(filter %.s %.S %.sx,$(1)),y,)

# devkitPRO-style architecture flag overrides
arch	= $(or \
	$(if $(filter %.arm %.iwram,$(basename $(1))),-marm,),\
	$(if $(filter %.thumb,$(basename $(1))),-mthumb,))

# Language-specific compiler flag list generation
flags	= $(or \
	$(if $(call is-c,$(1)),$(CFLAGS),),\
	$(if $(call is-cxx,$(1)),$(CXXFLAGS),),\
	$(if $(call is-asm,$(1)),$(ASFLAGS),)) $(ALLFLAGS) $(call arch,$(1))

#
# Internal Variables
#

# Verbosity
SILENT	:= $(if $(VERBOSE)$(V),,@)

# Tools
CC 	:= $(TOOLCHAIN)-gcc
CXX	:= $(TOOLCHAIN)-g++
AR	:= $(TOOLCHAIN)-ar
OBJCOPY	:= $(TOOLCHAIN)-objcopy
LD	:= $(if $(call is-cxx,$(SOURCES)),$(CXX),$(CC))
GBAFIX	:= $(DEVKITPRO)/tools/bin/gbafix
RUNNER	:= mgba-qt

# Primary build artifacts
ELFFILE	:= $(BUILDDIR)/$(PROJECT).elf
ROMFILE	:= $(BUILDDIR)/$(PROJECT).gba
MAPFILE	:= $(BUILDDIR)/$(PROJECT).map

# Default compiler flags
ALLFLAGS += \
	-mthumb \
	-mcpu=arm7tdmi \
	-mabi=aapcs \
	-mfloat-abi=soft \
	$(LIBDIRS:%=-I%/include) \
	$(INCLUDES:%=-iquote %) \
	$(if $(USE_LTO),-flto,-fno-lto) \

# Default linker flags
LDFLAGS	+= \
	-Wl,--gc-sections \
	-Wl,-Map,$(MAPFILE) \
	$(LIBDIRS:%=-L%/lib) \
	$(LIBS:%=-l%) \
	$(if $(USE_LTO),-flto,-fno-lto) \

# Gbafix flags
GFFLAGS	:= \
	$(if $(strip $(ROM_TITLE)),'-t$(strip $(ROM_TITLE))',) \
	$(if $(strip $(ROM_GAMECODE)),'-c$(strip $(ROM_GAMECODE))',) \
	$(if $(strip $(ROM_MAKERCODE)),'-m$(strip $(ROM_MAKERCODE))',) \
	$(if $(strip $(ROM_VERSION)),'-r$(strip $(ROM_VERSION))',)

SOURCES	:= $(SOURCE_FILES) \
	   $(foreach dir,$(SOURCE_DIRS), \
	   $(foreach ext,$(SOURCE_EXTS),$(wildcard $(dir)/*.$(ext))))

# Build artifacts
OBJECTS	:= $(foreach source,$(SOURCES),$(call obj,$(source)))
DEPENDS	:= $(foreach source,$(SOURCES),$(call dep,$(source)))
DIRS	:= $(dir $(BUILDDIR) $(OBJECTS) $(DEPENDS))

#
# Targets
#

$(ROMFILE): $(ELFFILE)
$(ELFFILE): $(OBJECTS)
$(OBJECTS): | dirs

$(foreach source,$(SOURCES),$(eval $(call obj,$(source)): $(source)))

#
# Rules
#

%.o:
	@echo "compile $<"
	$(SILENT)$(CC) -c -o $@ $(call flags,$<) -MMD -MP -MF $(call dep,$<) $<

%.a:
	@echo "archive $@"
	$(SILENT)rm -f $@
	$(SILENT)$(AR) rcs $@ $^

%.elf:
	@echo "link    $@"
	$(SILENT)$(LD) -o $@ $^ $(LDFLAGS)

%.gba:
	@echo "rom     $@"
	$(SILENT)$(OBJCOPY) -O binary $< $@
	$(SILENT)$(GBAFIX) $@ $(GFFLAGS) >&-

dirs:
	$(SILENT)mkdir -p $(DIRS)

clean:
	@echo "clean $(BUILDDIR)"
	$(SILENT)rm -rf $(BUILDDIR)

run: $(ELFFILE)
	@echo "run $(ELFFILE)"
	$(SILENT)$(RUNNER) $<

.PHONY: dirs clean run

-include $(DEPENDS)
