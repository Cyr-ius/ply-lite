LIBPNG=libpng-1.6.34
ZLIB=zlib-1.2.11

NUMCPUS=$(shell grep -c '^processor' /proc/cpuinfo)
CROSS_COMPILE?=$(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
HOST=$(shell basename $(CROSS_COMPILE))

AR=$(CROSS_COMPILE)-ar
CC=$(CROSS_COMPILE)-gcc
STRIP=$(CROSS_COMPILE)-strip
RANLIB=$(CROSS_COMPILE)-ranlib
LD=$(CROSS_COMPILE)-ld
NM=$(CROSS_COMPILE)-nm
OBJDUMP=$(CROSS_COMPILE)-objdump
MT=$(CROSS_COMPILE)-mt
DLLTOOL=$(CROSS_COMPILE)-dlltool

ifeq ($(HOST),arm-linux-gnueabihf)
	CROSS_COMPILE:=$(shell pwd)/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/$(CROSS_COMPILE)
endif

ply-image: toolchain zlib libpng
	$(CC) ply-image.c ply-frame-buffer.c -o ply-image -lpng16 -lm -lz -L./depends/lib -I./depends/include
	$(STRIP) ply-image
	$(CC) checkmodifier.c -o checkmodifier
	$(STRIP) checkmodifier

zlib:
	wget http://www.zlib.net/$(ZLIB).tar.gz
	tar -xvf $(ZLIB).tar.gz
	cd $(ZLIB);CHOST=$(CROSS_COMPILE) ./configure --prefix=$(shell pwd)/depends;make -j$(NUMCPUS);make install

libpng:
	wget ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/$(LIBPNG).tar.gz 
	tar -xvf $(LIBPNG).tar.gz
	cd $(LIBPNG); \
	./configure --host $(HOST) --prefix=$(shell pwd)/depends CPPFLAGS="-I../depends/include" LDFLAGS="-L../depends/lib" \
	AR=$(AR) CC=$(CC) STRIP=$(STRIP) RANLIB=$(RANLIB) LD=$(LD) NM=$(NM) OBJDUMP=$(OBJDUMP) MT=$(MT) DLLTOOL=$(DLLTOOL); \
	make -j$(NUMCPUS); \
	make install

toolchain:
	@if  [ "$(HOST)" = "arm-linux-gnueabihf" ] && [ ! -d tools ];then \
		echo "Load tools...";\
		git clone git://github.com/raspberrypi/tools.git --jobs=$(NUMCPUS) --depth=1 -b master; \
	fi

clean:
	rm -f ply-image
	rm -f checkmodifier
	rm -rf depends/
	rm -rf tools/
	rm -rf $(ZLIB) $(ZLIB).tar.gz*
	rm -rf $(LIBPNG) $(LIBPNG).tar.gz*