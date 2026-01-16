#include <stdint.h>
#include <cstddef>
namespace VGA {
    constexpr uint16_t WIDTH  = 80;
    constexpr uint16_t HEIGHT = 25;

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
        LIGHT_BROWN = 14,
        WHITE = 15,
    };

    void clear(uint8_t color = WHITE);
    void putchar(char c, uint8_t color = WHITE);
    void write(const char* str, uint8_t color = WHITE);
}

static uint16_t* const VGA_MEMORY = (uint16_t*)0xB8000;
static uint16_t cursor_x = 0;
static uint16_t cursor_y = 0;

static uint16_t vga_entry(char c, uint8_t color) {
    return (uint16_t)c | (uint16_t(color) << 8);
}

namespace VGA {

void clear(uint8_t color) {
    for (uint16_t y = 0; y < HEIGHT; y++) {
        for (uint16_t x = 0; x < WIDTH; x++) {
            VGA_MEMORY[y * WIDTH + x] = vga_entry(' ', color);
        }
    }
    cursor_x = 0;
    cursor_y = 0;
}

void putchar(char c, uint8_t color) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
        return;
    }

    VGA_MEMORY[cursor_y * WIDTH + cursor_x] = vga_entry(c, color);
    cursor_x++;

    if (cursor_x >= WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }

    if (cursor_y >= HEIGHT) {
        cursor_y = 0; // scroll simple (luego se mejora)
    }
}

void write(const char* str, uint8_t color) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        putchar(str[i], color);
    }
}

}


extern "C" void kernel_main(void) 
{
    VGA::clear(VGA::WHITE);
    VGA::write("AnnetteOS booted successfully\n", VGA::LIGHT_GREEN);
    VGA::write("VGA output working! v2\n", VGA::LIGHT_CYAN);
    while (1) 
    {
        asm volatile ("hlt");
    }
}