/* linker.ld - Linker script for the kernel */

ENTRY(_start)

SECTIONS
{
    /* Kernel starts at 1MB in physical memory */
    . = 1M;
    
    /* Multiboot header comes first */
    .multiboot ALIGN(4K) : {
        *(.multiboot)
    }
    
    /* Read-only data */
    .rodata ALIGN(4K) : {
        *(.rodata*)
    }
    
    /* Code section */
    .text ALIGN(4K) : {
        *(.text*)
    }
    
    /* Global constructors */
    .init_array ALIGN(8) : {
        start_ctors = .;
        KEEP(*(.init_array*))
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        end_ctors = .;
    }
    
    /* Global destructors */
    .fini_array ALIGN(8) : {
        start_dtors = .;
        KEEP(*(.fini_array*))
        KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*)))
        end_dtors = .;
    }
    
    /* Read-write data */
    .data ALIGN(4K) : {
        *(.data*)
    }
    
    /* Uninitialized data */
    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss*)
    }
    
    /* Stack grows downward */
    .stack ALIGN(16) : {
        *(.stack*)
    }
}