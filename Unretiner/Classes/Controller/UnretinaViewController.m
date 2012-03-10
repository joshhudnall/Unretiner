//
//  UnretinaViewController.m
//  Unretiner
//
//  Created by Stuart Hall on 31/07/11.
//

#import "UnretinaViewController.h"
#import "NSURL+Unretina.h"
#import "Unretiner.h"


@interface UnretinaViewController ()

@end


@implementation UnretinaViewController

static NSString* const kRetinaString = @"@2x";
static NSString* const kHdString = @"-hd";

@synthesize saveToOriginCheckBox;
@synthesize overwriteCheckBox;
@synthesize tableView;

#pragma mark - Initialisation

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    id s = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (s == self) {
        // Register for drag and drop
        [[self view] registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    
    return s;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	overwriteCheckBox.state = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyForOverwrite];
	saveToOriginCheckBox.state = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyForSaveToOrigin];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(unretinerDidFinishProcessing)
												 name:UnretinerDidFinishProcessing
											   object:nil];
}

- (void)unretinerDidFinishProcessing {
	// All we really need to do right now is refresh the table view
	[self.tableView reloadData];
}

#pragma mark - Memory Management

- (void)dealloc {
    [super dealloc];
}

#pragma mark - Private Methods

- (IBAction)onSelectFolder:(id)sender {  
    // Select the files to convert
	NSOpenPanel*panel = [NSOpenPanel openPanel]; 
	[panel setCanChooseDirectories:YES]; 
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:YES];
	[panel setDelegate:self];
	[panel setCanCreateDirectories:YES];
	panel.title = @"Select @2x or -hd retina files";
	
    if ([panel runModal] == NSOKButton) {
        // Success, process all the files
        [[Unretiner sharedInstance] unretinaUrls:panel.URLs];
    }
}

- (IBAction)onCheckOverwriteChange:(id)sender {
	BOOL overwrite = overwriteCheckBox.state;
	[[NSUserDefaults standardUserDefaults] setBool:overwrite forKey:kDefaultsKeyForOverwrite];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onCheckOriginChange:(id)sender {
	BOOL origin = saveToOriginCheckBox.state;
	[[NSUserDefaults standardUserDefaults] setBool:origin forKey:kDefaultsKeyForSaveToOrigin];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - NSOpenSavePanelDelegate

- (BOOL)allowFile:(NSString*)filename {
    // Allow directories
    NSURL* url = [NSURL fileURLWithPath:filename];
    if (url && [Unretiner isDirectory:url])
        return YES;
    
    // See if the file is a retina image
    return url && [url isRetinaImage];
}

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL*)url {
    // Only enable valid files
	return [self allowFile:[url path]];
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString*)filename {
    // Only show valid files
	return [self allowFile:filename];
}

#pragma mark - Drag and Drop

- (void)filesDropped:(NSArray*)urls {
    // Process them
    [[Unretiner sharedInstance] unretinaUrls:urls];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView*)aTableView {	
	return [[[Unretiner sharedInstance] errors] count] + [[[Unretiner sharedInstance] warnings] count];
}

- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row {
	NSArray* errors = [[Unretiner sharedInstance] errors];
	NSArray* warnings = [[Unretiner sharedInstance] warnings];
	
	if ([tableColumn.identifier isEqualToString:@"Type"]) {
		if (row < [errors count]) {
			return @"Error";
		} else {
			return @"Warning";
		}
	} else {
		if (row < [errors count]) {
			return [errors objectAtIndex:row];
		} else {
			return [warnings objectAtIndex:row - [errors count]];
		}
	}
	
	return nil;
}


@end
