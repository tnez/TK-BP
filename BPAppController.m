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
	NSAlert *alert =[NSAlert alertWithMessageText:@"Error:"
									defaultButton:@"OK"
								  alternateButton:nil
									  otherButton:nil
						informativeTextWithFormat:message];
	[alert runModal];
}

-(void) awakeFromNib {
	// register as delegate for shared application
	[NSApp setDelegate:self];
	// if should run on launch, then begin
	if(SHOULD_RUN_ON_LAUNCH) {
		if([self isClearedToBeginSession]) {
			[self openNewBPWindow:self];
		} else {}
	} else {}
}

-(BOOL) isClearedToBeginSession {
	// TODO: reimplement
	return YES;
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

-(BOOL) isClearedToEndSession {
	// TODO: return NO if we are currently undergoing determination
	return YES;
}

-(IBAction) openNewBPWindow:(id) sender {
	if([self isClearedToBeginSession]) {
		[NSBundle loadNibNamed:BP_WINDOW_NIB_FILE owner:self];
		
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
	if([self isClearedToEndSession]) {
		[NSApp terminate:self];
	} else {
		[self alertWithMessage:@"Waiting for data from Dinamap BP"];
	}
}
	
@end
