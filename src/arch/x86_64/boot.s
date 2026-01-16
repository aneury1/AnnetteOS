/* boot.s - Multiboot2 compatible boot code for x86_64 */

.set MAGIC,    0xe85250d6              /* Multiboot2 magic number */
.set ARCH,     0                       /* i386 architecture */
.set HEADER_LENGTH, header_end - header_start
.set CHECKSUM, -(MAGIC + ARCH + HEADER_LENGTH)

.section .multiboot
.align 8
header_start:
    .long MAGIC
    .long ARCH
    .long HEADER_LENGTH
    .long CHECKSUM
    
    /* End tag */
    .short 0
    .short 0
    .long 8
header_end:

/* Reserve stack space */
.section .bss
.align 16
stack_bottom:
    .skip 16384  /* 16 KB stack */
stack_top:

/* Global constructor arrays */
.section .init_array
.global start_ctors
start_ctors:

.section .fini_array
.global end_ctors
end_ctors:

/* Entry point */
.section .text
.global _start
.type _start, @function

_start:
    /* Set up stack */
    mov $stack_top, %esp
    
    /* Reset EFLAGS */
    pushl $0
    popf
    
    /* Call global constructors */
    call call_constructors
    
    /* Call kernel main */
    call kernel_main
    
    /* If kernel_main returns, halt */
    cli
1:
    hlt
    jmp 1b

/* Set size of _start symbol */
.size _start, . - _start