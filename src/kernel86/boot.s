/*
   simple Kernel 
*/

.set MAGIC, 0X1BADB002
.set FLAGS, (1<<0|1<<1)
.set CHECKSUM, -(FLAGS + MAGIC)



.section .multiboot
   .long MAGIC
   .long FLAGS
   .long CHECKSUM


.section .text
.extern kernelMain
.extern call_in_stage_1
.global loader

loader: 
   mov $kernel_stack, %esp
   call call_in_stage_1
   push %eax
   push %ebx
   call kernelMain

/* this is an loop. */
_stop:
   cli
   hlt
   jmp _stop

.section .bss
.space 2*1024*1024; # 2mib
kernel_stack:

