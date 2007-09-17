#import "World.h"
#import "Ant.h"
#import "Vector.h"

#define SPAWN_NEW_ANTS_PROBABILITY 0.5f
#define MAX_ANTS 5

@implementation World

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
    }
}

- (id) restart
{
    [self pause];
    [self start];
}

- (id) adjustTimer
{
    if ([objectsM count] == 0) {
        if (tickIntervalM != 5.0f) {
            tickIntervalM = 5.0f;
            [self restart];
        }
    } else {
        // we have objects, increase timer
        if (tickIntervalM != 0.1f) {
            tickIntervalM = 0.1f;
            [self restart];
        }
    }
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
                vel.x = vel.y = 0.01f;
                CGPoint pos;
                pos.x = 150.0f;
                pos.y = 240.0f;
                Ant *ant = [[Ant alloc] initWithPosition: pos velocity: vel world: self];
                [ant setBehavior: [[[WanderBehavior alloc] init] autorelease]];
                [self addObject: ant];
            }
        }
    }

    if (lastTimeM) {
        NSTimeInterval timeDelta = [now timeIntervalSinceDate: lastTimeM];
        // loop thru our objects, tick them
        int cnt = [objectsM count];
        int i;
        for(i = 0; i < cnt; i++) {
            id <Agent> object = [objectsM objectAtIndex: i];
            [object tickWithTimeDelta: timeDelta];
            // out of bounds?
            // TODO
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
    NSLog(@"Tap at %f, %f", pos.x, pos.y);
    // anybody nearby?
    int i, cnt = [objectsM count];
    for(i = 0; i < cnt; i++) {
        NSObject <Agent> *agent = [objectsM objectAtIndex: i];
        CGPoint diffVector = [Vector subtract: [agent position] from: pos];
        NSLog(@"Agent %d is this far away: %f", i, [Vector lengthSquared: diffVector]);
        if ([Vector lengthSquared: diffVector] < 2500.0f) {
            NSLog(@"got one");
            [agent setBehavior: [[[FleeBehavior alloc] initWithPoint: pos] autorelease]];
            [agent setMaxVelocity: 60.0f];
        }
    }
}

- (float) randomFloat
{
    int r;
    fread((void *)&r, 4, 1, urandomM);
    return (float) r / (float) INT_MAX;
}

@end
