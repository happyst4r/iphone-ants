
#import "AntsControllerApp.h"
#import <UIKit/UIPreferencesTable.h>
#import "Common.h"

#define LAUNCHD_FILE @"/Library/LaunchDaemons/net.schine.ants.plist"

@implementation AntsControllerApp

- (void) applicationDidFinishLaunching: (id) unused
{
    [self initDefaults];
    struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;

    windowM = [[UIWindow alloc] initWithContentRect: rect];

    [windowM orderFront: self];
    [windowM makeKey: self];
    [windowM _setHidden: NO];

    mainViewM = [[UIView alloc] initWithFrame: rect];

    // create the cells
    maxAntsCellM = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 48.0f, rect.size.width, 48.0f)];
    [maxAntsCellM setTitle:@"Maximum Ants"];
    [maxAntsCellM setValue:[defaultsM valueForKey:@"maxAnts"]];

    enabledCellM = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 48.0f)];
    [enabledCellM setTitle:@"Enabled"];
    UISwitchControl *enabledControl = [[[UISwitchControl alloc] initWithFrame: CGRectMake(rect.size.width - 114.0f, 11.0f, 114.0f, 48.0f)] autorelease];
    [enabledControl setAlternateColors:YES];
    [enabledControl setValue:[self isAntsRunning]];
    [enabledCellM setControl:enabledControl];

    enableAccelCellM = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 48.0f)];
    [enableAccelCellM setTitle:@"Accelerometer Use"];
    UISwitchControl *enableAccelControl = [[[UISwitchControl alloc] initWithFrame: CGRectMake(rect.size.width - 114.0f, 11.0f, 114.0f, 48.0f)] autorelease];
    [enableAccelControl setAlternateColors:YES];
    [enableAccelControl setValue:([[defaultsM valueForKey:@"accelerometer"] intValue]==1)];
    [enableAccelCellM setControl:enableAccelControl];

    spawnRateCellM = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 48.0f)];
    [spawnRateCellM setTitle:@"Spawn Rate"];
    UISliderControl *spawnRateControl = [[[UISliderControl alloc] initWithFrame: CGRectMake(rect.size.width - 185.0f, 2.0f, 170.0f, 44.0f)] autorelease];
    [spawnRateControl setContinuous: YES];
    [spawnRateControl setMinValue: 0.0f];
    [spawnRateControl setMaxValue: 1.0f];
    NSNumber *spawnRate = [defaultsM valueForKey:@"spawnRate"];
    float spawnRateF = spawnRate?[spawnRate floatValue]/100:0.2f;
    [spawnRateControl setValue: spawnRateF];
    [spawnRateCellM setControl:spawnRateControl];

    // nav bar
    navBarM = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 48.0f)] autorelease];
    [navBarM showLeftButton:@"About" withStyle:0 rightButton:@"Done" withStyle:3];
    [navBarM setBarStyle:0];
    [navBarM setDelegate:self];
    [mainViewM addSubview: navBarM];

    // title
    UINavigationItem *title = [[[UINavigationItem alloc] initWithTitle:@"Ants Control"] autorelease];
    [navBarM pushNavigationItem:title];

    // pref table
    tableM = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 48.0f, rect.size.width, rect.size.height - 48.0f)];
    [tableM setDataSource:self];
    [tableM setDelegate:self];
    [mainViewM addSubview: tableM];

    [tableM reloadData];

    [windowM setContentView: mainViewM];
}

- (void) tableRowSelected:(NSNotification *)notification
{
    [[tableM cellAtRow: [tableM selectedRow] column:0] setSelected:NO];
}

- (int) numberOfGroupsInPreferencesTable: (id) table
{
    return 2;
}

- (int) preferencesTable:(id)table numberOfRowsInGroup:(int)group
{
    switch (group)
    {
        case 0:
            return 1;
        case 1:
            return 3;
    }
}

- (id)preferencesTable: (id)table cellForRow: (int) row inGroup:(int)group
{
    switch (group) {
        case 0:
            // only one item
            return enabledCellM;
        case 1:
        {
            switch (row) {
                case 0:
                    return enableAccelCellM;
                case 1:
                    return maxAntsCellM;
                case 2:
                    return spawnRateCellM;
            }
        }
    }
}

