#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIScroller.h>
#import <GraphicsServices/GraphicsServices.h>

@interface AppButton : UIImageView {
  DockApp *app;
  UIView * parent;
  NSString *path;
  NSDictionary *info;
  UITextLabel * label;
  BOOL notDragging;
  BOOL animated;
  float x;
  float y;
}

-(id)initWithDir:(NSString *)dir app:(DockApp *)appl parent:(UIView*)view;
-(NSString *)name;
-(BOOL)hasName;
-(void)launch;
-(NSString *)getPath;
-(void)setImage: (UIImage *)img text: (NSString *)text;
@end
