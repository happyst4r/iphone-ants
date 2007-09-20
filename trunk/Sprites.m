#import <UIKit/UIKit.h>
#import "Sprites.h"

NSMutableDictionary *_sprites;

@implementation Sprites
+ (Sprites *) spritesWithDescription: (NSDictionary *) desc
{
    if (!_sprites) {
        _sprites = [[NSMutableDictionary alloc] init];
    }
    NSString *className = [desc objectForKey: @"class"];
    Sprites * newSprites;
    if (!(newSprites = [_sprites objectForKey: className])) {
        newSprites = [[Sprites alloc] initWithDescription: desc];
        [_sprites setObject: newSprites forKey: className];
    }

    return newSprites;
}

- (id) initWithDescription: (NSDictionary *) desc
{
    [super init];

    descriptionM = desc;
    spriteGroupImagesM = [[NSMutableDictionary alloc] init];
    return self;
}

- (UIImage *) spriteAtIndex: (int) i forState: (int) s
{
    NSString * group;
    if (!(group = [self loadGroupForState: s])) {
        return nil;
    }

    return [[spriteGroupImagesM objectForKey: group] objectAtIndex: i];
}

- (int) numberOfSpritesForState: (int) s
{
    NSString * group;
    if (!(group = [self loadGroupForState: s])) {
        return 0;
    }

    return [[spriteGroupImagesM objectForKey: group] count];
}

- (BOOL) spritesBasedOnDistanceForState: (int) s
{
    NSString * group;
    if (!(group = [self loadGroupForState: s])) {
        return NO;
    }

    return [[[[descriptionM objectForKey: @"states"] objectAtIndex: s] objectForKey:@"spritesBasedOnDistance"] boolValue];
}

- (NSString *) loadGroupForState: (int) s
{
    if (s >= [[descriptionM objectForKey: @"states"] count]) {
        return nil;
    }
    NSString *group = [[[descriptionM objectForKey: @"states"] objectAtIndex: s] objectForKey:@"useSpriteGroup"];
    if (![spriteGroupImagesM objectForKey: group]) {
        // do we have this sprite group defined?
        NSArray *groupDefinition = [[descriptionM objectForKey: @"spriteGroups"] objectForKey: group];
        if (!groupDefinition) {
            return nil;
        }

        int count = [groupDefinition count];
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity: count];
        int i;
        for(i = 0; i < count; i++) {
            UIImage *img = [[UIImage alloc] initWithContentsOfFile: [groupDefinition objectAtIndex: i]];
            [images addObject: img];
        }

        [spriteGroupImagesM setObject: images forKey: group];
    }
    return group;
}
@end

