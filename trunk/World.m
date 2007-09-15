#import "World.h"

@implementation World

- (id) init
{
    if ((self = [super init])) {
        tickIntervalM = 0.1f; // start with long tick interval
        objectsM = [[NSMutableArray alloc] init];
    }

    return self;
}

- (id) dealloc
{
    if (timerM) [timerM invalidate];
    [objectsM release];

    [super dealloc];
}

- (id) addObject: (id <Agent>) obj
{
    [objectsM addObject: obj];
    return obj;
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

- (id) tick: (NSTimer *)timer
{
    // calculate dt
    NSDate *now = [[NSDate alloc] init];

    if (lastTimeM) {
        NSTimeInterval timeDelta = [now timeIntervalSinceDate: lastTimeM];
        // loop thru our objects, tick them
        int cnt = [objectsM count];
        int i;
        for(i = 0; i < cnt; i++) {
            id <Agent> object = [objectsM objectAtIndex: i];
            [object tickWithTimeDelta: timeDelta];
        }
        // done

        [lastTimeM release];
    }

    lastTimeM = now;
}

@end
