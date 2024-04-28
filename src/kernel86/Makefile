
CPP_PARAMS = -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -m32
AS_PARAMS = --32
LD_PARAMS = -melf_i386


objects = boot.o kmain.o screen.o terminal.o


# runvm: annette.iso
# 	virtualbox --startvm AnnetteOS &

annette.iso: annette.bin
	@mkdir -p ../../iso
	@mkdir -p ../../iso/boot
	@mkdir -p ../../iso/boot/grub
	@cp annette.bin ../../iso/boot/annette.bin
	@rm ../../iso/boot/grub/grub.cfg
	@echo 'set timeout=0' >>  ../../iso/boot/grub/grub.cfg
	@echo 'set default=0' >>  ../../iso/boot/grub/grub.cfg
	@echo ' ' >>  ../../iso/boot/grub/grub.cfg
	@echo 'menuentry "AnnetteOS "{' >>  ../../iso/boot/grub/grub.cfg
	@echo '	multiboot /boot/annette.bin' >>  ../../iso/boot/grub/grub.cfg
	@echo '  boot' >>  ../../iso/boot/grub/grub.cfg
	@echo '}' >>  ../../iso/boot/grub/grub.cfg
	@echo ' ' >>  ../../iso/boot/grub/grub.cfg
	@echo ' ' >>  ../../iso/boot/grub/grub.cfg
	grub-mkrescue --output=../../$@ ../../iso/


annette.bin: linker.ld $(objects)
	@echo "Linking...annette.bin"
	@$(HOME)/opt/cross/bin/$(TARGET)-ld $(LD_PARAMS) -T $< -o $@ $(objects)

install: annette.bin
	@sudo cp $< /boot/annette.bin


%.o: %.cpp
	@echo "Compiling...$<"
	@$(HOME)/opt/cross/bin/$(TARGET)-g++ $(CPP_PARAMS) -o $@ -c $<

%.o: %.s
	@echo "Compiling...$<"
	@$(HOME)/opt/cross/bin/$(TARGET)-as $(AS_PARAMS) -o $@ -c $<

clean:
	rm -rf *.o
	rm -rf *.bin
	rm -rf *.iso