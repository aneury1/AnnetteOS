#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "kmain.h"
#include "screen.h"
#include "terminal.h"


typedef void (*globalCalls)();
extern "C" globalCalls start_ctors;
extern "C" globalCalls end_ctors;

extern "C" void call_in_stage_1(){
	for(globalCalls* i =&start_ctors; *i!=end_ctors;i++)
		(*i)();
}

 
 
extern "C" void kernelMain(multiboot_info *multiboot_spc, unsigned int magic){
    multiboot_spc;
    magic;
  terminal_initialize();
  
  kprintf("AnnetteOS V0.0.0.1\n");
  terminal_setcolor(VGA_COLOR_BLUE);
  kprintf("--------------------------------------------------\n");
  terminal_setcolor(VGA_COLOR_LIGHT_MAGENTA);
  kprintf("low_mem: %d\nhigh_memory: %d\n", multiboot_spc->low_mem, multiboot_spc->high_mem);


  while(1);
}