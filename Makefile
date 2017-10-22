current_dir = $(shell pwd)
NUMCPUS=$(shell grep -c '^processor' /proc/cpuinfo)
DEB_HOST_GNU_TYPE   ?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
CROSS_COMPILE ?= $(DEB_HOST_GNU_TYPE)
DEPENDS=$(current_dir)/depends
HOST=--host $(CROSS_COMPILE)
XCOMPILE=$(CROSS_COMPILE)-
CC=$(XCOMPILE)gcc
STRIP=$(XCOMPILE)strip
AS=$(XCOMPILE)as
LD=$(XCOMPILE)ld
AR=$(XCOMPILE)ar
RANLIB=$(CROSS_COMPILE)-ranlib

LIBPNG=libpng-1.6.34
ZLIB=zlib-1.2.11

ply-image: zlib libpng
	$(CC) ply-image.c ply-frame-buffer.c -o ply-image -lpng16 -lm -lz -L$(DEPENDS)/lib -I$(DEPENDS)/include
	$(STRIP) ply-image
	$(CC) checkmodifier.c -o checkmodifier
	$(STRIP) checkmodifier

zlib:
	wget http://www.zlib.net/$(ZLIB).tar.gz
	tar -xvf $(ZLIB).tar.gz
	cd $(ZLIB);AS=$(AS) LD=$(LD) CC=$(CC) ./configure --prefix=$(DEPENDS);make -j$(NUMCPUS);make install

libpng:
	wget ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/$(LIBPNG).tar.gz 
	tar -xvf $(LIBPNG).tar.gz
	cd $(LIBPNG);./configure $(HOST) --prefix=$(DEPENDS) CC=$(CC) AR=$(AR) STRIP=$(STRIP) RANLIB=$(RANLIB) CPPFLAGS="-I$(DEPENDS)/include" LDFLAGS="-L$(DEPENDS)/lib";make -j$(NUMCPUS);make install

clean:
	rm -f ply-image
	rm -f checkmodifier
	rm -rf depends/
	rm -rf $(ZLIB) $(ZLIB).tar.gz*
	rm -rf $(LIBPNG) $(LIBPNG).tar.gz*