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
	NSAlert *alert =[NSAlert alertWithMessageText:@"Error:" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:message];
	[alert runModal];
}
-(void) awakeFromNib {
	// register as delegate for shared application
	[NSApp setDelegate:self];
}
-(id) init {
	if(self=[super init]) {
		[self awakeFromNib];
		return self;
	} else {
		return nil;
	}
}
-(BOOL) isClearedToEndSession {
	// TODO: return NO if we are currently undergoing determination
	return YES;
}
-(IBAction) openNewBPWindow:(id) sender {
	[NSBundle loadNibNamed:BP_WINDOW_NIB_FILE owner:self];
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
#pragma mark NSApplicationDelegate
-(void) applicationDidFinishLaunching:(NSNotification *) aNote {
	if(SHOULD_RUN_ON_LAUNCH) {
		[self openNewBPWindow:self];
	} else {
		// do nothing
	}
}
-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *) app {
	if([self isClearedToEndSession]) {
		return NSTerminateNow;
	} else {
		[self alertWithMessage:@"Waiting for data from Dinamap BP"];		
		return NSTerminateCancel;
	}
}
@end
