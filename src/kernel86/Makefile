
CPP_PARAMS = -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti -m32
AS_PARAMS = --32
LD_PARAMS = -melf_i386


objects = boot.o kmain.o

annette.bin: linker.ld $(objects)
	echo "Linking...annette.bin"
	$(HOME)/opt/cross/bin/$(TARGET)-ld $(LD_PARAMS) -T $< -o $@ $(objects)

install: annette.bin
	sudo cp $< /boot/annette.bin


%.o: %.cpp
	echo "Compiling...$<"
	$(HOME)/opt/cross/bin/$(TARGET)-g++ $(CPP_PARAMS) -o $@ -c $<

%.o: %.s
	echo "Compiling...$<"
	$(HOME)/opt/cross/bin/$(TARGET)-as $(AS_PARAMS) -o $@ -c $<

clean:
	rm *.o
	rm *.b