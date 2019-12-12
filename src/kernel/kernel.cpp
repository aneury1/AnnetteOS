#include "gnu/gtypes.h"
#include "kernel/vconsole.h"

extern "C"
void kernel_main(void) 
{
   kcls();
   kprintf("AnnetteOS V0.0.01b");
}
