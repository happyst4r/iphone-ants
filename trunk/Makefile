CC=arm-apple-darwin-gcc
LD=$(CC) 
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework Celestial -framework UIKit -framework LayerKit -framework CoreGraphics -framework GraphicsServices -framework WebCore -framework IOKit

VERSION=1.2.0

default: all

all: ants AntsControllerApp

AntsControllerApp: AntsController
	rm -rf Ants.app
	mkdir Ants.app
	cp AntsController Default.png Info.plist Ants.app
	cp AntsIcon.png Ants.app/icon.png

dist: version pxl archives

version:
	bash new_version.sh

pxl: ants AntsControllerApp
	mkdir bin
	mkdir share
	mkdir launchdaemons
	cp -r Ants.app app
	cp ants bin
	cp DaemonInfo.plist bin/Info.plist
	cp ant_sprites/*.png bugs.plist share
	cp net.schine.ants.plist launchdaemons
	rm -f Ants${VERSION}.pxl 
	zip -r Ants${VERSION}.pxl PxlPkg.plist bin share launchdaemons app
	rm -rf bin share launchdaemons app


archives: ants AntsControllerApp
	mkdir -p usr/local/bin/ants_daemon
	mkdir -p usr/local/share/ants
	mkdir -p Library/LaunchDaemons
	mkdir -p Applications
	cp -r Ants.app Applications
	cp ants usr/local/bin/ants_daemon
	cp DaemonInfo.plist usr/local/bin/ants_daemon/Info.plist
	cp net.schine.ants.plist Library/LaunchDaemons/
	cp ant_sprites/*.png bugs.plist usr/local/share/ants/
	rm -f Ants${VERSION}.zip
	rm -f ants${VERSION}.tar.gz
	zip -r Ants${VERSION}.zip usr Library Applications
	tar -z -c -f ants${VERSION}.tar.gz usr Library Applications
	rm -rf Library Applications usr

accel_test: accel_test.o
	$(LD) $(LDFLAGS) -v -o $@ $^

ants: mainapp.o AntsApp.o Ant.o World.o Behaviors.o Vector.o Sprites.o
	$(LD) $(LDFLAGS) -v -o $@ $^

AntsController: mainController.o AntsControllerApp.o
	$(LD) $(LDFLAGS) -v -o $@ $^

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -rf *.o ants Ants.app

distclean: clean
	rm -f *.pxl *.zip *.gz
