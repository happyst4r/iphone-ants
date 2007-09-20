#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

@protocol Behavior;

@protocol Agent
- (id) tickWithTimeDelta: (NSTimeInterval) timeDelta;
- (CGPoint) position;
- (CGPoint) velocity;
- (id) registerTapAt: (CGPoint) pos;
- (id) removeFromWorld;
- (id) setBehavior: (NSObject <Behavior> *) behavior;
@end

@interface World : NSObject
{
    NSMutableArray *objectsM;
    NSMutableArray *removeListM;
    NSTimer *timerM;
    float tickIntervalM;
    NSDate *lastTimeM;
    FILE *urandomM;
    float accelX;
    float accelY;
    float accelZ;
    int noAccelCountM;
    BOOL gotAccelM;
    BOOL accelEnabledM;

    NSDictionary *defaultsM;
    NSDictionary *bugsM;
    int maxBugsM;
    int bugTypesM;
    float spawnNewBugsProbabilityM;
    int totalSpawnWeightM;
}
+ (World *) singleton;
- (id) addObject: (id <Agent>) obj;
- (id) removeObject: (id <Agent>) obj;
- (id) tick:(NSTimer*)timer;
- (BOOL) adjustTimer;
- (id) start;
- (id) pause;
- (id) restart;
- (float) randomFloat;
- (float) accelX;
- (float) accelY;
- (float) accelZ;
- (id) registerTapAt: (CGPoint) pos;
- (id) updateAccelerometerInX: (float)x Y: (float)y Z: (float)z;
@end


