ROOT_DIR=/home/aneury/Desktop/annetteOS/AnnetteOS
INCLUDES_DIR=$(ROOT_DIR)/includes

CPPPARAMS = -I$(INCLUDES_DIR) -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
GCCPARAMS = -m32  -I$(INCLUDES_DIR) -Iinclude -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore -Wno-write-strings
ASPARAMS = --32
LDPARAMS = -melf_i386

CC=i686-elf-gcc
AS=i686-elf-as
LD_TOOL=i686-elf-ld

TARGET = annette.bin
ISO_FILE = annette.iso

objects= obj/gboot.o \
         obj/vconsole.o \
		 obj/kernel.o

all: $(ISO_FILE) $(objects) $(TARGET)
	@echo end building proccess...now linking to the elf

$(TARGET): linker.ld $(objects)
	$(LD_TOOL) $(LDPARAMS) -T $< -o $@ $(objects)

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

$(ISO_FILE):$(TARGET)
	mkdir -p isodir/boot/grub
	cp $(TARGET) isodir/boot/$(TARGET)
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO_FILE) isodir