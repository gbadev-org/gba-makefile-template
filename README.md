# devkitARM GBA Template

NOTE: This project is not affiliated with devkitPro.

This repository provides a solid template Makefile for GBA development with
devkitARM, supporting C, C++, and Assembly.

Build options inside the `Makefile` are commented and hopefully easy to use.

build.mk contains all of the build code, and you usually don't need to touch it
at all.

## Features

- soundbank.bin creation with mmutil
- Graphics processing with grit
- Conversion of binary files with bin2s
- Use of relative and symlinked file paths (../etc/hi.c)
- Creating a multiboot build by adding `_mb` suffix to project name
- `*.iwram.ext`, `*.arm.ext`, and `*.thumb.ext` filenames override ARM/THUMB code
- Building with LTO
- Specifying title, game code, etc. for gbafix
- Running ROM in mGBA (by default) via `make run`

## License

Repository is licensed under the [CC0 1.0 Universal License][CC0].

[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
