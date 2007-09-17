#import "World.h"

@implementation World

- (id) init
{
    if ((self = [super init])) {
        tickIntervalM = 0.1f; // start with long tick interval
        objectsM = [[NSMutableArray alloc] init];
        removeListM = [[NSMutableArray alloc] init];
    }

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
    // TODO

    if (lastTimeM) {
        NSTimeInterval timeDelta = [now timeIntervalSinceDate: lastTimeM];
        // loop thru our objects, tick them
        int cnt = [objectsM count];
        NSLog(@"count: %d", cnt);
        int i;
        for(i = 0; i < cnt; i++) {
            id <Agent> object = [objectsM objectAtIndex: i];
            [object tickWithTimeDelta: timeDelta];
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

- (float) randomFloat
{
    int r;
    fread((void *)&r, 4, 1, urandomM);
    return (float) r / (float) INT_MAX;
}

@end
