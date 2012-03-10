//
//  Unretiner.h
//  Unretiner
//
//  Created by Josh Hudnall on 3/9/12.
//  Copyright (c) 2012 Bonobo. All rights reserved.
//


@interface Unretiner : NSObject

@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic, retain) NSMutableArray* warnings;

// Returns singleton instance
+ (Unretiner*)sharedInstance;

// Unretiner Methods
- (void)unretinaUrls:(NSArray*)urls;
- (void)unretinaUrls:(NSArray*)urls andStayOpen:(BOOL)stayOpen;

// Utility methods
+ (NSURL*)getSaveFolder:(NSURL*)url;
+ (BOOL)isDirectory:(NSURL*)url;

@end
