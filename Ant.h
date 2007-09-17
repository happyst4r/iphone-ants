#import <UIKit/UIWindow.h>
#import <UIKit/UIImageView.h>

#import "World.h"
#import "Behavior.h"

#define MAX_ACCEL 500

@interface Ant : UIWindow <Agent>
{
    UIImageView  * viewM;
    CGPoint posM;
    CGPoint velM;
    CGPoint fallingVelM;
    World * worldM;
    NSObject <Behavior> *behaviorM;
    float travelCounterM;
    int currentSpriteM;
    int stateM;
    float deathCounterM;
    float maxVelocityM;
}

- (id) initWithPosition: (CGPoint)p velocity: (CGPoint)v world: (World *) w;
- (id) moveByX: (float)x Y: (float) y;
- (id) reposition;
- (float) getRotation;

@end
