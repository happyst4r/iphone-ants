#import <UIKit/UIWindow.h>
#import <UIKit/UIImageView.h>

#import "World.h"
#import "Behavior.h"

#define MAX_VEL 30
#define MAX_ACCEL 200

@interface Ant : UIWindow <Agent>
{
    UIImageView  * viewM;
    CGPoint posM;
    CGPoint velM;
    World * worldM;
    id <Behavior> behaviorM;
    float travelCounterM;
    int currentSpriteM;
    int stateM;
    float deathCounterM;
}

- (id) initWithX: (float)x Y: (float) y world: (World *) w;
- (id) initWithPosition: (CGPoint)p world: (World *) w;
- (id) moveByX: (float)x Y: (float) y;
- (id) reposition;
- (float) getRotation;

@end
