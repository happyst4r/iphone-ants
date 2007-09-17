#import "Ant.h"
#import "Behavior.h"
#import "Vector.h"
#import <UIKit/UIKit.h>

#include <math.h>

#define NUM_SPRITES 3

enum {
    kAntAlive,
    kAntFalling,
    kAntDead
};

@interface AntSprites : NSObject
{
    NSMutableArray *spritesM;
    UIImage *deadAntImageM;
}
+ (AntSprites *) singleton;
- (UIImage *) spriteAtIndex: (int) i;
- (UIImage *) deadAntSprite;
@end

AntSprites *_antSprites;

@implementation AntSprites
+ (AntSprites *) singleton
{
    if (!_antSprites) {
        _antSprites = [[AntSprites alloc] init];
    }
    return _antSprites;
}

- (id) init
{
    [super init];

    spritesM = [[NSMutableArray alloc] initWithCapacity: NUM_SPRITES];
    int i;
    for(i = 0; i < NUM_SPRITES; i++) {
        NSString *path = [NSString stringWithFormat:@"/usr/local/share/ants/ant%d.png", i+1];
        //NSLog(@"Adding image: %@", path);
        UIImage *img = [[UIImage alloc] initWithContentsOfFile: path];
        [spritesM addObject: img];
    }

    deadAntImageM = [[UIImage alloc] initWithContentsOfFile: @"/usr/local/share/ants/ant_dead.png"];

    return self;
}

- (UIImage *) deadAntSprite
{
    return deadAntImageM;
}

- (UIImage *) spriteAtIndex: (int) i
{
    return [spritesM objectAtIndex: i];
}
@end

@implementation Ant
- (id) initWithPosition: (CGPoint) pos velocity: (CGPoint) vel world: (World *) w
{
    [super init];
    travelCounterM = 0.0f;
    currentSpriteM = 0;
    posM = pos;
    worldM = w;
    stateM = kAntAlive;
    maxVelocityM = 30.0f;
    deathCounterM = 0.0f;
    velM = [Vector truncate: vel to: maxVelocityM];

    struct CGRect rect = CGRectMake(0.0f, 0.0f, 16.0f, 25.0f);
    
    [super initWithContentRect: rect];
    [super orderFront: self];

    viewM = [[UIImageView alloc] initWithImage: [[AntSprites singleton] spriteAtIndex: 0]];

    [super setContentView: viewM];

    [self reposition];

    //NSLog(@"yay - ants!");

    return self;
}

- (id) dealloc
{
    [viewM release];
    [super dealloc];
}

- (CGPoint) position
{
    return posM;
}

- (CGPoint) velocity
{
    return velM;
}

- (id) reposition
{
    [super setTransform: CGAffineTransformMakeTranslation(posM.x, posM.y)];
    [viewM setTransform: CGAffineTransformMakeRotation([self getRotation])];
}

- (float) getRotation
{
    // calc rotation based on vel
    float baseAngle = atan(velM.y/velM.x);

    while(baseAngle < 0) baseAngle += 2*M_PI;

    //NSLog(@"angle: %f", baseAngle/M_PI*180);

    return baseAngle + M_PI/2 + (velM.x < 0?M_PI:0);
}

- (id) setBehavior: (NSObject <Behavior> *) newBehavior
{
    if (newBehavior != behaviorM) {
        [behaviorM release];
        behaviorM = [newBehavior retain];
    }
}

- (id) moveByX: (float)x Y:(float)y
{
    posM.x += x;
    posM.y += y;

    travelCounterM += (x*x + y*y);
    if (travelCounterM > 9.0f) {
        travelCounterM = 0.0f;
        currentSpriteM = (currentSpriteM + 1) % NUM_SPRITES;
        [viewM setTransform: CGAffineTransformIdentity];
        [viewM setImage: [[AntSprites singleton] spriteAtIndex: currentSpriteM]];
    }

    [self reposition];
}

- (BOOL) ignoresMouseEvents
{
    return stateM != kAntAlive;
}

