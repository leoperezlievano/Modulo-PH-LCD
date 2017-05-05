MMDIR=../..
include $(MMDIR)/firmware/include.mak

OBJECTS_ALL=divsi3.o libc.o crc16.o crc32.o blockdev.o board.o
OBJECTS=$(OBJECTS_ALL) softfloat.o softfloat-glue.o vsnprintf.o atof.o
OBJECTS_LIGHT=$(OBJECTS_ALL) vsnprintf-nofloat.o

all: libbase-light.a libbase.a

libbase-light.a: $(OBJECTS_LIGHT)
	$(AR) clr libbase-light.a $(OBJECTS_LIGHT)
	$(RANLIB) libbase-light.a

libbase.a: $(OBJECTS)
	$(AR) clr libbase.a $(OBJECTS)
	$(RANLIB) libbase.a

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o libbase.a libbase-light.a .*~ *~ Makefile.bak

# DO NOT DELETE

atof.o: ../../firmware/include/base/stdlib.h
atof.o: ../../firmware/include/base/ctype.h
blockdev.o: ../../firmware/include/hw/flash.h
blockdev.o: ../../firmware/include/hw/memcard.h
blockdev.o: ../../firmware/include/hw/common.h
blockdev.o: ../../firmware/include/base/string.h
blockdev.o: ../../firmware/include/base/stdlib.h
blockdev.o: ../../firmware/include/base/blockdev.h
board.o: ../../firmware/include/hw/sysctl.h
board.o: ../../firmware/include/hw/common.h ../../firmware/include/hw/gpio.h
board.o: ../../firmware/include/base/stdio.h
board.o: ../../firmware/include/base/stdlib.h
board.o: ../../firmware/include/base/board.h
crc16.o: ../../firmware/include/base/crc.h
crc32.o: ../../firmware/include/base/crc.h
libc.o: ../../firmware/include/base/ctype.h
libc.o: ../../firmware/include/base/stdio.h
libc.o: ../../firmware/include/base/stdlib.h
libc.o: ../../firmware/include/base/stdarg.h
libc.o: ../../firmware/include/base/string.h
libc.o: ../../firmware/include/base/limits.h
softfloat.o: milieu.h softfloat.h softfloat-macros.h softfloat-specialize.h
softfloat-glue.o: softfloat.h
vsnprintf.o: ../../firmware/include/base/stdlib.h
vsnprintf.o: ../../firmware/include/base/stdio.h
vsnprintf.o: ../../firmware/include/base/stdarg.h
vsnprintf.o: ../../firmware/include/base/string.h
vsnprintf.o: ../../firmware/include/base/ctype.h
vsnprintf-nofloat.o: ../../firmware/include/base/stdlib.h
vsnprintf-nofloat.o: ../../firmware/include/base/stdio.h
vsnprintf-nofloat.o: ../../firmware/include/base/stdarg.h
vsnprintf-nofloat.o: ../../firmware/include/base/string.h
vsnprintf-nofloat.o: ../../firmware/include/base/ctype.h
