#import "Behavior.h"

@implementation DummyBehavior
- (GCPoint) getAccelerationVectorForObject: (id <Agent>) agent world: (World *) w
{
    GCPoint a;
    a.x = 0.0f;
    a.y = 10.0f;
}
@end
