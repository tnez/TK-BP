//
//  BPAppController.m
//  BP
//
//  Created by Travis Nesland on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPAppController.h"


@implementation BPAppController

-(void) alertWithMessage:(NSString *) message {
	[NSAlert alertWithMessageText:@"Error:"
					defaultButton:@"OK"
				  alternateButton:nil
					  otherButton:nil
		informativeTextWithFormat:message];
}

-(void) awakeFromNib {
	// register as delegate for shared application
	[NSApp setDelegate:self];
	// if should run on launch, then begin
	if(SHOULD_RUN_ON_LAUNCH) {
		[self openNewBPWindow:self];
	} else { }
}

-(void) createNewBPInstance {
	if([self isClearedToBeginSession]) {
		BPInstance = [[TKDinamapBPController alloc] init];
		[BPInstance setDeviceName:BP_PORT];
	} else { }
}

-(BOOL) isClearedToBeginSession {
	// check that data directory exists
	BOOL isDirectory, exists;
	exists = [[NSFileManager defaultManager] fileExistsAtPath:DATA_DIRECTORY isDirectory:&isDirectory];
	if(!(exists && isDirectory)) {
		[self alertWithMessage:@"Data directory is not valid"];
		return NO;
	}
	// all checks passed at this point, so . . .
	return YES;
}

-(IBAction) openNewBPWindow:(id) sender {
	if(!BPInstance) {
		[self createNewBPInstance];		
		if([NSBundle loadNibNamed:BP_WINDOW_NIB_FILE owner:BPInstance]) {
			// . . .
		} else {}
	} else {}
}

-(IBAction) openDataFile:(id) sender {
	// if data file task does not already exist . . .
	if(![dataFileTask isRunning]) {
		dataFileTask = [NSTask launchedTaskWithLaunchPath:DATA_FILE_EDITOR arguments:[NSArray arrayWithObject:DATA_FILE]];
	} else { }
}

-(IBAction) openPreferences:(id) sender {
	[[TKPreferences defaultPrefs] open:self];
}
		
-(IBAction) quit:(id) sender {
	if(![BPInstance hasDeterminationInProgress]) {
		[NSApp terminate];
	} else {
		[self alertWithMessage:@"Waiting for data from Dinamap BP"];
	}
}
	
@end
