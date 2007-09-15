#import "Behavior.h"

@implementation DummyBehavior
- (CGPoint) getAccelerationVectorForAgent: (id <Agent>) agent world: (World *) w
{
    CGPoint a;
    a.x = 0.0f;
    a.y = 2.0f;
}
@end
