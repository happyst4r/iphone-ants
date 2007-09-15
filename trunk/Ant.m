#import "Ant.h"
#import "Behaviors.h"
#import <UIKit/UIKit.h>

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
    velM.x = velM.y = 0;
    worldM = w;

    struct CGRect rect = CGRectMake(0.0f, 0.0f, 48.0f, 48.0f);
    
    [super initWithContentRect: rect];
    [super orderFront: self];

    viewM = [[UIImageView alloc] initWithImage: [[UIImage alloc] initWithContentsOfFile: @"/usr/local/bin/dock/cancel.png"]];

    [super setContentView: viewM];

    [self reposition];

    NSLog(@"yay - ants!");

    behaviorM = [[DummyBehavior alloc] init];

    return self;
}

- (CGPoint) position
{
    return posM;
}

- (id) reposition
{
    [super setTransform: CGAffineTransformMakeTranslation(posM.x, posM.y)];
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
    if (behaviorM) {
        GCPoint accel = [behaviorM getAccelerationVectorForAgent: self world: worldM];
        accel = [Vector truncate: accel to: MAX_ACCEL];
        velM = [Vector truncate: [Vector add: accel to: velM] to: MAX_VEL];
    }

    GCPoint posDelta = [Vector multiply: velM by: timeDelta];
    [self moveByX: posDelta.x Y: posDelta.y];
}

@end
