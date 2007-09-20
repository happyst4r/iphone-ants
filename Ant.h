#import <UIKit/UIWindow.h>
#import <UIKit/UIImageView.h>

#import "World.h"
#import "Behavior.h"
#import "Sprites.h"

@interface Ant : UIWindow <Agent>
{
    UIImageView  * viewM;
    Sprites * spritesM;
    CGPoint posM;
    CGPoint velM;
    CGPoint fallingVelM;
    World * worldM;
    NSDictionary *descriptionM;
    NSObject <Behavior> *behaviorM;
    float travelCounterM;
    float widthM;
    float heightM;
    float scaleM;
    int currentSpriteM;
    int stateM;
    float deathCounterM;

    float maxVelocityM;
    float maxAccelerationM;

    float velocityVarianceFloatM;
    float accelerationVarianceFloatM;
}

- (id) initWithPosition: (CGPoint)p velocity: (CGPoint)v description: (NSDictionary *)desc world: (World *) w;
- (id) moveByX: (float)x Y: (float) y;
- (id) reposition;
- (float) getRotation;
- (id) updateSprite;
- (id) updateLimitsForState;

@end
