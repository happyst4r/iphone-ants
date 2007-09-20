#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIBox.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesControlTableCell.h>


@interface AntsControllerApp : UIApplication {
    UIWindow *windowM;
    UIView *mainViewM;

    UINavigationBar *navBarM;

    UIPreferencesTable *tableM;
    UIPreferencesTextTableCell *maxAntsCellM;
    UIPreferencesControlTableCell *enabledCellM;
    UIPreferencesControlTableCell *enableAccelCellM;
    UIPreferencesControlTableCell *spawnRateCellM;

    NSMutableDictionary *defaultsM;
}

- (void) saveAndExit;
- (void) initDefaults;
- (NSString *) executeCommand: (NSString *)cmd;
- (BOOL) isAntsRunning;
- (void) stopAnts;
- (void) startAnts;
- (void) showBugAlert;
@end
