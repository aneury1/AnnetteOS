#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
 

void kprintf(const char *buffer){
	unsigned short* videoMemory = (unsigned short*)0xb8000;
	for(int i=0; buffer[i]!='\0';i++){
		videoMemory[i]= (videoMemory[i]& 0xFF00) | buffer[i];
	}
}

extern "C" void kernelMain(void *multiboot_spc, unsigned int magic){
  (void)multiboot_spc;
  (void) magic;
  kprintf("Annette Kernel v0.0.0.1");
}