#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

@protocol Agent
- (id) tickWithTimeDelta: (NSTimeInterval) timeDelta;
- (CGPoint) position;
@end

@interface World : NSObject
{
    NSMutableArray *objectsM;
    NSTimer *timerM;
    float tickIntervalM;
    NSDate *lastTimeM;
    FILE *urandomM;
}
- (id) addObject: (id <Agent>) obj;
- (id) tick:(NSTimer*)timer;
- (id) start;
- (id) pause;
- (id) restart;
- (float) randomFloat;
@end


