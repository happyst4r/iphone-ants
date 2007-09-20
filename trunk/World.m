#import "World.h"
#import "Ant.h"
#import "Vector.h"
#import "Common.h"

World *_world;
void initialize(int);

@implementation World

+ (World *) singleton
{
    if (!_world) {
        _world = [[World alloc] init];
    }
    return _world;
}

- (id) init
{
    if ((self = [super init])) {
        tickIntervalM = 0.1f; // start with long tick interval
        objectsM = [[NSMutableArray alloc] init];
        removeListM = [[NSMutableArray alloc] init];
    }

    bugsM = [[NSDictionary alloc] initWithContentsOfFile: BUGS_FILE];

    accelX = accelY = 0.0f; // neutral
    accelZ = -0.5f;

    noAccelCountM = 0;
    gotAccelM = NO;

    urandomM = fopen("/dev/urandom", "r");

    // load stuff from defaults
    defaultsM = [[NSDictionary alloc] initWithContentsOfFile: DEFAULTS_FILE];
    maxBugsM = [[defaultsM valueForKey:@"maxAnts"] intValue];
    accelEnabledM = [[defaultsM valueForKey:@"accelerometer"] intValue] == 1;
    if (maxBugsM < 1) maxBugsM = 4; // default
    else maxBugsM /= (maxBugsM==1?1:2);

    // init bug types and stuff
    NSArray *bugTypes = [bugsM objectForKey:@"bugs"];
    int totalWeight = 0;
    int numBugTypes = [bugTypes count];
    int i;
    for(i = 0, totalSpawnWeightM = 0; i < numBugTypes; i++) {
        int spawnWeight = [[[bugTypes objectAtIndex: i] valueForKey:@"spawnWeight"] intValue];
        if (spawnWeight == 0) spawnWeight = 1;
        totalSpawnWeightM += spawnWeight;
    }
    bugTypesM = numBugTypes;

    spawnNewBugsProbabilityM = 0.2f;
    NSNumber *spawnProbObject = [defaultsM valueForKey:@"spawnRate"];
    if (spawnProbObject) spawnNewBugsProbabilityM = [spawnProbObject floatValue] / 100;
    if (spawnNewBugsProbabilityM < 0.0f) spawnNewBugsProbabilityM = 0.0f;
    if (spawnNewBugsProbabilityM > 1.0f) spawnNewBugsProbabilityM = 1.0f;

    return self;
}

- (id) updateAccelerometerInX: (float)x Y: (float)y Z: (float)z
{
    accelX = x;
    accelY = y;
    accelZ = z;
    gotAccelM = YES;
    //NSLog(@"accel: %f %f %f", x, y, z);
}

- (float) accelX { return accelX; }
- (float) accelY { return accelY; }
- (float) accelZ { return accelZ; }

- (id) dealloc
{
    if (timerM) [timerM invalidate];
    [objectsM release];
    [removeListM release];
    [defaultsM release];

    [super dealloc];
}

- (id) addObject: (id <Agent>) obj
{
    [objectsM addObject: obj];
    return obj;
}

- (id) removeObject: (id <Agent>) obj
{
    [removeListM addObject: obj];
}

- (id) start
{
    [self pause]; // in case "start" is called twice
    // create our timer
    timerM = [NSTimer scheduledTimerWithTimeInterval: tickIntervalM
                target: self
                selector: @selector(tick:)
                userInfo: nil
                repeats: YES];
}

- (id) pause
{
    if (timerM) {
        [timerM invalidate];
        timerM = nil;
    }
}

- (id) restart
{
    [self pause];
    [self start];
}

- (BOOL) adjustTimer
{
    if ([objectsM count] == 0) {
        if (tickIntervalM != 5.0f) {
            tickIntervalM = 5.0f;
            [self restart];
            return YES;
        }
    } else {
        // we have objects, increase timer
        if (tickIntervalM != 0.1f) {
            tickIntervalM = 0.1f;
            [self restart];
            return YES;
        }
    }

    return NO;
}

