
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
            return 1;
    }
}

- (id)preferencesTable: (id)table cellForRow: (int) row inGroup:(int)group
{
    switch (group) {
        case 0:
            // only one item
            return enabledCellM;
        case 1:
            return maxAntsCellM;
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

    // save to file
    if (! [defaultsM writeToFile: DEFAULTS_FILE atomically: YES]) {
        NSLog(@"Could not write defaults");
    }

    // restart ants
    [self stopAnts];
    if ([[[enabledCellM control] valueForKey:@"value"] boolValue]) {
        [self startAnts];
    }

    // exit
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

