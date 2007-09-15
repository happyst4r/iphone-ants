#import <UIKit/UIWindow.h>
#import <UIKit/UIImageView.h>

#import "World.h"

#define MAX_VEL 50
#define MAX_ACCEL 200

@interface Ant : UIWindow <Agent>
{
    UIImageView  * viewM;
    CGPoint posM;
    CGPoint velM;
    World * worldM;
}

- (id) initWithX: (float)x Y: (float) y world: (World *) w;
- (id) initWithPosition: (CGPoint)p world: (World *) w;
- (id) moveByX: (float)x Y: (float) y;
- (id) reposition;

@end