- (id) tick: (NSTimer *)timer
{
    if (accelEnabledM && !gotAccelM) {
        noAccelCountM++;
        if (noAccelCountM > 15) {
            initialize(10);
            noAccelCountM = 0;
        }
    } else {
        noAccelCountM = 0;
        gotAccelM = NO;
    }

    // calculate dt
    NSDate *now = [[NSDate alloc] init];

    // spawn new bugs?
    int bugCount = [objectsM count];
    if (bugCount < maxBugsM) {
        float rand = [self randomFloat] / 2 + 0.5f;
        if (rand < (spawnNewBugsProbabilityM * (bugCount > 0?0.02f:1.0f))) {
            // how many?
            float randFloat = [self randomFloat] / 2 + 0.5f;
            int cnt = (int) (randFloat * randFloat * maxBugsM);
            //NSLog(@"spawning %d bugs out of %d types", cnt, bugTypesM);
            int i;
            for (i = 0; i < cnt; i++) {
                NSDictionary *bugDescription;
                // need to find the type
                int typeRand = (int) ([self randomFloat] * (float) totalSpawnWeightM);
                int j, runningCount;
                for (j = 0, runningCount = 0; j < bugTypesM; j++) {
                    NSDictionary *maybeBug = [[bugsM objectForKey:@"bugs"] objectAtIndex: j];
                    runningCount += [[maybeBug valueForKey: @"spawnWeight"] intValue];
                    if (runningCount > typeRand) {
                        // this is our bug!
                        bugDescription = maybeBug;
                    }
                }

                CGPoint vel, pos, center;
                center.x = 160.0f;
                center.y = 240.0f;
                // random position outside our screen
                pos.x = ([self randomFloat] - 1.0f) * 15.0f + ([self randomFloat]>0.0f?360.0f:-10.0f);
                if (pos.x > 350.0f) pos.x = 350.0f;
                pos.y = ([self randomFloat] + 1.0f) * 260.0f - 20.0f;
                //pos.y = ([self randomFloat] - 1.0f) * 15.0f + ([self randomFloat]>0.0f?520.0f:0.0f);
                //if (pos.y > 510.0f) pos.y = 510.0f;
                vel = [Vector subtract: pos from: center];
                //NSLog(@"spawn at: (%f,%f) vel: (%f,%f)", pos.x, pos.y, vel.x, vel.y);
                Class bugClass = NSClassFromString([bugDescription objectForKey:@"class"]);
                id bug = [[bugClass alloc] initWithPosition: pos velocity: vel description: bugDescription world: self];
                [self addObject: bug];
            }
        }
    }

    if (lastTimeM) {
        NSTimeInterval timeDelta = [now timeIntervalSinceDate: lastTimeM];
        // throttle timeDelta to 0.2
        if (timeDelta > 0.2f) timeDelta = 0.2f;
        // loop thru our objects, tick them
        int cnt = [objectsM count];
        int i;
        for(i = 0; i < cnt; i++) {
            id <Agent> object = [objectsM objectAtIndex: i];
            [object tickWithTimeDelta: timeDelta];
            // out of bounds?
            CGPoint pos = [object position];
            if (pos.x < -60.0f || pos.y < -60.0f || pos.x > 380.0f || pos.y > 540.0f) {
                // kill the ant!
                //NSLog(@"killing: %d", i);
                [object removeFromWorld];
            }
        }

        // remove all the objects in our remove list
        cnt = [removeListM count];
        for(i = 0; i < cnt; i++) {
            [objectsM removeObject: [removeListM objectAtIndex: i]];
        }

        [removeListM removeAllObjects];
        // done

        [lastTimeM release];
    }

    lastTimeM = now;

    [self adjustTimer];
}

- (id) registerTapAt: (CGPoint) pos
{
    int i, cnt = [objectsM count];
    for(i = 0; i < cnt; i++) {
        NSObject <Agent> *agent = [objectsM objectAtIndex: i];
        [agent registerTapAt: (CGPoint) pos];
    }
}

- (float) randomFloat
{
    int r;
    fread((void *)&r, sizeof(int), 1, urandomM);
    return (float) r / (float) INT_MAX;
}

@end

#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>

typedef struct {} *IOHIDEventSystemRef;
typedef struct {} *IOHIDEventRef;
float IOHIDEventGetFloatValue(IOHIDEventRef ref, int param);

void handleHIDEvent(int a, int b, int c, IOHIDEventRef ptr) {
  int type = IOHIDEventGetType(ptr);

  if (type == 12) {
    float x,y,z;

    x = IOHIDEventGetFloatValue(ptr, 0xc0000);
    y = IOHIDEventGetFloatValue(ptr, 0xc0001);
    z = IOHIDEventGetFloatValue(ptr, 0xc0002);

    // update the world's accel view

    [[World singleton] updateAccelerometerInX: x Y: y Z: z];
  }
}


#define expect(x) if(!x) { printf("failed: %s\n", #x);  return; }



void initialize(int hz) {
  mach_port_t master;
  expect(0 == IOMasterPort(MACH_PORT_NULL, &master));
  int page = 0xff00, usage = 3;

  CFNumberRef nums[2];
  CFStringRef keys[2];
  keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
  keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
  nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
  nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);
  CFDictionaryRef dict = CFDictionaryCreate(0, (const void**)keys, (const void**)nums, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  expect(dict);

  IOHIDEventSystemRef sys = (IOHIDEventSystemRef) IOHIDEventSystemCreate(0);
  expect(sys);

  CFArrayRef srvs = (CFArrayRef)IOHIDEventSystemCopyMatchingServices(sys, dict, 0, 0, 0);
  expect(CFArrayGetCount(srvs)==1);

  io_registry_entry_t serv = (io_registry_entry_t)CFArrayGetValueAtIndex(srvs, 0);
  expect(serv);

  CFStringRef cs = CFStringCreateWithCString(0, "ReportInterval", 0);
  int rv = 1000000/hz;
  CFNumberRef cn = CFNumberCreate(0, kCFNumberSInt32Type, &rv);

  int res = IOHIDServiceSetProperty(serv, cs, cn);
  expect(res == 1);

  res = IOHIDEventSystemOpen(sys, handleHIDEvent, 0, 0);
  expect(res != 0);
}
