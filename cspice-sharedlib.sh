#!/bin/bash
#
# Author: Attila Kovacs <attila.kovacs[AT]cfa.harvard.edu>
#
# Shell script to build the NAIF CSPICE Toolkit with shared (.so) libraries, and dynamic linking
# instead of the normal static libraries and static linking of the distribution. 
#
# This script is available at the Smithsonian/cspice-sharelib GitHub repository at:
#
#   https://github.com/Smithsonian/cspice-sharedlib
#
# Please refer to the README.md there for documentation on how to use.
# 

# ----------------------------------------------------------------------------
# Check if we are running this from the cspice parent directory
if [ ! -d cspice ] ; then
  echo "ERROR! You should run this installation from the parent directory of of the"
  echo "       cspice installation."
  echo ""
  echo "Aborting."
  exit 1
fi

# ----------------------------------------------------------------------------
# Exit on the first error
set -e

# ----------------------------------------------------------------------------
# Go into the unpacked cspice directory 
cd cspice

# ----------------------------------------------------------------------------
# Clean out the pre-built binaries that shipped with upstream archive
rm -rf lib/* exe/*

# ----------------------------------------------------------------------------
# Modify the build scripts to dynamically link against the shared libcspice.so 
# lib.
echo "Modifying component build scripts..."

cd src

for component in * ; do
  if [ -d $component ] ; then
    # back up the build script
    cp -a $component/mkprodct.csh $component/mkprodct.bak
  
    # Don't used default build for static libs or cookbook examples. 
    # We don't package these
    if [ "$component" == "cspice" -o "$component" == "csupport" -o "$component" == "cook_c" ] ; then
      rm -f $component/*.pgm
      echo "" > $component/mkprodct.csh
    else 
      # Don't link executables against static libs
      sed -i "s:../../lib/cspice.a::g" $component/mkprodct.csh
      sed -i "s:../../lib/csupport.a::g" $component/mkprodct.csh
    fi
  fi
done

cd ..

# ----------------------------------------------------------------------------
# Additional compiler flags we need.
# It's an old library, with parts converted from FORTRAN. 
# Some functions do not declare a return value, so we must allow implitic-int
# and also other compat flags since we do not control the source code.
CFLAGS="$CFLAGS -ansi -DNON_UNIX_STDIO -Wno-implicit-int -fno-strict-aliasing"

# Flags for linking shared libraries
SO_LINK="-shared -fPIC -Wl,-soname,libcspice.so.1 $LDFLAGS -lm"

# ----------------------------------------------------------------------------
echo "Building lib/libcspice.so.1..."

# Build shared lib first (our way)
gcc -o lib/libcspice.so.1 src/cspice/*.c src/csupport/*.c $CPPFLAGS $CFLAGS $SO_LINK

# ----------------------------------------------------------------------------
# Create unversion .so symlink
echo "Creating lib/libcspice.so link..."
( cd lib ; ln -sf libcspice.so.1 libcspice.so )

# ----------------------------------------------------------------------------
# Now we can run the modified build scripts...

# Set up variables for build scripts
export TKCOMPILER=gcc
export TKCOMPILEOPTIONS="-c $CPPFLAGS $CFLAGS"
export TKLINKOPTIONS="$LDFLAGS -L$(pwd)/lib -lcspice -lm"

# Locating the shared libraries for local builds
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$(pwd)/lib"

# Now build the executables
echo "Building CSPICE toolkit executables in exe/..."
csh makeall.csh

# ----------------------------------------------------------------------------
# Restore the original build scripts
echo "Restoring original build scripts..."
for component in * ; do
  if [ -f $component/mkproduct.bak ] ; then
    # back up the build script
    mv $component/mkprodct.bak $component/mkprodct.csh 

echo "All done."
