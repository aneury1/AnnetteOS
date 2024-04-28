#!/usr/bin/bash

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

echo "Please move to make, cmake, premake..."
# echo "Showing assembler version and compiling"
rm *.o
make -j
rm *.o
rm *.iso
# $HOME/opt/cross/bin/$TARGET-as --version
#echo "Compiling boot.s"
#$HOME/opt/cross/bin/$TARGET-as ./boot.s -o boot.o
#echo "Compiling kmain.cpp"
#$HOME/opt/cross/bin/$TARGET-g++ -c kmain.cpp -o kmain.o -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
