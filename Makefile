LIBPNG=libpng-1.6.34
ZLIB=zlib-1.2.11

NUMCPUS=$(shell grep -c '^processor' /proc/cpuinfo)
URLTOOLS="https://github.com/raspberrypi/tools.git"

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
	CROSS_COMPILE:=$(CURDIR)/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin/$(CROSS_COMPILE)
endif

ifeq ($(RPI_MODEL),rbp1)
	ARCH=armhf
endif

ifeq ($(RPI_MODEL),rbp2)
	ARCH=armhf
endif

ifeq ($(RPI_MODEL),rbp3)
	ARCH=arm64
endif

rbp%:
	RPI_MODEL=$@ $(MAKE) package
	
all: ply-image

ply-image: toolchain zlib libpng
	$(CC) ply-image.c ply-frame-buffer.c -o ply-image -lpng16 -lm -lz -L./depends/lib -I./depends/include
	$(STRIP) ply-image
	$(CC) checkmodifier.c -o checkmodifier
	$(STRIP) checkmodifier

zlib:
	@if [ ! -d $(ZLIB) ];then \
		wget http://www.zlib.net/$(ZLIB).tar.gz; \
		tar -xvf $(ZLIB).tar.gz; \
	fi
	cd $(ZLIB);CC=$(CC) ./configure --prefix=$(shell pwd)/depends;make -j$(NUMCPUS);make install

libpng:
	@if [ ! -d $(LIBPNG) ];then \
		wget ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/$(LIBPNG).tar.gz; \
		tar -xvf $(LIBPNG).tar.gz; \
	fi
	cd $(LIBPNG); \
	./configure --host $(HOST) --prefix=$(shell pwd)/depends CPPFLAGS="-I../depends/include" LDFLAGS="-L../depends/lib" \
	AR=$(AR) CC=$(CC) STRIP=$(STRIP) RANLIB=$(RANLIB) LD=$(LD) NM=$(NM) OBJDUMP=$(OBJDUMP) MT=$(MT) DLLTOOL=$(DLLTOOL); \
	make -j$(NUMCPUS); \
	make install

toolchain:
	@if  [ "$(HOST)" = "arm-linux-gnueabihf" ] && [ ! -d tools ];then \
		echo "Load tools...";\
		git clone $(URLTOOLS) --jobs=$(NUMCPUS) --depth=1 -b master; \
	fi

clean:
	rm -f ply-image
	rm -f checkmodifier
	rm -rf depends/
	rm -rf tools/
	rm -rf $(ZLIB) $(ZLIB).tar.gz*
	rm -rf $(LIBPNG) $(LIBPNG).tar.gz*

package:
	dpkg-buildpackage -us -uc -B -a$(ARCH)

reset:
	debclean
