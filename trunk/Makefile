CC=arm-apple-darwin-gcc
LD=$(CC) 
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework Celestial -framework UIKit -framework LayerKit -framework CoreGraphics -framework GraphicsServices -framework WebCore -framework IOKit

default: ants

#all: dock pxl iapp
all: ants

archives: ants
	mkdir -p usr/local/bin
	mkdir -p usr/local/share/ants
	mkdir -p Library/LaunchDaemons
	cp ants usr/local/bin/
	cp net.schine.ants.plist Library/LaunchDaemons/
	cp ant_sprites/*.png usr/local/share/ants/
	rm -f Ants.zip
	rm -f ants.tar.gz
	zip -r Ants.zip usr Library
	tar -z -c -f ants.tar.gz usr Library
	rm -rf usr
	rm -rf Library

ants: mainapp.o AntsApp.o Ant.o World.o Behaviors.o Vector.o
	$(LD) $(LDFLAGS) -v -o $@ $^

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f *.o ants 
