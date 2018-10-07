#Makefile for helloOS

# Programs, etc.
ASM = nasm

# This Program 
TARGET = boot.bin 
IMG = a.img

# All Phony Targets
.PHONY : everything clean all

# Default starting position
everything : $(TARGET) $(IMG)

clean :
	rm -f $(TARGET)

all : clean everything

boot.bin : boot.asm
	$(ASM) -o $@ $<

a.img : boot.bin
	dd if=$< of=$@ bs=512 count=1
