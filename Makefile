# Makefile for Hello World OS Kernel

# Configuration
TARGET := i686-elf
TOOLCHAIN_DIR := ./toolchain
BUILD_DIR := build
ISO_DIR := $(BUILD_DIR)/isodir

# Tools
CC := $(TOOLCHAIN_DIR)/bin/clang
CXX := $(TOOLCHAIN_DIR)/bin/clang++
AS := $(TOOLCHAIN_DIR)/bin/clang
LD := $(TOOLCHAIN_DIR)/bin/ld.lld

# Flags
CXXFLAGS := -target $(TARGET) \
            -ffreestanding \
            -nostdlib \
            -fno-builtin \
            -fno-exceptions \
            -fno-rtti \
            -fno-stack-protector \
            -mno-red-zone \
            -std=c++17 \
            -Wall -Wextra \
            -O2

ASFLAGS := -target $(TARGET)

LDFLAGS := -T linker.ld \
           -nostdlib \
           -static

# Source files
ASM_SOURCES := boot.s
CXX_SOURCES := kernel.cpp

# Object files
ASM_OBJECTS := $(patsubst %.s,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
CXX_OBJECTS := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CXX_SOURCES))
OBJECTS := $(ASM_OBJECTS) $(CXX_OBJECTS)

# Output
KERNEL := $(BUILD_DIR)/kernel.elf
ISO := $(BUILD_DIR)/myos.iso

# Phony targets
.PHONY: all clean run debug iso help

# Default target
all: $(KERNEL)

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile assembly files
$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	@echo "[AS] $<"
	@$(AS) $(ASFLAGS) -c $< -o $@

# Compile C++ files
$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	@echo "[CXX] $<"
	@$(CXX) $(CXXFLAGS) -c $< -o $@

# Link kernel
$(KERNEL): $(OBJECTS) linker.ld
	@echo "[LD] $@"
	@$(LD) $(LDFLAGS) $(OBJECTS) -o $@
	@echo "Kernel built successfully!"
	@echo "Size: $$(stat -f%z $@ 2>/dev/null || stat -c%s $@) bytes"

# Create bootable ISO
iso: $(KERNEL)
	@echo "[ISO] Creating bootable ISO..."
	@mkdir -p $(ISO_DIR)/boot/grub
	@cp $(KERNEL) $(ISO_DIR)/boot/
	@echo 'set timeout=0' > $(ISO_DIR)/boot/grub/grub.cfg
	@echo 'set default=0' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo 'menuentry "Hello World OS" {' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '    multiboot2 /boot/kernel.elf' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '    boot' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '}' >> $(ISO_DIR)/boot/grub/grub.cfg
	@grub-mkrescue -o $(ISO) $(ISO_DIR) 2>/dev/null
	@echo "ISO created: $(ISO)"

# Run in QEMU
run: $(KERNEL)
	@echo "[QEMU] Running kernel..."
	@qemu-system-i386 -kernel $(KERNEL)

# Run in QEMU from ISO
run-iso: iso
	@echo "[QEMU] Running from ISO..."
	@qemu-system-i386 -cdrom $(ISO)

# Debug with QEMU (waits for GDB connection)
debug: $(KERNEL)
	@echo "[QEMU] Starting in debug mode..."
	@echo "Connect with: gdb $(KERNEL) -ex 'target remote :1234'"
	@qemu-system-i386 -kernel $(KERNEL) -s -S

# Clean build artifacts
clean:
	@echo "[CLEAN] Removing build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

# Help message
help:
	@echo "Available targets:"
	@echo "  all       - Build the kernel (default)"
	@echo "  iso       - Create bootable ISO"
	@echo "  run       - Run kernel in QEMU"
	@echo "  run-iso   - Run ISO in QEMU"
	@echo "  debug     - Run kernel in QEMU with GDB server"
	@echo "  clean     - Remove build artifacts"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Dependencies:"
	@echo "  - LLVM toolchain in $(TOOLCHAIN_DIR)"
	@echo "  - QEMU (qemu-system-i386) for testing"
	@echo "  - GRUB tools for ISO creation"