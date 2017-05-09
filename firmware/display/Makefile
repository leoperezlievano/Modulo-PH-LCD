MMDIR=../..
include $(MMDIR)/firmware/include.mak

OBJECTS=crt0ram.o main.o soc-hw.o 
SEGMENTS= -j .text -j .rodata -j .data
LIBS=$(MMDIR)/firmware/libbase/libbase-light.a 

SREC2VRAM ?= ../../tools/srec2vram/srec2vram

all: image.ram

%.ram: %.srec
	$(MAKE) -C $(MMDIR)/tools/srec2vram/
	$(SREC2VRAM) $< 0x00000000 0x4000 > $@
	cat image.ram | cut -c 1-2 > image3.ram
	cat image.ram | cut -c 3-4 > image2.ram
	cat image.ram | cut -c 5-6 > image1.ram
	cat image.ram | cut -c 7-8 > image0.ram

%.srec: %.elf
	$(OBJCOPY) $(SEGMENTS) -O srec $< $@

%.lst: %.elf
	$(OBJDUMP) -h -S $< > $@

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@
	chmod -x $@

image.elf: linker.ld $(OBJECTS) $(LIBS)

%.elf:
	$(LD) $(LDFLAGS) -T $< -N -o $@ $(OBJECTS) -L$(MMDIR)/firmware/libbase --start-group -lbase-light --end-group
	chmod -x $@

$(MMDIR)/firmware/libbase/libbase-light.a:
	make -C $(MMDIR)/firmware/libbase/

.PHONY: clean depend $(LIBS)

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o *.elf *.bin *.lst *.srec *.ram .*~ *~ Makefile.bak

# DO NOT DELETE

main.o: ../../firmware/include/base/stdio.h
main.o: ../../firmware/include/base/string.h
