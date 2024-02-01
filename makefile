# Automatically generate lists of sources using wildcards.
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# TODO: Make sources dependent on all header files

# Convert the *.c filenames to *.o to give a list of object files
# to build
OBJ = ${C_SOURCES:.c=.o}

# Default build target
all: os-image

# Run qemu to simulate booting the code
run: all
	qemu-system-x86_64 -fda os-image

# This is the actual disk image that the computer loads
# which is the combination of our compiled bootsector and kernel
# TODO: Figure out a way to make this copy dependent on prereq's
#       OR use a different command (something from linux?)
os-image: boot/boot_sect.bin kernel.bin
	copy /b boot\boot_sect.bin+kernel.bin os-image

kernel.bin: kernel.tmp
	objcopy -O binary -j .text $^ $@

# This builds the binary of our kernel from two object files:
#  - the kernel_entry, which jumps to main() in our kernel
#  - the compiled C kernel
kernel.tmp: kernel/kernel_entry.o ${OBJ}
	ld -T NUL -o $@ -Ttext 0x1000 $^


# Generic rule for compiling C code to an object file
# For simplicity, C files will depend on all header files
%.o : %.c ${HEADERS}
	gcc -ffreestanding -c $< -o $@

# Assemble the kernel_entry
%.o : %.asm
	nasm $< -f elf -o $@

%.bin : %.asm
	nasm $< -f bin -I '../../16bit/' -o $@
# nasm $< -f bin -o $@

clean:
	del /f /q *.bin *.tmp *.o os-image
	del /f /q kernel\*.o boot\*.bin drivers\*.o