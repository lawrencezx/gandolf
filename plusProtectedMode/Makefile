#Makefile for plusProtectedMode

# Programs, etc.
ASM = nasm

# This Program 
IMG     :=a.img
BOOT		:=boot.asm 
LDR			:=loader.asm 
BOOT_BIN:= $(subst .asm,.bin,$(BOOT))
LDR_BIN	:= $(subst .asm,.bin,$(LDR)) 

# All Phony Targets
.PHONY : everything clean all

# Default starting position
everything : $(BOOT_BIN) $(LDR_BIN) 
	dd if=$(BOOT_BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(IMG) /mnt/floppy/
	sudo cp $(LDR_BIN) /mnt/floppy/ -v
	sudo umount /mnt/floppy

clean :
	rm -f *.bin

all : clean everything

$(BOOT_BIN) : $(BOOT)
	$(ASM) -o $@ $<

$(LDR_BIN) : $(LDR)
	$(ASM) -o $@ $<

