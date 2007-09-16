#import "Behavior.h"
#import "Vector.h"

@implementation DummyBehavior
- (CGPoint) getAccelerationVectorForAgent: (id <Agent>) agent world: (World *) w
{
    CGPoint a;
    a.x = 0.0f;
    a.y = 2.0f;
    return a;
}
@end

#define WANDER_MAX 50
#define WANDER_VARIATION_MAX 50

@implementation WanderBehavior
- (id) init
{
    [super init];
    lastAccelM.x = lastAccelM.y = 0.0f;
    return self;
}

- (CGPoint) getAccelerationVectorForAgent: (id <Agent>) agent world: (World *) w
{
    if (lastAccelM.x == 0.0f && lastAccelM.y == 0.0f) {
        lastAccelM.x = [w randomFloat] * WANDER_MAX;
        lastAccelM.y = [w randomFloat] * WANDER_MAX;
    }

    // now vary the wander accel by a little bit
    lastAccelM.x += [w randomFloat] * WANDER_VARIATION_MAX;
    lastAccelM.y += [w randomFloat] * WANDER_VARIATION_MAX;

    lastAccelM = [Vector truncate: lastAccelM to: WANDER_MAX];

    return lastAccelM;
}
@end
