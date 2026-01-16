#!/usr/bin/bash
export CWD=$PWD
export TARGET=x86_64-elf
export PREFIX=$CWD/cross
export PATH="$PREFIX/bin:$PATH"

sudo apt install \
  build-essential \
  bison \
  flex \
  libgmp3-dev \
  libmpc-dev \
  libmpfr-dev \
  texinfo \
  wget \
  xz-utils

mkdir build-cross
cd build-cross

wget https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz
tar -xf binutils-2.42.tar.xz

mkdir build-binutils
cd build-binutils

../binutils-2.42/configure \
  --target=$TARGET \
  --prefix=$PREFIX \
  --with-sysroot \
  --disable-nls \
  --disable-werror

make -j$(nproc)
make install
# check version
$TARGET-ld --version

cd ..

wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
tar -xf gcc-13.2.0.tar.xz

cd gcc-13.2.0
./contrib/download_prerequisites
cd ..

mkdir build-gcc
cd build-gcc

../gcc-13.2.0/configure \
  --target=$TARGET \
  --prefix=$PREFIX \
  --disable-nls \
  --enable-languages=c,c++ \
  --without-headers

make all-gcc -j$(nproc)
make all-target-libgcc -j$(nproc)

make install-gcc
make install-target-libgcc