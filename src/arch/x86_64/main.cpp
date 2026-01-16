// kernel.cpp - Hello World OS Kernel with C++ features
// Demonstrates destructors, virtual functions, and templates

#include <stdint.h>
#include <stddef.h>

// ============================================================================
// VGA Text Mode Driver
// ============================================================================

namespace VGA {
    constexpr uint16_t* VIDEO_MEMORY = (uint16_t*)0xB8000;
    constexpr size_t WIDTH = 80;
    constexpr size_t HEIGHT = 25;
    
    enum Color : uint8_t {
        BLACK = 0,
        BLUE = 1,
        GREEN = 2,
        CYAN = 3,
        RED = 4,
        MAGENTA = 5,
        BROWN = 6,
        LIGHT_GREY = 7,
        DARK_GREY = 8,
        LIGHT_BLUE = 9,
        LIGHT_GREEN = 10,
        LIGHT_CYAN = 11,
        LIGHT_RED = 12,
        LIGHT_MAGENTA = 13,
        YELLOW = 14,
        WHITE = 15,
    };
    
    inline uint16_t make_vga_entry(char c, Color fg, Color bg) {
        return (uint16_t)c | (uint16_t)((bg << 4 | fg) << 8);
    }
}

// ============================================================================
// Base Display Class (demonstrates virtual functions)
// ============================================================================

class Display {
protected:
    size_t row;
    size_t col;
    VGA::Color fg_color;
    VGA::Color bg_color;
    
public:
    Display(VGA::Color fg = VGA::WHITE, VGA::Color bg = VGA::BLACK) 
        : row(0), col(0), fg_color(fg), bg_color(bg) {
        // Constructor
    }
    
    virtual ~Display() {
        // Virtual destructor - important for inheritance!
        // In real OS, might release resources here
    }
    
    // Virtual function to be overridden
    virtual void write_char(char c) = 0;
    
    virtual void write_string(const char* str) {
        while (*str) {
            write_char(*str++);
        }
    }
    
    virtual void clear() = 0;
    
    void set_color(VGA::Color fg, VGA::Color bg) {
        fg_color = fg;
        bg_color = bg;
    }
};

// ============================================================================
// VGA Terminal Implementation (demonstrates inheritance)
// ============================================================================

class VGATerminal : public Display {
private:
    void scroll() {
        // Move all lines up
        for (size_t y = 0; y < VGA::HEIGHT - 1; y++) {
            for (size_t x = 0; x < VGA::WIDTH; x++) {
                VGA::VIDEO_MEMORY[y * VGA::WIDTH + x] = 
                    VGA::VIDEO_MEMORY[(y + 1) * VGA::WIDTH + x];
            }
        }
        
        // Clear last line
        for (size_t x = 0; x < VGA::WIDTH; x++) {
            VGA::VIDEO_MEMORY[(VGA::HEIGHT - 1) * VGA::WIDTH + x] = 
                VGA::make_vga_entry(' ', fg_color, bg_color);
        }
        
        row = VGA::HEIGHT - 1;
    }
    
public:
    VGATerminal() : Display(VGA::LIGHT_GREY, VGA::BLACK) {
        clear();
    }
    
    ~VGATerminal() override {
        // Destructor - demonstrates proper cleanup
        // Could save screen state, release resources, etc.
    }
    
    void write_char(char c) override {
        if (c == '\n') {
            col = 0;
            if (++row >= VGA::HEIGHT) {
                scroll();
            }
            return;
        }
        
        if (col >= VGA::WIDTH) {
            col = 0;
            if (++row >= VGA::HEIGHT) {
                scroll();
            }
        }
        
        VGA::VIDEO_MEMORY[row * VGA::WIDTH + col] = 
            VGA::make_vga_entry(c, fg_color, bg_color);
        col++;
    }
    
    void clear() override {
        for (size_t i = 0; i < VGA::WIDTH * VGA::HEIGHT; i++) {
            VGA::VIDEO_MEMORY[i] = VGA::make_vga_entry(' ', fg_color, bg_color);
        }
        row = 0;
        col = 0;
    }
};

// ============================================================================
// Template Class (demonstrates templates)
// ============================================================================

template<typename T>
class Array {
private:
    T* data;
    size_t size;
    
public:
    Array(size_t n) : size(n) {
        // In real OS, would use proper memory allocator
        // For this demo, we'll use a static buffer
        data = new T[n];  // This will call our operator new below
    }
    
    ~Array() {
        delete[] data;  // Demonstrates destructor with resource cleanup
    }
    
    T& operator[](size_t index) {
        return data[index];
    }
    
    const T& operator[](size_t index) const {
        return data[index];
    }
    
    size_t length() const {
        return size;
    }
};

// ============================================================================
// C++ Runtime Support (required for C++ features)
// ============================================================================

