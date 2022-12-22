.SUFFIXES:

#
# Functions
#

# String equality
eq	= $(if $(and $(findstring x$(1),x$(2)),$(findstring x$(2),x$(1))),y,)

# Map relative directory names into build tree
pathmap	= $(1)$(subst $(subst ,, ),/,$(foreach component,$(subst /, ,$(2)),$(if $(call eq,$(component),..),__,$(component))))$(3)

glob	= $(foreach dir,$(1), \
	$(foreach ext,$(2),$(wildcard $(dir)/*.$(ext))))

# Object and dependency filename functions
obj	= $(call pathmap,$(BUILDDIR)/obj/,$(1),.o)
dep	= $(call pathmap,$(BUILDDIR)/dep/,$(1),.d)
gen_s	= $(call pathmap,$(BUILDDIR)/gen_sources/,$(1),$(2))
gen_i	= $(call pathmap,$(BUILDDIR)/gen_include/,$(1),$(2))
gen_b	= $(call pathmap,$(BUILDDIR)/gen_binary/,$(1),$(2))

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

# Toolchain prefix
TOOLCHAIN	:= $(DEVKITARM)/bin/arm-none-eabi

# Tools
CC 	:= $(TOOLCHAIN)-gcc
CXX	:= $(TOOLCHAIN)-g++
AR	:= $(TOOLCHAIN)-ar
OBJCOPY	:= $(TOOLCHAIN)-objcopy
LD	:= $(if $(call is-cxx,$(SOURCES)),$(CXX),$(CC))
BIN2S	:= $(DEVKITPRO)/tools/bin/bin2s
GBAFIX	:= $(DEVKITPRO)/tools/bin/gbafix
MMUTIL	:= $(DEVKITPRO)/tools/bin/mmutil
GRIT	:= $(DEVKITPRO)/tools/bin/grit
RUNNER	:= mgba-qt

# Primary build artifacts
ELFFILE	:= $(BUILDDIR)/$(PROJECT).elf
ROMFILE	:= $(BUILDDIR)/$(PROJECT).gba
MAPFILE	:= $(BUILDDIR)/$(PROJECT).map
LIBFILE	:= $(BUILDDIR)/lib$(PROJECT).a

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

SOURCES	:= $(SOURCE_FILES) $(call glob,$(SOURCE_DIRS),$(SOURCE_EXTS))

BINARY	:= $(BINARY_FILES) $(call glob,$(BINARY_DIRS),$(BINARY_EXTS))

AUDIO	:= $(AUDIO_FILES) $(call glob,$(AUDIO_DIRS),$(AUDIO_EXTS))

GRAPHICS:= $(GRAPHICS_FILES) $(call glob,$(GRAPHICS_DIRS),$(GRAPHICS_EXTS))

GEN_B	:= $(if $(strip $(AUDIO)),$(call gen_b,soundbank.bin,))

BINARY	+= $(GEN_B)

GEN_S	:= $(foreach bin,$(BINARY),$(call gen_s,$(bin),.S)) \
	   $(foreach gfx,$(GRAPHICS),$(call gen_s,$(gfx),.s))

SOURCES	+= $(GEN_S)

GEN_I	:= $(foreach bin,$(BINARY),$(call gen_i,$(bin),.h)) \
	   $(foreach gfx,$(GRAPHICS),$(call gen_i,$(gfx),.h)) \
	   $(if $(strip $(AUDIO)),$(call gen_i,soundbank.h,),)

ALLFLAGS += $(foreach dir,$(dir $(GEN_I)),-iquote $(dir))

# Build artifacts
OBJECTS	:= $(foreach source,$(SOURCES),$(call obj,$(source)))
DEPENDS	:= $(foreach source,$(SOURCES),$(call dep,$(source)))
DIRS	:= $(dir $(BUILDDIR) $(OBJECTS) $(DEPENDS) $(GEN_S) $(GEN_I) $(GEN_B))

#
# Targets
#

ifeq ($(strip $(BUILD_LIB)),)
$(ROMFILE): $(ELFFILE)
$(ELFFILE): $(OBJECTS)
else
$(LIBFILE): $(OBJECTS)
endif

$(OBJECTS): | dirs $(GEN_I)

define bin2s =
$(call gen_s,$(1),.S) $(call gen_i,$(1),.h) &: $(1)
	@echo "bin2s   $$<"
	$$(SILENT)$$(BIN2S) -a 2 -H $(call gen_i,$(1),.h) $$< > $(call gen_s,$(1),.S)
endef

define grit =
$(call gen_s,$(1),.s) $(call gen_i,$(1),.h) &: $(1) $(1).grit
	@echo "grit    $$<"
	$$(SILENT)$$(GRIT) -o$(call gen_s,$(1),.s) -ff$(1).grit $$<
	$$(SILENT)mv $(call gen_s,$(1),.h) $(call gen_i,$(1),.h)
endef

define compile =
$(call obj,$(1)): $(1)
endef

# Process binary files
$(foreach binary,$(BINARY),$(eval $(call bin2s,$(binary))))

# Process graphics files
$(foreach graphic,$(GRAPHICS),$(eval $(call grit,$(graphic))))

# Compile sources
$(foreach source,$(SOURCES),$(eval $(call compile,$(source))))

#
# Rules
#

$(BUILDDIR)/gen_binary/soundbank.bin $(BUILDDIR)/gen_include/soundbank.h &: $(AUDIO)
	@echo "mmutil  $@"
	$(SILENT)$(MMUTIL) $^ -o$(BUILDDIR)/gen_binary/soundbank.bin -h$(BUILDDIR)/gen_include/soundbank.h

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

