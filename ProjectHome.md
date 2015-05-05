**Installer: Uninstalling Issue**: A number of users have reported that uninstalling Ants from Installer does not work. Please take this issue up with the package maintainer (Ste). You can reach him through is website: http://blog.psmxy.org/ or email ste

&lt;at&gt;

psmxy

&lt;dot&gt;

org.

**SDK Update**: I got some time with an apple SDK engineer (rare opportunity). I was very excited about porting Ants to the SDK, and thought I'd use the opportunity to write version 2.0. Unfortunately, Apple has put a number of restrictions on apps written using the SDK, and the background-nature of Ants violates a couple of those restrictions. So, I will be looking into ways to get around them, and if anybody has ideas, feel free to punt them my way.

**NOTE**: It seems as though the BSD Subsystem package is necessary for ants to run. I'm still investigating as to why. It could be just the existence of `/usr/lib/libarmfp.dylib`, which BSD subsystem installs.

# News #

  * **Sept 10, 2007**: Ants 1.2.0 is out. This'll be the final release before 2.0 (probably). Features include a couple bug fixes, addition of the spawn rate adjuster in the controller app (requested many times). Let me know if there's anything else you'd like to see (besides more bugs - that's already in the plan). You can already start mucking with the details of bugs in `/usr/local/share/ants/bugs.plist`. Just make a backup.

# About #

Interactive "game" which involves ants crawling around on your screen. Based on the principles of A-Life, they react to what you do. Kill them, shake them off, scare them.

### Features ###
  * While you use your phone, ants will appear on screen. You can squish them, among other things.
  * Ants react to nearby death - they get scared.
  * Tilt the phone and shake and they might let go and fall off... or slide around on the screen if the phone is upside down.
  * Low CPU usage when running - when your phone goes to sleep, so does the app.

### Planned Enhancements ###
  * Other bugs.
  * Make it easy for people to add their own bugs.
  * Add food? Maybe other interactions?

### Change Log ###

[Available here](http://code.google.com/p/iphone-ants/wiki/ChangeLog).

# Installation #

Please see [HowToInstall](http://code.google.com/p/iphone-ants/wiki/HowToInstall) for installation instructions.

# Screenshot #

Obligatory:

![http://iphone-ants.googlecode.com/svn/trunk/snaps/ants1.png](http://iphone-ants.googlecode.com/svn/trunk/snaps/ants1.png)