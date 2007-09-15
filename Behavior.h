#import "World.h"

@protocol Behavior

- (CGPoint) getAccelerationVectorForAgent: (id <Agent>) obj world: (World *) w;

@end

@interface DummyBehavior : NSObject <Behavior>
@end