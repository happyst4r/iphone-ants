#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

@protocol Agent
- (id) tickWithTimeDelta: (NSTimeInterval) timeDelta;
- (CGPoint) position;
@end

@interface World : NSObject
{
    NSMutableArray *objectsM;
    NSMutableArray *removeListM;
    NSTimer *timerM;
    float tickIntervalM;
    NSDate *lastTimeM;
    FILE *urandomM;
}
- (id) addObject: (id <Agent>) obj;
- (id) removeObject: (id <Agent>) obj;
- (id) tick:(NSTimer*)timer;
- (id) adjustTimer;
- (id) start;
- (id) pause;
- (id) restart;
- (float) randomFloat;
@end


