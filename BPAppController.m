//
//  BPAppController.m
//  BP
//
//  Created by Travis Nesland on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "BPAppController.h"
@implementation BPAppController
@synthesize windowController, machine, subjects;


#pragma mark Application
-(void) alertWithMessage:(NSString *) message {
	NSAlert *alert =[NSAlert alertWithMessageText:@"Error:" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:message];
	[alert runModal];
}

-(void) applicationDidFinishLaunching:(NSNotification *) aNote {
    // set device name for machine
    [machine setDeviceName:[[TKPreferences defaultPrefs] valueForKey:@"bpSerialPortName"]];
    // load subject data
    [subjects readSubjects];
    // bring focus to front
    [NSApp makeKeyAndOrderFront:self];
    // open bp window
    [self openNewBPWindow:self];
}

-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *) app {
	if([self isClearedToEndSession]) {
		return NSTerminateNow;
	} else {
		return NSTerminateCancel;
	}
}

-(void) applicationWillTerminate:(NSNotification *) notification {
    // write subjects
    [subjects writeSubjects];
}

-(id) init {
    if(self=[super init]) {
        [NSApp setDelegate:self];
        subjects = [[TKSubjects alloc] init];
        return self;
    }
    return nil;
}

-(BOOL) isClearedToEndSession {
    if([machine determinationIsInProgress]) {
        return NO;
    } else {
        return YES;
    }
}

-(IBAction) quit:(id) sender {
	if([self isClearedToEndSession]) {
		[NSApp terminate:self];
	} else {
		[self alertWithMessage:@"Cannot quit application while determination is in progress"];
	}
}


#pragma mark Windows

-(IBAction) openNewBPWindow:(id) sender {
	[NSBundle loadNibNamed:BP_WINDOW_NIB_FILE owner:self];
}

-(IBAction) openPreferences:(id) sender {
	[[TKPreferences defaultPrefs] open:self];
}


#pragma mark Readings

-(IBAction) start:(id) sender {
    // get selection
    NSIndexSet *selection = [[[windowController subjectTable] selectedRowIndexes] copy];
    if([selection count] == 1) {
        // get current subject
        NSDictionary *currentSubject = [NSDictionary dictionaryWithDictionary:[subjects objectAtIndex:[selection firstIndex]]];
        // set current info and begin
        [machine setStudy:[currentSubject valueForKey:@"study"]];
        [machine setSubject:[currentSubject valueForKey:@"id"]];
    } else {
        [self alertWithMessage:@"Must select one (and only one subject) before a determination can be started"];
    }
}

-(IBAction) cancel:(id) sender { // TODO: implement
    if([machine hasDeterminationInProgress]) {
        [machine cancelDetermination];
    }
}

#pragma mark Subjects

-(IBAction) addSubject:(id) sender {
    [subjects add];
}

-(IBAction) clearSubjectData:(id) sender {
	// run panel to ask user whether they want to clear run times or all subject info
	NSAlert *box = [NSAlert alertWithMessageText:@"What do you want to clear?" defaultButton:@"Timestamps Only" alternateButton:@"All Subject Data" otherButton:@"Cancel" informativeTextWithFormat:@"You can clear subject timestamps or clear all subjects from memory"];
	NSInteger response = [box runModal];
	// select action based on response
	switch (response) {
		case NSAlertDefaultReturn:
			// clear last run time from subjects
            [subjects clearDataForKey:@"last"];
			break;
		case NSAlertAlternateReturn:
			// clear all data from subjects
			[subjects clear];
			break;
		default:
			// do nothing
			break;
	}
}

-(IBAction) removeSubjects:(id) sender {
    [subjects removeSubjects:[[windowController subjectTable] selectedRowIndexes]];
}

@end
