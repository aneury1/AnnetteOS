# Hello World OS Kernel with C++ Features

A minimal operating system kernel demonstrating C++ features including classes, destructors, virtual functions, and templates compiled with LLVM/Clang.

## Features Demonstrated

- ✅ **Classes and Objects**: VGATerminal and Display classes
- ✅ **Constructors/Destructors**: Proper initialization and cleanup
- ✅ **Virtual Functions**: Polymorphic dispatch through base class pointers
- ✅ **Templates**: Template functions and classes (Array<T>)
- ✅ **Inheritance**: VGATerminal inherits from Display base class
- ✅ **Operator Overloading**: Array subscript operator, new/delete operators
- ✅ **VGA Text Mode**: Direct hardware access for display output

## Project Structure

```
.
├── kernel.cpp          # Main kernel code with C++ features
├── boot.s             # Assembly bootstrap code
├── linker.ld          # Linker script
├── build.sh           # Build script
├── Makefile           # Alternative build system
└── README.md          # This file
```

## Prerequisites

1. **LLVM Toolchain**: Build using the provided `build-llvm-cross.sh` script
2. **QEMU** (optional, for testing): `sudo apt install qemu-system-x86`
3. **GRUB tools** (optional, for ISO): `sudo apt install grub-pc-bin xorriso`

## Building the Kernel

### Method 1: Using build.sh (Recommended)

```bash
# Make executable
chmod +x build.sh

# Build kernel
./build.sh

# The script will:
# - Compile boot.s and kernel.cpp
# - Link into kernel.elf
# - Create bootable ISO (if GRUB tools available)
# - Offer to run in QEMU
```

### Method 2: Using Makefile

```bash
# Build kernel
make

# Create bootable ISO
make iso

# Run in QEMU
make run

# Debug with GDB
make debug

# Clean build files
make clean

# Show help
make help
```

### Method 3: Manual Build

```bash
# Set up environment
export PATH="./toolchain/bin:$PATH"

# Create build directory
mkdir -p build

# Compile boot code
clang -target i686-elf -c boot.s -o build/boot.o

# Compile kernel
clang++ -target i686-elf \
    -ffreestanding \
    -nostdlib \
    -fno-builtin \
    -fno-exceptions \
    -fno-rtti \
    -fno-stack-protector \
    -mno-red-zone \
    -std=c++17 \
    -Wall -Wextra \
    -O2 \
    -c kernel.cpp -o build/kernel.o

# Link kernel
ld.lld -T linker.ld \
    -nostdlib \
    -static \
    build/boot.o build/kernel.o \
    -o build/kernel.elf
```

## Running the Kernel

### In QEMU (Direct Kernel Boot)

```bash
qemu-system-i386 -kernel build/kernel.elf
```

### In QEMU (ISO Boot)

```bash
qemu-system-i386 -cdrom build/myos.iso
```

### On Real Hardware

1. Write ISO to USB drive:
   ```bash
   sudo dd if=build/myos.iso of=/dev/sdX bs=4M status=progress
   ```
2. Boot from USB drive

## Expected Output

When the kernel runs, you should see:

```
=================================
  Hello World OS Kernel!
=================================

Virtual Function Test:
  Virtual dispatch working!

Template Function Test:
  max(42, 17) = 42
  max(3.14, 2.71) = 314 (x100)

Template Class Test:
  Array contents: 10, 20, 30, 40, 50

C++ Features Tested:
  [X] Constructors
  [X] Destructors
  [X] Virtual Functions
  [X] Templates
  [X] Operator Overloading
  [X] Inheritance

Kernel initialization complete!
```

## Debugging

### With QEMU and GDB

Terminal 1:
```bash
qemu-system-i386 -kernel build/kernel.elf -s -S
```

Terminal 2:
```bash
gdb build/kernel.elf
(gdb) target remote :1234
(gdb) break kernel_main
(gdb) continue
```

### View Disassembly

```bash
llvm-objdump -d build/kernel.elf
```

### View Symbols

```bash
llvm-nm build/kernel.elf
```

### View Sections

```bash
llvm-readelf -S build/kernel.elf
```

## Code Explanation

### kernel.cpp

- **VGA Driver**: Direct hardware access to VGA text buffer at 0xB8000
- **Display Base Class**: Abstract base with pure virtual functions
- **VGATerminal**: Concrete implementation with scrolling support
- **Array<T> Template**: Demonstrates template classes with resource management
- **C++ Runtime Support**: Custom new/delete operators for freestanding environment
- **Global Constructors**: Proper initialization of global C++ objects

### boot.s

- Multiboot2 header for bootloader compatibility
- Stack setup (16KB)
- Calls global constructors before kernel_main
- Entry point for the kernel

### linker.ld

- Places kernel at 1MB in memory (standard for x86)
- Organizes sections: .multiboot, .text, .data, .bss
- Defines constructor/destructor arrays
- Aligns sections to page boundaries (4KB)

## Compiler Flags Explained

### C++ Flags

- `-target i686-elf`: Cross-compile for bare-metal i686
- `-ffreestanding`: No standard library or hosted environment
- `-nostdlib`: Don't link standard library
- `-fno-builtin`: Don't assume standard functions exist
- `-fno-exceptions`: Disable C++ exceptions (requires unwinding support)
- `-fno-rtti`: Disable runtime type information
- `-fno-stack-protector`: No stack canaries (requires support code)
- `-mno-red-zone`: Required for kernel code (no red zone below stack)
- `-std=c++17`: Use C++17 standard

## Troubleshooting

### "Kernel is not multiboot compliant"

- Check that boot.s has correct multiboot2 header
- Verify linker script places .multiboot section first
- Use `grub-file --is-x86-multiboot2 build/kernel.elf` to verify

### "Undefined reference to vtable"

- Ensure all pure virtual functions are implemented
- Check that __cxa_pure_virtual is defined

### "Triple screen/garbage output"

- Check VGA buffer pointer (0xB8000)
- Verify character encoding (ASCII + color byte)
- Ensure proper initialization in constructor

### QEMU shows black screen

- Try adding `-serial stdio` to see serial output
- Check that kernel_main is being called
- Verify the kernel loaded at correct address

## Extending the Kernel

### Add More Output

Modify `kernel_main()` to add more demonstrations:

```cpp
terminal.write_string("Hello from my OS!\n");
```

### Add Keyboard Support

1. Set up IDT (Interrupt Descriptor Table)
2. Configure PIC (Programmable Interrupt Controller)
3. Add keyboard IRQ handler
4. Read from port 0x60

### Add Memory Management

1. Implement proper heap allocator
2. Add paging support
3. Create virtual memory manager

### Add More Drivers

- Serial port (COM1/COM2)
- Timer (PIT)
- Real-time clock (RTC)

## Resources

- [OSDev Wiki](https://wiki.osdev.org/)
- [LLVM Documentation](https://llvm.org/docs/)
- [Intel x86 Manual](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [Multiboot2 Specification](https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html)

## License

This is example/educational code. Feel free to use and modify as needed.

## Author

Created as a demonstration of C++ features in OS development using LLVM/Clang toolchain.