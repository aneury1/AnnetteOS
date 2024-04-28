export FREEGCC=/home/aneury/Desktop/project/AnnetteOS/cross/i386-elf-7.5.0-Linux-x86_64/bin/i386-elf-gcc
export FREEGPP=/home/aneury/Desktop/project/AnnetteOS/cross/i386-elf-7.5.0-Linux-x86_64/bin/i386-elf-g++
export ASSEMBLER=nasm

export CPP_FLAGS_FREESTANDING="-ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti"
export C_FLAGS_FREESTANDING="-std=gnu99 -ffreestanding -O2 -Wall -Wextra"

cd ./src/kernel
/home/aneury/Desktop/project/AnnetteOS/cross/i386-elf-7.5.0-Linux-x86_64/bin/i386-elf-as boot.s -o boot.o

/home/aneury/Desktop/project/AnnetteOS/cross/i386-elf-7.5.0-Linux-x86_64/bin/i386-elf-gcc -c kmain.cpp -o kmain.o  -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti

/home/aneury/Desktop/project/AnnetteOS/cross/i386-elf-7.5.0-Linux-x86_64/bin/i386-elf-gcc -T ./linker.ld -o annette.bin  -ffreestanding -O2 -nostdlib boot.o kmain.o -lgcc
