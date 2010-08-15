//
//  BPAppController.m
//  BP
//
//  Created by Travis Nesland on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "BPAppController.h"
@implementation BPAppController
@synthesize windowController, machine;
-(IBAction) addSubject:(id) sender {
    [windowController addNewSubject:self];
}
-(void) alertWithMessage:(NSString *) message {
	NSAlert *alert =[NSAlert alertWithMessageText:@"Error:" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:message];
	[alert runModal];
}
-(void) awakeFromNib {
	// register as delegate for shared application
	[NSApp setDelegate:self];
}
-(IBAction) clearData:(id) sender {
    [windowController clearSubjects:self];
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
    if([machine determinationIsInProgress]) {
        return NO;
        return NO;
    } else {
        return YES;
    }
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
		[self alertWithMessage:@"Cannot quit application while determination is in progress"];
	}
}
-(IBAction) removeSubject:(id) sender {
    [windowController removeSelectedSubject:self];
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
		return NSTerminateCancel;
	}
}
@end
