#import "World.h"
#import "Ant.h"
#import "Vector.h"

#define SPAWN_NEW_ANTS_PROBABILITY 0.4f
#define MAX_ANTS 8

World *_world;

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

    accelX = accelY = 0.5f; // neutral
    accelZ = 0.0f;

    urandomM = fopen("/dev/urandom", "r");

    return self;
}

- (id) updateAccelerometerInX: (float)x Y: (float)y Z: (float)z
{
    accelX = x;
    accelY = y;
    accelZ = z;
}

- (float) accelX { return accelX; }
- (float) accelY { return accelY; }
- (float) accelZ { return accelZ; }

- (id) dealloc
{
    if (timerM) [timerM invalidate];
    [objectsM release];
    [removeListM release];

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
    // calculate dt
    NSDate *now = [[NSDate alloc] init];

    // spawn new ants?
    int antCount = [objectsM count];
    if (antCount < MAX_ANTS) {
        float rand = [self randomFloat] / 2 + 0.5f;
        if (rand < (SPAWN_NEW_ANTS_PROBABILITY * (antCount > 0?0.02f:1.0f))) {
            // how many?
            int cnt = (int) (([self randomFloat] / 2 + 0.5f) * MAX_ANTS);
            int i;
            for (i = 0; i < cnt; i++) {
                CGPoint vel;
                CGPoint pos;
                CGPoint center;
                center.x = 160.0f;
                center.y = 240.0f;
                // random position outside our screen
                pos.x = ([self randomFloat] - 1.0f) * 15.0f + ([self randomFloat]>0.0f?360.0f:0.0f);
                if (pos.x > 350.0f) pos.x = 350.0f;
                pos.y = ([self randomFloat] + 1.0f) * 260.0f - 20.0f;
                //pos.y = ([self randomFloat] - 1.0f) * 15.0f + ([self randomFloat]>0.0f?520.0f:0.0f);
                //if (pos.y > 510.0f) pos.y = 510.0f;
                vel = [Vector subtract: pos from: center];
                //NSLog(@"spawn at: (%f,%f) vel: (%f,%f)", pos.x, pos.y, vel.x, vel.y);
                Ant *ant = [[Ant alloc] initWithPosition: pos velocity: vel world: self];
                [ant setBehavior: [[[WanderBehavior alloc] init] autorelease]];
                [self addObject: ant];
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
    //NSLog(@"Tap at %f, %f", pos.x, pos.y);
    // anybody nearby?
    int i, cnt = [objectsM count];
    for(i = 0; i < cnt; i++) {
        NSObject <Agent> *agent = [objectsM objectAtIndex: i];
        CGPoint diffVector = [Vector subtract: [agent position] from: pos];
        if ([Vector lengthSquared: diffVector] < 10000.0f) {
            [agent setBehavior: [[[FleeBehavior alloc] initWithPoint: pos] autorelease]];
            [agent setMaxVelocity: 60.0f];
        }
    }
}

- (float) randomFloat
{
    int r;
    fread((void *)&r, sizeof(int), 1, urandomM);
    return (float) r / (float) INT_MAX;
}

@end