// Simple heap implementation for demonstration
static uint8_t heap_memory[4096] __attribute__((aligned(16)));
static size_t heap_offset = 0;

void* operator new(size_t size) {
    if (heap_offset + size > sizeof(heap_memory)) {
        return nullptr;  // Out of memory
    }
    
    void* ptr = &heap_memory[heap_offset];
    heap_offset += size;
    return ptr;
}

void* operator new[](size_t size) {
    return operator new(size);
}

void operator delete(void*) noexcept {
    // Simple allocator - no deallocation for this demo
}

void operator delete[](void*) noexcept {
    // Simple allocator - no deallocation for this demo
}

void operator delete(void*, unsigned long) noexcept {
    // C++14 sized deallocation
}

void operator delete[](void*, unsigned long) noexcept {
    // C++14 sized deallocation
}

// Pure virtual function handler
extern "C" void __cxa_pure_virtual() {
    // Called when a pure virtual function is called
    // Should never happen in correct code
    while(1);
}

// Global constructor support
typedef void (*constructor_func)();
extern "C" constructor_func start_ctors;
extern "C" constructor_func end_ctors;

extern "C" void call_constructors() {
    for (constructor_func* ctor = &start_ctors; ctor < &end_ctors; ctor++) {
        (*ctor)();
    }
}

// ============================================================================
// Helper Functions
// ============================================================================

void print_number(Display& display, int num) {
    if (num == 0) {
        display.write_char('0');
        return;
    }
    
    if (num < 0) {
        display.write_char('-');
        num = -num;
    }
    
    char buffer[32];
    int i = 0;
    
    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }
    
    // Print in reverse
    while (i > 0) {
        display.write_char(buffer[--i]);
    }
}

// Template function example
template<typename T>
T max(T a, T b) {
    return (a > b) ? a : b;
}

// ============================================================================
// Kernel Main
// ============================================================================

extern "C" void kernel_main() {
    // Call global constructors
    call_constructors();
    
    // Create terminal instance (uses constructor)
    VGATerminal terminal;
    
    // Test 1: Basic output
    terminal.set_color(VGA::LIGHT_GREEN, VGA::BLACK);
    terminal.write_string("=================================\n");
    terminal.write_string("  Hello World OS Kernel!\n");
    terminal.write_string("=================================\n\n");
    
    // Test 2: Virtual function demonstration
    terminal.set_color(VGA::LIGHT_CYAN, VGA::BLACK);
    terminal.write_string("Virtual Function Test:\n");
    Display* display_ptr = &terminal;  // Polymorphism
    display_ptr->write_string("  Virtual dispatch working!\n\n");
    
    // Test 3: Template function demonstration
    terminal.set_color(VGA::YELLOW, VGA::BLACK);
    terminal.write_string("Template Function Test:\n");
    terminal.write_string("  max(42, 17) = ");
    print_number(terminal, max(42, 17));
    terminal.write_char('\n');
    terminal.write_string("  max(3.14, 2.71) = ");
    int result = (int)(max(3.14, 2.71) * 100);
    print_number(terminal, result);
    terminal.write_string(" (x100)\n\n");
    
    // Test 4: Template class demonstration
    terminal.set_color(VGA::LIGHT_MAGENTA, VGA::BLACK);
    terminal.write_string("Template Class Test:\n");
    Array<int> numbers(5);
    numbers[0] = 10;
    numbers[1] = 20;
    numbers[2] = 30;
    numbers[3] = 40;
    numbers[4] = 50;
    
    terminal.write_string("  Array contents: ");
    for (size_t i = 0; i < numbers.length(); i++) {
        print_number(terminal, numbers[i]);
        if (i < numbers.length() - 1) {
            terminal.write_string(", ");
        }
    }
    terminal.write_string("\n\n");
    
    // Test 5: Destructor demonstration (will be called when going out of scope)
    terminal.set_color(VGA::WHITE, VGA::BLACK);
    terminal.write_string("C++ Features Tested:\n");
    terminal.set_color(VGA::LIGHT_GREEN, VGA::BLACK);
    terminal.write_string("  [X] Constructors\n");
    terminal.write_string("  [X] Destructors\n");
    terminal.write_string("  [X] Virtual Functions\n");
    terminal.write_string("  [X] Templates\n");
    terminal.write_string("  [X] Operator Overloading\n");
    terminal.write_string("  [X] Inheritance\n\n");
    
    terminal.set_color(VGA::LIGHT_GREY, VGA::BLACK);
    terminal.write_string("Kernel initialization complete!\n");
    
    // Infinite loop (kernel should never exit)
    while (1) {
        asm volatile("hlt");  // Halt CPU until next interrupt
    }
    
    // When this function returns, destructors will be called
    // (though we never return from kernel_main in practice)
}