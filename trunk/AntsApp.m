
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
//    Ant *a = [[Ant alloc] initWithX: 0.0f Y: 0.0f world: worldM];
    Ant *b = [[Ant alloc] initWithX: 150.0f Y: 240.0f world: worldM];

    NSLog(@"adding objects");
//    [worldM addObject: a];
    [worldM addObject: b];

    NSLog(@"starting world");
    [worldM start];

    NSLog(@"loaded");
}

- (void) statusBarMouseDown: (struct __GSEvent *) ev {
    NSLog(@"Statusbar");
}

- (void) applicationWillSuspend
{
    NSLog(@"willsuspend");
}

- (void) willSleep {
	NSLog(@"willsleep");
}

- (void) didWake {
	NSLog(@"didwake");
}

@end
