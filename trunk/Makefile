CC=arm-apple-darwin-gcc
LD=$(CC) 
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework Celestial -framework UIKit -framework LayerKit -framework CoreGraphics -framework GraphicsServices -framework WebCore -framework IOKit

VERSION=1.0.2

default: ants

#all: dock pxl iapp
all: ants

pxl: ants
	mkdir bin
	mkdir share
	mkdir launchdaemons
	cp ants bin
	cp ant_sprites/*.png share
	cp net.schine.ants.plist launchdaemons
	rm -f Ants${VERSION}.pxl 
	zip -r Ants${VERSION}.pxl PxlPkg.plist bin share launchdaemons
	rm -rf bin share launchdaemons


archives: ants
	mkdir -p usr/local/bin
	mkdir -p usr/local/share/ants
	mkdir -p Library/LaunchDaemons
	cp ants usr/local/bin/
	cp net.schine.ants.plist Library/LaunchDaemons/
	cp ant_sprites/*.png usr/local/share/ants/
	rm -f Ants${VERSION}.zip
	rm -f ants${VERSION}.tar.gz
	zip -r Ants${VERSION}.zip usr Library
	tar -z -c -f ants${VERSION}.tar.gz usr Library
	rm -rf usr
	rm -rf Library

ants: mainapp.o AntsApp.o Ant.o World.o Behaviors.o Vector.o
	$(LD) $(LDFLAGS) -v -o $@ $^

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f *.o ants 
