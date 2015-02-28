all:
	echo -e "Specify a target:\nmake armv6l\nmake armv7\nmake i386\n"

armv6l:
	sudo bash build.sh "armv6l"

armv7:
	sudo bash build.sh "armv7"

i386:
	sudo bash build.sh "i386"

clean:
	sudo rm -f *.deb > /dev/null 2>&1
	sudo rm -rf files/usr > /dev/null 2>&1
	sudo rm -f src/ply-image >/dev/null 2>&1
