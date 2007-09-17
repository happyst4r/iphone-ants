
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
    worldM = [World singleton];

    //NSLog(@"starting world");
    [worldM start];

    //NSLog(@"loaded");
}

- (void) applicationWillSuspend
{
    [worldM pause];
    NSLog(@"pausing: suspend");
}

- (void) applicationWillTerminate
{
    [worldM pause];
    NSLog(@"pausing: terminate");
}

- (void) willSleep {
	[worldM pause];
    NSLog(@"pausing: sleep");
}

- (void) didWake {
	[worldM start];
    NSLog(@"starting: wake");
}

@end

