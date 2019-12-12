ROOT_DIR=/home/aneury/Desktop/annetteOS/AnnetteOS
INCLUDES_DIR=$(ROOT_DIR)/includes


GCCPARAMS = -m32  -I$(INCLUDES_DIR) -Iinclude -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore -Wno-write-strings
ASPARAMS = --32
LDPARAMS = -melf_i386

CC=gcc
AS=as

TARGET = annette

objects= obj/gboot.o \
         obj/vconsole.o \
		 obj/kernel.o

all: $(objects)
	@echo end building proccess...now linking to the elf
	

obj/%.o: src/boot/%.s
	@mkdir -p $(@D)
	@$(AS) $(ASPARAMS) -o $@ $<
	@echo compiling...$<

obj/%.o: src/kernel/%.cpp
	@mkdir -p $(@D)
	@$(CC) $(GCCPARAMS) -c -o $@ $<
	@echo compiling...$<

clean:
	rm $(objects)