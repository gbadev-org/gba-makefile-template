# GBA Makefile Template

This repository provides a solid template Makefile for GBA development with
devkitARM, supporting C, C++, and Assembly.

Note that this template requires GNU Make 4.3. Most systems should have it,
however LTS Linux distros like Debian 10 or Ubuntu 20.04 might not.
Check with `make --version`.

## Usage

- Modify the options inside `Makefile` to suit your needs, and run `make`.
- To get verbose output, run `make V=1` or `make VERBOSE=1`.
- To run a clean build, run `make -B`

build.mk contains all of the build code, and you usually don't need to touch it
at all.

## Features

- Soundbank creation with mmutil
- Graphics processing with grit
- Binary conversion with bin2s
- Use of relative and symlinked file paths (e.g. `../etc/hi.c`)
- Creating a multiboot build by adding `_mb` suffix to project name
- `*.iwram.*`, `*.arm.*`, and `*.thumb.*` filenames override ARM/THUMB code
- Building with LTO
- Building a static library
- Specifying title, game code, etc. for gbafix
- Running ROM in mGBA (by default) via `make run`. Custom runner via `make RUNNER=... run`
- Automatic `.gitignore` creation in build directory

## License

This repository is licensed under the [CC0 1.0 Universal License][CC0].

[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
