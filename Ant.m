#import "Ant.h"
#import "Behavior.h"
#import "Vector.h"
#import <UIKit/UIKit.h>

#include <math.h>

#define NUM_SPRITES 3

enum {
    kAntAlive,
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
        NSString *path = [NSString stringWithFormat:@"/usr/local/bin/ants/ant%d.png", i+1];
        //NSLog(@"Adding image: %@", path);
        UIImage *img = [[UIImage alloc] initWithContentsOfFile: path];
        [spritesM addObject: img];
    }

    deadAntImageM = [[UIImage alloc] initWithContentsOfFile: @"/usr/local/bin/ants/ant_dead.png"];

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
- (id) initWithX: (float)x Y: (float)y world: (World *) w
{
    CGPoint pos;
    pos.x = x;
    pos.y = y;

    return [self initWithPosition: pos world: w];
}

- (id) initWithPosition: (CGPoint) pos world: (World *) w
{
    [super init];
    travelCounterM = 0.0f;
    currentSpriteM = 0;
    posM = pos;
    velM.x = velM.y = 0.01f;
    worldM = w;
    stateM = kAntAlive;
    deathCounterM = 0.0f;

    struct CGRect rect = CGRectMake(0.0f, 0.0f, 16.0f, 25.0f);
    
    [super initWithContentRect: rect];
    [super orderFront: self];

    viewM = [[UIImageView alloc] initWithImage: [[AntSprites singleton] spriteAtIndex: 0]];

    [super setContentView: viewM];

    [self reposition];

    //NSLog(@"yay - ants!");

    behaviorM = [[WanderBehavior alloc] init];

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
}

- (id) tickWithTimeDelta: (NSTimeInterval)timeDelta
{
    [super orderFront: self]; // bring to front

    // if alive, move
    if (stateM == kAntAlive) {
        // calculate new position
        CGPoint accel;
        if (behaviorM) {
            accel = [behaviorM getAccelerationVectorForAgent: self world: worldM];
            //NSLog(@"accel virgin: %f, %f", accel.x, accel.y);
            accel = [Vector multiply: [Vector truncate: accel to: MAX_ACCEL] by: timeDelta];
            //NSLog(@"accel trunc: %f, %f", accel.x, accel.y);
            velM = [Vector truncate: [Vector add: accel to: velM] to: MAX_VEL];
        }

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
                [worldM removeObject: self];
                [self orderOut: self];
                [self release];
                return;
            }
            [viewM setAlpha: 4.0f - deathCounterM];
        }
    }
}

@end
