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

@implementation Ant
- (id) initWithPosition: (CGPoint) pos velocity: (CGPoint) vel description: (NSDictionary *)desc world: (World *) w
{
    [super init];
    travelCounterM = 0.0f;
    currentSpriteM = 0;
    posM = pos;
    worldM = w;
    descriptionM = desc;
    stateM = kAntAlive;

    velocityVarianceFloatM = [w randomFloat];
    accelerationVarianceFloatM = [w randomFloat];
    [self updateLimitsForState];

    deathCounterM = 0.0f;

    velM = [Vector truncate: vel to: maxVelocityM];

    NSDictionary *dim = [descriptionM objectForKey: @"dimensions"];
    float var = [[dim objectForKey: @"variance"] floatValue] / 100.0f * [worldM randomFloat];
    widthM = [[dim objectForKey:@"width"] floatValue];
    heightM = [[dim objectForKey:@"height"] floatValue];
    widthM += widthM*var;
    heightM += heightM*var;
    struct CGRect rect = CGRectMake(0.0f, 0.0f, widthM , heightM);
    scaleM = var>1.0f?var:1-var;
    
    [super initWithContentRect: rect];
    [super orderFront: self];

    viewM = [[UIImageView alloc] init];
    spritesM = [Sprites spritesWithDescription: descriptionM];
    [self setBehavior: [[[WanderBehavior alloc] init] autorelease]];

    [super setContentView: viewM];

    [self reposition];

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

- (id) registerTapAt: (CGPoint) pos
{
    CGPoint diffVector = [Vector subtract: [self position] from: pos];
    if ([Vector lengthSquared: diffVector] < 10000.0f) {
        [self setBehavior: [[[FleeBehavior alloc] initWithPoint: pos] autorelease]];
        maxVelocityM *= 2;
    }
}

- (id) updateLimitsForState
{
    if (stateM >= [[descriptionM objectForKey:@"states"] count]) {
        maxVelocityM = maxAccelerationM = 0;
        return;
    }

    NSDictionary *d = [[descriptionM objectForKey:@"states"] objectAtIndex: stateM];

    float maxVelocityVariance = [[d objectForKey:@"maxVelocityVariance"] floatValue] * velocityVarianceFloatM;
    maxVelocityM = [[d objectForKey:@"maxVelocity"] intValue] + maxVelocityVariance; 

    float maxAccelerationVariance = [[d objectForKey:@"maxAccelerationVariance"] floatValue] * accelerationVarianceFloatM;
    maxAccelerationM = [[d objectForKey:@"maxAcceleration"] intValue] + maxAccelerationVariance; 

    //NSLog(@"new ant: %f, %f", maxVelocityM, maxAccelerationM);
}

- (id) reposition
{
    [self updateSprite];
    [super setTransform: CGAffineTransformMakeTranslation(posM.x, posM.y)];
    [viewM setTransform:
        CGAffineTransformScale(
            CGAffineTransformMakeRotation([self getRotation]), scaleM, scaleM)];
}

- (float) getRotation
{
    // calc rotation based on vel
    float baseAngle = atan(velM.y/velM.x);

    while(baseAngle < 0) baseAngle += 2*M_PI;

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

    [self reposition];
}

- (id) updateSprite
{
    if ([spritesM spritesBasedOnDistanceForState: stateM]) {
        int distance = [[descriptionM objectForKey:@"distanceBetweenSpriteChanges"] intValue];
        if (travelCounterM > distance * distance) {
            travelCounterM = 0.0f;
            currentSpriteM++;
        }
    } else {
        currentSpriteM++;
    }

    currentSpriteM = currentSpriteM % [spritesM numberOfSpritesForState: stateM];
    [viewM setTransform: CGAffineTransformIdentity];
    [viewM setImage: [spritesM spriteAtIndex: currentSpriteM forState: stateM]];
}


- (BOOL) ignoresMouseEvents
{
    return stateM != kAntAlive;
}

- (id) mouseDown: (void *) event
{
    stateM = kAntDead;
    [self updateLimitsForState];
    //NSLog(@"ANT JUST GOT KILLED YO!");
    [viewM setTransform: CGAffineTransformIdentity];
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

    // if not dead...
    if (stateM != kAntDead) {
        // do we need to react to the accelerometer? 
        if (stateM == kAntFalling) {
            // we're faaaalllllliinnnngggg. fun

            // are we going to get back on our feet?
            if (abs(x) < 0.25f && abs(y) < 0.25f && z < -0.25f) {
                // ok, now we have a chance of re-attaching
                if (z < -0.40f || ([worldM randomFloat] / 2 + 0.5) < 0.4f * timeDelta) {
                    stateM = kAntAlive;
                    [self updateLimitsForState];
                    fallingVelM.x = fallingVelM.y = 0.0f;
                }
            } 
            
            if (z < 0.42) {
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
            [self reposition];
        } else {
            // now are we going to let go?
            float ax = abs(x), ay = abs(y);
            if (ax > 0.35 || ay > 0.35) {
                float max = ax>ay?ax:ay;

                if ([worldM randomFloat] / 2 + 0.5f < max*max) {
                    // yup
                    stateM = kAntFalling;
                    [self updateLimitsForState];
                    fallingVelM = velM; // preservation of motion
                }
            }
        }
    }


    // calculate new position
    CGPoint accel = [Vector makeIdentity];
    if (behaviorM) {
        accel = [behaviorM getAccelerationVectorForAgent: self world: worldM];
        //NSLog(@"accel virgin: %f, %f", accel.x, accel.y);
        accel = [Vector multiply: [Vector truncate: accel to: maxAccelerationM] by: timeDelta];
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
