#import "World.h"

@protocol Behavior

- (CGPoint) getAccelerationVectorForAgent: (id <Agent>) obj world: (World *) w;

@end

@interface DummyBehavior : NSObject <Behavior>
@end

@interface WanderBehavior : NSObject <Behavior>
{
    CGPoint lastAccelM;
}
@end

@interface FleeBehavior: WanderBehavior
{
    CGPoint fromM;
}
- (id) initWithPoint: (CGPoint) pos;
@end
