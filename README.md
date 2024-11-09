# cspice-sharedlib

Shell script to build the NAIF CSPICE Toolkit with shared (`.so`) libraries, and dynamic linking
instead of the normal static libraries and static linking of the distribution.

Author: Attila Kovacs `<attila.kovacs[AT]cfa.harvard.edu>`
Version: 0.9


## Prerequisites

You can get the CSPICE toolkit from https://naif.jpl.nasa.gov/naif/toolkit_C.html. Just grab
`cspice.tar.Z` for any of the platforms (these contain pre-built binaries, which we will not use 
anyway). Then unpack it in a location of choice:

```bash
 $ tar xf <path-to-tar>/cspice.tar.Z
```

(Note that the `tar.Z` extension indicates a compressed archive, but it is not in fact compressed, 
hence no decompression flags for the `tar` command).
 
 
## Advanced Setup

The build uses the standard `CPPFLAGS`, `CFLAGS`, and `LDFLAGS` options for the precompiler, 
compiler, and linker, respectively. So, you can define these in the shell prior to running the 
build to further customize the build for your need. E.g.:

```bash
 $ export CFLAGS="-O2 -g"
```

## Build

To use, simply run this script from the parent directory of the unpacked `cspice` package. E.g.:

```bash
 $ <path-to-script>/cspice-sharedlib.sh
```

## Install

After a successful build, you can install the shared libraries and executables into their final 
locations (e.g. `/usr/lib` and `/usr/bin` respectively). Simply copy the contents of `lib/` to the
designated location for the `.so` library files (and make sure that location is included in the
`LD_LIBRARY_PATH` environment variable), then copy the executables under `exe/` into the location
of choice.

--------------------------------------------------------------------------------------------------
Copyright (C)2024 Attila Kovacs
