INSTALL=/usr/bin/install
CC=$(CROSS_COMPILE)gcc
STRIP=$(CROSS_COMPILE)strip
ply-image: ply-image.c ply-frame-buffer.c checkmodifier.c Makefile
	$(CC) ply-image.c ply-frame-buffer.c -o ply-image -lpng16 -lm -lz $(CPPFLAGS) $(LDFLAGS)
	$(STRIP) ply-image
	$(CC) checkmodifier.c -o checkmodifier
	$(STRIP) checkmodifier

clean:
	rm -f ply-image
	rm -f checkmodifier
