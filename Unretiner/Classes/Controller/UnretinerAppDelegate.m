//
//  UnretinerAppDelegate.m
//  Unretiner
//
//  Created by Stuart Hall on 30/07/11.
//

#import "UnretinerAppDelegate.h"
#import "UnretinaViewController.h"
#import "Unretiner.h"

@interface UnretinerAppDelegate () 

@property (nonatomic, assign) BOOL _keepOpen;

@end

@implementation UnretinerAppDelegate

@synthesize window;
@synthesize view;
@synthesize viewController;
@synthesize _keepOpen;

- (void)dealloc {
    self.window = nil;
    self.view = nil;
    self.viewController = nil;
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Set up some defaults if they're not already set by the user
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyForSaveToOrigin] == nil) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyForSaveToOrigin];
	}
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyForOverwrite] == nil) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyForOverwrite];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    // Add the view from our controller
    viewController = [[UnretinaViewController alloc] initWithNibName:@"UnretinaViewController" bundle:nil];
    viewController.view.bounds = self.view.bounds;
    [view addSubview:viewController.view];
	
	_keepOpen = YES; // If we reach this point, the user has opened the app to keep it open
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	// Close when the window is closed
	return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)files {
    // Files dropped onto the icon
    NSMutableArray* urls = [NSMutableArray arrayWithCapacity:[files count]];
	for (NSString* file in files) {
		[urls addObject:[NSURL fileURLWithPath:file]];
	}
    
    // Send to the controller
    [[Unretiner sharedInstance] unretinaUrls:urls andStayOpen:_keepOpen];
}

- (BOOL)application:(NSApplication*)sender openFile:(NSString*)file {
    // Send to the controller
	[self application:sender openFiles:[NSArray arrayWithObject:[NSURL fileURLWithPath:file]]];
	
	return YES;
}

@end
