NUMCPUS=$(shell grep -c '^processor' /proc/cpuinfo)
CROSS_COMPILE ?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
DEPENDS=$(shell pwd)/depends
CC=$(CROSS_COMPILE)-gcc
STRIP=$(CROSS_COMPILE)-strip

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
	cd $(ZLIB);CC=$(CC) ./configure --prefix=$(DEPENDS);make -j$(NUMCPUS);make install

libpng:
	wget ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/$(LIBPNG).tar.gz 
	tar -xvf $(LIBPNG).tar.gz
	cd $(LIBPNG);./configure --host $(CROSS_COMPILE) --prefix=$(DEPENDS) CPPFLAGS="-I$(DEPENDS)/include" LDFLAGS="-L$(DEPENDS)/lib";make -j$(NUMCPUS);make install

clean:
	rm -f ply-image
	rm -f checkmodifier
	rm -rf depends/
	rm -rf $(ZLIB) $(ZLIB).tar.gz*
	rm -rf $(LIBPNG) $(LIBPNG).tar.gz*