#include "hardware/io/port.h"


static inline void Write8Slow(u16 _port, u8 _data)
{
     __asm__ volatile("outb %0, %1\njmp 1f\n1: jmp 1f\n1:" : : "a" (_data), "Nd" (_port));
}

void writePort(u8 data, u16 port)
{
  __asm__ volatile("outb %0, %1": :"a"(data), "Nd"(port));
}
void writePort(u16 data, u16 port)
{
    __asm__ volatile("outw %0, %1": :"a"(data), "Nd"(port));
}
void writePort(u32 data, u16 port)
{
    __asm__ volatile("outl %0, %1": :"a"(data), "Nd"(port)); 
}


u8 readPort(u8 data, u16 port)
{
   __asm__ volatile("inb %1, %0" : "=a" (data) : "Nd" (port));
  return data;
}
u16 readPort(u16 data, u16 port)
{
 __asm__ volatile("inw %1, %0" : "=a" (data) : "Nd" (port));
  return data;
}
u32 readPort(u32 data, u16 port)
{               
  __asm__ volatile("inl %1, %0":"=a"(data): "Nd"(port));
  return data;
}