- (id)preferencesTable:(id)table titleForGroup:(int)group
{
    switch (group)
    {
        case 0:
            return @"Ants";
        case 1:
            return @"Settings";
    }
}

- (float)preferencesTable:(id)table heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposedHeight;
{
	return 48.0f;
}

- (void)navigationBar:(id)navbar buttonClicked:(int)button
{
    switch (button)
    {
        case 0:
            [self saveAndExit];
            break;
        case 1:
            // do about
            // TODO
            break;
    }
}

- (void)saveAndExit
{
    // save defaults
    NSString *newMaxAnts = [maxAntsCellM value];
    if (![newMaxAnts isEqualToString:[defaultsM valueForKey:@"maxAnts"]]
        && [newMaxAnts intValue] > 0)
    {
        [defaultsM setValue:newMaxAnts forKey:@"maxAnts"];
    }

    BOOL accelEnabled = [[[enableAccelCellM control] valueForKey: @"value"] boolValue];
    BOOL oldAccel = [[defaultsM valueForKey:@"accelerometer"] intValue] == 1;
    [defaultsM setValue:(accelEnabled?@"1":@"0") forKey:@"accelerometer"];
    UISliderControl *spawnRateControl = [spawnRateCellM control];
    float spawnRate = [spawnRateControl value];
    [defaultsM setValue: [NSString stringWithFormat: @"%d", (int) (spawnRate * 100.0f)] forKey:@"spawnRate"];

    // save to file
    if (! [defaultsM writeToFile: DEFAULTS_FILE atomically: YES]) {
        NSLog(@"Could not write defaults");
    }

    // restart ants
    [self stopAnts];
    if ([[[enabledCellM control] valueForKey:@"value"] boolValue]) {
        [self startAnts];
    }

    if (accelEnabled && !oldAccel) {
        // show alert saying there's a bug
        [self showBugAlert];
    } else {
        // exit now
        [self terminateWithSuccess];
    }
}

- (void) showBugAlert
{
    UIAlertSheet *alert = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0,0,320,480)];
    [alert setTitle:@"Bug Notice"];
    [alert setBodyText:@"Enabling accelerometer usage introduces a (harmless) bug: if your ringer is ON, the Ringer On icon will appear on screen at certain times."];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertSheetStyle:3];
    [alert setDelegate: self];
    [alert popupAlertAnimated: YES];
}

- (void) alertSheet:(UIAlertSheet *)alert buttonClicked:(int) button
{
    [alert dismissAnimated: YES];
    [self terminateWithSuccess];
}

- (void)initDefaults
{
    defaultsM = [[NSMutableDictionary alloc] initWithContentsOfFile: DEFAULTS_FILE];
    if (defaultsM == nil) {
        defaultsM = [[NSMutableDictionary alloc] init];
        // set defaults
        [defaultsM setValue:@"7" forKey:@"maxAnts"];
    }
}

- (BOOL) isAntsRunning
{
    NSString *output = [self executeCommand: @"/bin/launchctl list"];
    NSRange r = [output rangeOfString:@"net.schine.ants"];
    if (r.location != NSNotFound) {
        return YES;
    }

    return NO;
}

- (void) stopAnts
{
    NSString *stop = [NSString stringWithFormat: @"/bin/launchctl unload -w %@", LAUNCHD_FILE];
    [self executeCommand: stop];
}

- (void) startAnts
{
    NSString *start = [NSString stringWithFormat: @"/bin/launchctl load -w %@", LAUNCHD_FILE];
    [self executeCommand: start];
}

- (NSString *)executeCommand:(NSString *)cmd
{
    NSString *output = [NSString string];
    FILE *pipe = popen([cmd cStringUsingEncoding: NSASCIIStringEncoding], "r");
    if (!pipe) return;

    char buf[1024];
    while(fgets(buf, 1024, pipe)) {
        output = [output stringByAppendingFormat: @"%s", buf];
    }

    pclose(pipe);
    return output;
}

@end

