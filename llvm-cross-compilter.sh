#!/bin/bash

set -e  # Exit on error

# Configuration
LLVM_VERSION="18.1.8"
TARGET_ARCH="x86_64"
INSTALL_PREFIX="$(pwd)/toolchain"
BUILD_DIR="$(pwd)/llvm-build"
SOURCE_DIR="$(pwd)/llvm-source"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored message
print_msg() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    print_msg "Checking dependencies..."
    
    local deps=("git" "cmake" "ninja" "python3" "gcc" "g++")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing[*]}"
        print_warn "Install them with:"
        print_warn "  Ubuntu/Debian: sudo apt install git cmake ninja-build python3 build-essential"
        print_warn "  Fedora/RHEL: sudo dnf install git cmake ninja-build python3 gcc gcc-c++"
        print_warn "  Arch: sudo pacman -S git cmake ninja python3 base-devel"
        exit 1
    fi
    
    print_msg "All dependencies satisfied"
}

# Download LLVM sources
download_sources() {
    print_msg "Downloading LLVM ${LLVM_VERSION} sources..."
    
    if [ -d "$SOURCE_DIR" ]; then
        print_warn "Source directory exists. Removing..."
        rm -rf "$SOURCE_DIR"
    fi
    
    mkdir -p "$SOURCE_DIR"
    cd "$SOURCE_DIR"
    
    # Download LLVM project
    print_msg "Cloning LLVM project (this may take a while)..."
    git clone --depth 1 --branch "llvmorg-${LLVM_VERSION}" \
        https://github.com/llvm/llvm-project.git .
    
    print_msg "Sources downloaded successfully"
}

# Build LLVM cross-compiler
build_llvm() {
    print_msg "Building LLVM cross-compiler..."
    print_msg "Target Architecture: ${TARGET_ARCH}"
    print_msg "Install Prefix: ${INSTALL_PREFIX}"
    
    if [ -d "$BUILD_DIR" ]; then
        print_warn "Build directory exists. Removing..."
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Configure LLVM build
    print_msg "Configuring LLVM build with CMake..."
    
    cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DLLVM_ENABLE_PROJECTS="clang;lld" \
        -DLLVM_TARGETS_TO_BUILD="X86;ARM;AArch64;RISCV" \
        -DLLVM_DEFAULT_TARGET_TRIPLE="${TARGET_ARCH}-elf" \
        -DLLVM_ENABLE_ASSERTIONS=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_ENABLE_DOXYGEN=OFF \
        -DLLVM_ENABLE_SPHINX=OFF \
        -DLLVM_OPTIMIZED_TABLEGEN=ON \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_ZLIB=ON \
        -DLLVM_ENABLE_Z3_SOLVER=OFF \
        "$SOURCE_DIR/llvm"
    
    # Build
    print_msg "Building LLVM (this will take a while, grab a coffee)..."
    print_msg "Using $(nproc) parallel jobs"
    
    ninja -j$(nproc)
    
    print_msg "Build completed successfully"
}

# Install LLVM
install_llvm() {
    print_msg "Installing LLVM to ${INSTALL_PREFIX}..."
    
    cd "$BUILD_DIR"
    ninja install
    
    print_msg "Installation completed"
}

# Create helper scripts
create_helpers() {
    print_msg "Creating helper scripts..."
    
    # Create environment setup script
    cat > "$INSTALL_PREFIX/setup-env.sh" << 'EOF'
#!/bin/bash
# Source this file to set up the LLVM cross-compiler environment

TOOLCHAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$TOOLCHAIN_DIR/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN_DIR/lib:$LD_LIBRARY_PATH"

echo "LLVM cross-compiler environment configured"
echo "Toolchain: $TOOLCHAIN_DIR"
echo "Clang version:"
clang --version | head -n1
EOF
    
    chmod +x "$INSTALL_PREFIX/setup-env.sh"
    
    # Create a sample OS build script
    cat > "$INSTALL_PREFIX/example-os-build.sh" << 'EOF'
#!/bin/bash
# Example OS kernel build script using the LLVM cross-compiler

TARGET="x86_64-elf"
TOOLCHAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$TOOLCHAIN_DIR/bin:$PATH"

# Compiler flags for freestanding environment
CFLAGS="-target $TARGET -ffreestanding -nostdlib -fno-builtin -fno-stack-protector"
CFLAGS="$CFLAGS -mno-red-zone -mcmodel=kernel -Wall -Wextra"

# Example kernel compilation
echo "Example: Compiling kernel.c"
echo "clang $CFLAGS -c kernel.c -o kernel.o"
echo ""
echo "Example: Linking kernel"
echo "ld.lld -T linker.ld -o kernel.elf kernel.o"
EOF
    
    chmod +x "$INSTALL_PREFIX/example-os-build.sh"
    
    print_msg "Helper scripts created"
}

# Verify installation
verify_installation() {
    print_msg "Verifying installation..."
    
    if [ ! -f "$INSTALL_PREFIX/bin/clang" ]; then
        print_error "Clang not found in installation"
        exit 1
    fi
    
    if [ ! -f "$INSTALL_PREFIX/bin/ld.lld" ]; then
        print_error "LLD linker not found in installation"
        exit 1
    fi
    
    print_msg "Clang version:"
    "$INSTALL_PREFIX/bin/clang" --version | head -n1
    
    print_msg "LLD version:"
    "$INSTALL_PREFIX/bin/ld.lld" --version | head -n1
    
    print_msg "Available targets:"
    "$INSTALL_PREFIX/bin/llc" --version | grep -A 20 "Registered Targets:"
}

# Cleanup
cleanup() {
    print_msg "Cleaning up build artifacts..."
    
    read -p "Remove source directory? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$SOURCE_DIR"
        print_msg "Source directory removed"
    fi
    
    read -p "Remove build directory? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$BUILD_DIR"
        print_msg "Build directory removed"
    fi
}

# Main execution
main() {
    echo "========================================"
    echo "  LLVM Cross-Compiler Build Script"
    echo "  for OS Development"
    echo "========================================"
    echo ""
    
    print_msg "Configuration:"
    echo "  LLVM Version: $LLVM_VERSION"
    echo "  Target: ${TARGET_ARCH}-elf"
    echo "  Install Prefix: $INSTALL_PREFIX"
    echo "  Build Directory: $BUILD_DIR"
    echo "  Source Directory: $SOURCE_DIR"
    echo ""
    
    read -p "Continue with build? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warn "Build cancelled"
        exit 0
    fi
    
    check_dependencies
    download_sources
    build_llvm
    install_llvm
    create_helpers
    verify_installation
    cleanup
    
    echo ""
    echo "========================================"
    print_msg "Build completed successfully!"
    echo "========================================"
    echo ""
    echo "To use the cross-compiler:"
    echo "  1. Source the environment: source $INSTALL_PREFIX/setup-env.sh"
    echo "  2. Or add to PATH: export PATH=\"$INSTALL_PREFIX/bin:\$PATH\""
    echo ""
    echo "Example usage:"
    echo "  clang -target ${TARGET_ARCH}-elf -ffreestanding -c kernel.c"
    echo "  ld.lld -T linker.ld -o kernel.elf kernel.o"
    echo ""
    echo "See $INSTALL_PREFIX/example-os-build.sh for more examples"
}

# Run main function
main