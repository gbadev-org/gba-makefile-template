# devkitARM GBA Template

This repository provides a solid template Makefile for GBA development with
devkitARM, supporting C, C++, and Assembly.

Build options inside the Makefile are documented and hopefully easy to use.
While some care was taken to stay compatible with the makefiles provided by
devkitPRO, some things are not supported, notably:

- bin2s/bin2o rules from devkitPRO makefiles
- soundbank/mmutil rules from devkitPRO makefiles
- Graphics processing with grit/gbagfx
- Compression with gbalzss
- GBFS creation

Support for these rules may be added in the future

Things that are supported:

- Use of relative and symlinked file paths (../etc/hi.c)
- Creating multiboot build by adding `_mb` suffix to project name
- `*.iwram.ext`, `*.arm.ext`, and `*.thumb.ext` filenames override ARM/THUMB code
- Building with LTO
- Specifying title, game code, etc. for gbafix
- Running ROM in mGBA (by default) via `make run`

## Why?

devkitPRO's makefiles are terribly written (recursive `make`, wildcards,
poorly formatted, poorly explained), and people frequently run into issues with
them (such as duplicate filenames causing linker errors).

While the code employed in this template can be seen as daunting, it has been
written carefully, and should avoid as many pitfalls as possible. The user
should, in most cases, only have to touch the variables at the top of the file.

## License

All source code in this project is licensed under the
Mozilla Public License Version 2.0.\
See [LICENSE.txt](./LICENSE.txt) for more information.
