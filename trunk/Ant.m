#import "Ant.h"
#import "Behavior.h"
#import "Vector.h"
#import <UIKit/UIKit.h>

#include <math.h>

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
    posM = pos;
    velM.x = velM.y = 0.01f;
    worldM = w;

    struct CGRect rect = CGRectMake(0.0f, 0.0f, 16.0f, 25.0f);
    
    [super initWithContentRect: rect];
    [super orderFront: self];

    viewM = [[UIImageView alloc] initWithImage: [[UIImage alloc] initWithContentsOfFile: @"/usr/local/bin/ants/ant_50_32.png"]];

    [super setContentView: viewM];

    [self reposition];

    NSLog(@"yay - ants!");

    behaviorM = [[WanderBehavior alloc] init];

    return self;
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

    NSLog(@"angle: %f", baseAngle/M_PI*180);

    return baseAngle + M_PI/2 + (velM.x < 0?M_PI:0);
}

- (id) moveByX: (float)x Y:(float)y
{
    posM.x += x;
    posM.y += y;

    [self reposition];
}

- (id) tickWithTimeDelta: (NSTimeInterval)timeDelta
{
    [super orderFront: self]; // bring to front

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
    NSLog(@"dt: %f accel: (%f,%f) vel: (%f,%f) posD: (%f,%f) pos: (%f,%f)",
        timeDelta, accel.x, accel.y, velM.x, velM.y, posDelta.x, posDelta.y,
        posM.x, posM.y);

    [self moveByX: posDelta.x Y: posDelta.y];
}

@end
