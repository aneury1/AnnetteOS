#!/usr/bin/bash

mkdir ../build

clang++ \
  --target=x86_64-elf \
  -ffreestanding \
  -fno-exceptions \
  -fno-rtti \
  -fno-stack-protector \
  -fno-pic \
  -mno-red-zone \
  -nostdlib \
  -c ../src/arch/x86_64/kernel.cpp -o ../build/kernel.o


clang \
  --target=x86_64-elf \
  -ffreestanding \
  -c ../src/arch/x86_64/boot.s -o ../build/boot.o


ld.lld \
  -T ../src/arch/x86_64/linker.ld \
  ../build/boot.o ../build/kernel.o \
  -o ../build/kernel.elf
