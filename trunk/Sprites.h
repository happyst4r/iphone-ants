@class UIImage;
@class NSMutableArray;

#import <Foundation/Foundation.h>

@interface Sprites : NSObject
{
    NSMutableDictionary *spriteGroupImagesM;
    NSDictionary *descriptionM;
}
- (UIImage *) spriteAtIndex: (int) i forState: (int) s;
- (BOOL) spritesBasedOnDistanceForState: (int) s;
- (id) initWithDescription: (NSDictionary *) d;
+ (Sprites *) spritesWithDescription: (NSDictionary *) d;
- (int) numberOfSpritesForState: (int) s;
- (NSString *) loadGroupForState: (int) s;
@end

