ifeq ($(and $(strip $(DEVKITPRO)),$(strip $(DEVKITARM))),)
$(error Make sure DEVKITPRO and DEVKITARM are correctly set in your environment.)
endif

# Name of your ROM
PROJECT		:= devkitarm-template

# Uncomment this if you're building a library
#
# BUILD_LIB	:= yes

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

#
# Files
#
# Options ending in _FILES list individual files
# Options ending in _DIRS and _EXTS are used for globbing
#
# For every directory listed in a _DIRS option, every file with an extension
# listed in the matching _EXTS option is collected
#
# This process is not recursive, so if you have nested directories, you will
# have to list all of them
#
# If you want to get every .c and .cpp file in a directory called source:
#
# SOURCE_DIRS := source
# SOURCE_EXTS := c cpp

# Binary files to process with bin2s
BINARY_FILES	:= src/hello.bin
BINARY_DIRS	:=
BINARY_EXTS	:=

# Audio files to process with mmutil
AUDIO_FILES	:=
AUDIO_DIRS	:=
AUDIO_EXTS	:=

# Graphics files to process with grit
#
# Every file requires an accompanying .grit file,
# so gfx/test.png needs gfx/test.png.grit
GRAPHICS_FILES	:=
GRAPHICS_DIRS	:=
GRAPHICS_EXTS	:=

# Source files to compile
SOURCE_FILES	:= src/main.c
SOURCE_DIRS	:=
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
ALLFLAGS	:= -Wall -Wextra -g3 -gdwarf-4 -O2 \
		-ffunction-sections -fdata-sections \
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

include build.mk
