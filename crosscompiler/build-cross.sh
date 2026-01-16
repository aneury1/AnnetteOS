#!/usr/bin/bash
export PREFIX="$PWD/opt/cross/"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

cd build-binutils || mkdir build-binutils
cd build-binutils
../binutils-2.45/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install


@echo "building gdb"
cd build-gdb || mkdir build-gdb
cd build-gdb
../gdb-17.1/configure --target=$TARGET --prefix="$PREFIX" --disable-werror
make all-gdb
make install-gdb


# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

cd build-gcc || mkdir build-gcc
cd build-gcc
../gcc-15.1.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
make all-gcc
make all-target-libgcc
make all-target-libstdc++-v3
make install-gcc
make install-target-libgcc
make install-target-libstdc++-v3