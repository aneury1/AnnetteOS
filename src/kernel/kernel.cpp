#include "gnu/gtypes.h"
#include "kernel/vconsole.h"

#ifdef __INTEL_CPU
#include "hardware/x86/GDT.h"
static void init_hw(){

}
#else
#warning "by now only intel would be supported"
static void init_hw(){
   kprintf("\nthis hardware is not yet supported");  
}
#endif


extern "C"
void kernel_main(void) 
{
   kcls();
   kprintf("AnnetteOS V0.0.01b");
   init_hw();
}