- (id) mouseDown: (void *) event
{
    stateM = kAntDead;
    //NSLog(@"ANT JUST GOT KILLED YO!");
    [viewM setTransform: CGAffineTransformIdentity];
    [viewM setImage: [[AntSprites singleton] deadAntSprite]];
    [self reposition]; // re-rotate and such
    // tell the world we just got tapped
    [worldM registerTapAt: posM];
}

- (id) removeFromWorld
{
    [worldM removeObject: self];
    [self orderOut: self];
    [self release];
}

- (id) tickWithTimeDelta: (NSTimeInterval)timeDelta
{
    [super orderFront: self]; // bring to front
    
    float x = [worldM accelX];
    float y = [worldM accelY];
    float z = [worldM accelZ];

    // do we need to react to the accelerometer?
    if (stateM == kAntFalling) {
        // we're faaaalllllliinnnngggg. fun

        // are we going to get back on our feet?
        if (abs(x) < 0.25f && abs(y) < 0.25f && z < -0.25f) {
            // ok, now we have a chance of re-attaching
            if ([worldM randomFloat] < 0.0f) {
                stateM = kAntAlive;
            }

            fallingVelM.x = fallingVelM.y = 0.0f;
        } else if (z < 0.40) {
            // ok keep falling
            // but are we upside down?
            CGPoint accel = [Vector
                multiply: [Vector makeWithX: -x Y: -y] // down
                by: 400.0f];

            // are we stuck?
            // subtract friction from the screen
            if (z > 0.0f) {
                accel = [Vector multiply: [Vector subtract: fallingVelM from: accel] by: z*2];
            }

            // compute new vel and apply
            accel = [Vector multiply: accel by: timeDelta];
            //NSLog(@"accel trunc: %f, %f", accel.x, accel.y);
            fallingVelM = [Vector truncate: [Vector add: accel to: fallingVelM] to: 200.0f];

            CGPoint posDelta = [Vector multiply: fallingVelM by: timeDelta];

            [self moveByX: posDelta.x Y: posDelta.y];
        } else {
            fallingVelM.x = fallingVelM.y = 0;
        }
        
        // flail!
        currentSpriteM = (currentSpriteM + 1) % NUM_SPRITES;
        [viewM setTransform: CGAffineTransformIdentity];
        [viewM setImage: [[AntSprites singleton] spriteAtIndex: currentSpriteM]];
        [self reposition];
    } else {
        // now are we going to let go?
        float ax = abs(x), ay = abs(y);
        if (ax > 0.35 || ay > 0.35) {
            float max = ax>ay?ax:ay;

            if ([worldM randomFloat] / 2 + 0.5f < max*max) {
                // yup
                stateM = kAntFalling;
            }
        }
    }


    // calculate new position
    CGPoint accel = [Vector makeIdentity];
    if (behaviorM) {
        accel = [behaviorM getAccelerationVectorForAgent: self world: worldM];
        //NSLog(@"accel virgin: %f, %f", accel.x, accel.y);
        accel = [Vector multiply: [Vector truncate: accel to: MAX_ACCEL] by: timeDelta];
        //NSLog(@"accel trunc: %f, %f", accel.x, accel.y);
        velM = [Vector truncate: [Vector add: accel to: velM] to: maxVelocityM];
    }

    // if alive, move
    if (stateM == kAntAlive) {
        CGPoint posDelta = [Vector multiply: velM by: timeDelta];
        //NSLog(@"dt: %f accel: (%f,%f) vel: (%f,%f) posD: (%f,%f) pos: (%f,%f)",
            //timeDelta, accel.x, accel.y, velM.x, velM.y, posDelta.x, posDelta.y,
            //posM.x, posM.y);

        [self moveByX: posDelta.x Y: posDelta.y];
    } else if (stateM == kAntDead) {
        // continue fading ant
        //NSLog(@"Dead ant!");
        deathCounterM += timeDelta;
        if (deathCounterM > 3.0f) {
            if (deathCounterM > 4.0f) {
                // remove from world, dealloc
                [self removeFromWorld];
                return;
            }
            [viewM setAlpha: 4.0f - deathCounterM];
        }
    }
}

- (id) setMaxVelocity: (float) max
{
    maxVelocityM = max;
}

@end
