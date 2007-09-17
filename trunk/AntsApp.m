
#import "AntsApp.h"
#import "Ant.h"
#import "World.h"

#include <math.h>

int SBGetTopDisplayID();

int springboard_pid();

#define fadeinspeed 10
#define fadeoutspeed 40
#define selspeed 10

@implementation AntsApp


- (void) applicationDidFinishLaunching: (id) unused
{
    worldM = [[World alloc] init];

    //NSLog(@"starting world");
    [worldM start];

    //NSLog(@"loaded");
}

- (void) applicationWillSuspend
{
    [worldM pause];
}

- (void) willSleep {
	[worldM pause];
}

- (void) didWake {
	[worldM start];
}

@end
