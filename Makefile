CC=arm-apple-darwin-gcc
LD=$(CC) 
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework Celestial -framework UIKit -framework LayerKit -framework CoreGraphics -framework GraphicsServices -framework WebCore

default: ants

#all: dock pxl iapp
all: ants

pxl: dock
	mkdir bin
	cp dock sunny.png camera.png cancel.png blacky.png dockicon.png bin
	mkdir launchdaemons
	cp com.natetrue.dock.plist launchdaemons
	rm -f Dock.pxl
	zip -r Dock.pxl PxlPkg.plist bin launchdaemons
	rm -rf bin
	rm -rf launchdaemons
	
iapp: dock
	mkdir -p usr/local/bin/dock
	mkdir -p Library/LaunchDaemons
	cp dock sunny.png camera.png cancel.png blacky.png usr/local/bin/dock/
	cp com.natetrue.dock.plist Library/LaunchDaemons/
	rm -f Dock.zip
	zip -r Dock.zip usr Library
	rm -rf usr
	rm -rf Library

ants: mainapp.o AntsApp.o Ant.o World.o Behaviors.o Vector.o
	$(LD) $(LDFLAGS) -v -o $@ $^

%.o: %.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f *.o ants 
