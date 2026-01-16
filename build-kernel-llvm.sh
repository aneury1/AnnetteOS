#!/bin/bash

set -e  # Exit on error

# Configuration
TARGET="i686-elf"
TOOLCHAIN_DIR="./toolchain"
OUTPUT_DIR="./build"
KERNEL_NAME="kernel.elf"
ISO_NAME="myos.iso"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_msg() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if toolchain exists
if [ ! -d "$TOOLCHAIN_DIR" ]; then
    print_error "Toolchain not found at $TOOLCHAIN_DIR"
    print_warn "Run the LLVM build script first!"
    exit 1
fi

# Set up environment
export PATH="$TOOLCHAIN_DIR/bin:$PATH"

# Check if clang is available
if ! command -v clang &> /dev/null; then
    print_error "Clang not found in PATH"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

print_msg "Building Hello World OS Kernel..."
echo ""

# Compiler flags for freestanding C++ environment
CXXFLAGS="-target $TARGET"
CXXFLAGS="$CXXFLAGS -ffreestanding"
CXXFLAGS="$CXXFLAGS -nostdlib"
CXXFLAGS="$CXXFLAGS -fno-builtin"
CXXFLAGS="$CXXFLAGS -fno-exceptions"
CXXFLAGS="$CXXFLAGS -fno-rtti"
CXXFLAGS="$CXXFLAGS -fno-stack-protector"
CXXFLAGS="$CXXFLAGS -mno-red-zone"
CXXFLAGS="$CXXFLAGS -std=c++17"
CXXFLAGS="$CXXFLAGS -Wall -Wextra"
CXXFLAGS="$CXXFLAGS -O2"

# Assembler flags
ASFLAGS="-target $TARGET"

# Linker flags
LDFLAGS="-T linker.ld"
LDFLAGS="$LDFLAGS -nostdlib"
LDFLAGS="$LDFLAGS -static"

# Compile boot assembly
print_msg "Compiling boot.s..."
clang $ASFLAGS -c boot.s -o "$OUTPUT_DIR/boot.o"

# Compile kernel C++ code
print_msg "Compiling kernel.cpp..."
clang++ $CXXFLAGS -c kernel.cpp -o "$OUTPUT_DIR/kernel.o"

# Link kernel
print_msg "Linking kernel..."
ld.lld $LDFLAGS "$OUTPUT_DIR/boot.o" "$OUTPUT_DIR/kernel.o" -o "$OUTPUT_DIR/$KERNEL_NAME"

# Verify kernel is multiboot compliant
if command -v grub-file &> /dev/null; then
    print_msg "Verifying multiboot header..."
    if grub-file --is-x86-multiboot2 "$OUTPUT_DIR/$KERNEL_NAME"; then
        print_msg "Kernel is multiboot2 compliant!"
    else
        print_warn "Kernel may not be multiboot2 compliant"
    fi
else
    print_warn "grub-file not found, skipping multiboot verification"
fi

# Create bootable ISO if grub-mkrescue is available
if command -v grub-mkrescue &> /dev/null; then
    print_msg "Creating bootable ISO..."
    
    # Create ISO directory structure
    mkdir -p "$OUTPUT_DIR/isodir/boot/grub"
    
    # Copy kernel
    cp "$OUTPUT_DIR/$KERNEL_NAME" "$OUTPUT_DIR/isodir/boot/"
    
    # Create grub.cfg
    cat > "$OUTPUT_DIR/isodir/boot/grub/grub.cfg" << EOF
set timeout=0
set default=0

menuentry "Hello World OS" {
    multiboot2 /boot/$KERNEL_NAME
    boot
}
EOF
    
    # Create ISO
    grub-mkrescue -o "$OUTPUT_DIR/$ISO_NAME" "$OUTPUT_DIR/isodir" 2>/dev/null
    
    print_msg "ISO created: $OUTPUT_DIR/$ISO_NAME"
else
    print_warn "grub-mkrescue not found, skipping ISO creation"
    print_warn "Install with: sudo apt install grub-pc-bin xorriso"
fi

# Print kernel information
print_msg "Kernel size: $(stat -f%z "$OUTPUT_DIR/$KERNEL_NAME" 2>/dev/null || stat -c%s "$OUTPUT_DIR/$KERNEL_NAME") bytes"

echo ""
print_msg "Build completed successfully!"
echo ""
echo "To test the kernel:"
echo "  qemu-system-i386 -kernel $OUTPUT_DIR/$KERNEL_NAME"
echo ""
if [ -f "$OUTPUT_DIR/$ISO_NAME" ]; then
    echo "Or boot the ISO:"
    echo "  qemu-system-i386 -cdrom $OUTPUT_DIR/$ISO_NAME"
    echo ""
fi
echo "To debug:"
echo "  qemu-system-i386 -kernel $OUTPUT_DIR/$KERNEL_NAME -s -S"
echo "  (then connect with gdb)"
echo ""

# Check if QEMU is available and offer to run
if command -v qemu-system-i386 &> /dev/null; then
    read -p "Run kernel in QEMU now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_msg "Starting QEMU..."
        qemu-system-i386 -kernel "$OUTPUT_DIR/$KERNEL_NAME"
    fi
else
    print_warn "QEMU not found. Install with: sudo apt install qemu-system-x86"
fi