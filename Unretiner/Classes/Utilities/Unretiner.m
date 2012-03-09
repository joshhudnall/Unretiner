//
//  Unretiner.m
//  Unretiner
//
//  Created by Josh Hudnall on 3/9/12.
//  Copyright (c) 2012 Bonobo. All rights reserved.
//

#import "Unretiner.h"
#import "SynthesizeSingleton.h"
#import "NSURL+Unretina.h"

#pragma mark - UserManager Private Declarations
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

@interface Unretiner ()

- (void)unretinaUrls:(NSArray*)urls savePath:(NSURL*)savePath errors:(NSMutableArray*)errors warnings:(NSMutableArray*)warnings recursive:(BOOL)recursive;

@end


#pragma mark - Unretiner
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

@implementation Unretiner

@synthesize errors = _errors;
@synthesize warnings = _warnings;

SYNTHESIZE_SINGLETON_FOR_CLASS(Unretiner); // Macro to create singleton methods.

#pragma mark - Unretiner Methods
///////////////////////////////////////////////////////////////////////////////////////

- (void)unretinaUrls:(NSArray *)urls {
	[self unretinaUrls:urls andStayOpen:YES];
}

- (void)unretinaUrls:(NSArray*)urls andStayOpen:(BOOL)stayOpen {
	NSURL* baseUrl = [urls objectAtIndex:0];
	if ( ! [Unretiner isDirectory:baseUrl]) {
		baseUrl = [baseUrl URLByDeletingLastPathComponent];
	}
	if ( ! [Unretiner isDirectory:baseUrl]) {
		baseUrl = [baseUrl URLByDeletingLastPathComponent];
	} // Not sure why, but this needs to be called twice (or a better mechanism be implemented)
	
	BOOL saveToOrigin = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyForSaveToOrigin];
	NSURL* savePath = (saveToOrigin) ? baseUrl : [Unretiner getSaveFolder:baseUrl];

    // Extract the default export folder
    if ([urls count] > 0) {
        if (savePath) {
            // Reinit arrays to store warnings and errors
            self.errors = [NSMutableArray array];
            self.warnings = [NSMutableArray array];
            
            // Do it!
            [self unretinaUrls:urls savePath:savePath errors:_errors warnings:_warnings recursive:YES];
        }
    }
	
	if ( ! stayOpen) {
		[NSApp terminate:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:UnretinerDidFinishProcessing object:nil];
	}
}

- (void)unretinaUrls:(NSArray*)urls savePath:(NSURL*)savePath errors:(NSMutableArray*)errors warnings:(NSMutableArray*)warnings recursive:(BOOL)recursive {
    // Parse each file passed in
    for (NSURL* url in urls) {
        if (url) {
            BOOL directory = [Unretiner isDirectory:url];
            if (recursive && directory) {
                // Folder and we want to jump into it, grab the urls
                NSFileManager* fileManager = [NSFileManager defaultManager];
                NSArray* contents = [fileManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
                
                // Parse them, but don't go into any further sub folders
                [self unretinaUrls:contents savePath:savePath errors:errors warnings:warnings recursive:NO];
            } else if (!directory) {
                // Parse the file
				BOOL overwrite = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyForOverwrite];
				
                [url unretina:savePath errors:errors warnings:warnings overwrite:overwrite];
            }
        }
    }
}


#pragma mark - Utility Methods
///////////////////////////////////////////////////////////////////////////////////////

// Retrieves a folder to save to
+ (NSURL *)getSaveFolder:(NSURL*)url {
    NSOpenPanel *panel = [NSOpenPanel openPanel]; 
    [panel setCanChooseDirectories:YES]; 
    [panel setCanChooseFiles:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setDirectoryURL:url];
    panel.prompt = @"Save Here";
    panel.title = @"Select folder to save converted files.";
    if ([panel runModal] == NSOKButton) {
        // Got it, return the URL
        return [panel URL];
    }
    
    return nil;
}

+ (BOOL)isDirectory:(NSURL*)url {
    // Determine if it is a directory
    return CFURLHasDirectoryPath((CFURLRef)url);
}


#pragma mark - Memory Management
///////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [_errors release], _errors = nil;
    [_warnings release], _warnings = nil;
	
	[super dealloc];
}

@end
