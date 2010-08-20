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
    // configure bp machine
    [self loadPreferences:nil];
    // load subjects
    subjects = [[TKSubjects alloc] init];
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

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(id) init {
    if(self=[super init]) {
        [NSApp setDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPreferences:) name:TKPreferencesDidChangeNotification object:nil];
        return self;
    }
    return nil;
}

-(BOOL) isClearedToEndSession {
    if([machine hasDeterminationInProgress]) {
        return NO;
    } else {
        return YES;
    }
}

-(void) loadPreferences:(NSNotification *) aNote {
    [machine setDataDirectory:[[TKPreferences defaultPrefs] valueForKey:@"dataDirectory"]];
    [machine setDeviceName:[[TKPreferences defaultPrefs] valueForKey:TKBPDeviceNameKey]];
    [machine setPollingFrequency:[[TKPreferences defaultPrefs] valueForKey:TKBPPollingFrequencyKey]];
    [machine setReadingMinimumLength:[[TKPreferences defaultPrefs] valueForKey:TKBPReadingMinimumLengthKey]];
}

-(void) presentError:(NSError *) error {
    NSString *header = [NSString stringWithFormat:@"Error Code: %@",[NSNumber numberWithInt:[error code]]];
    NSString *desc = [[error userInfo] valueForKey:@"description"];
    [[NSAlert alertWithMessageText:header defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:desc] runModal];
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

-(BOOL) windowShouldClose:(id) sender {
    return [machine hasDeterminationInProgress];
}

-(void) windowWillClose:(NSNotification *) aNote {
    [self quit:self];
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
        // issue command to bp machine
        [machine startDetermination];
    } else {
        [self alertWithMessage:@"Must select one (and only one subject) before a determination can be started"];
    }
}

-(IBAction) cancel:(id) sender {
    if([machine hasDeterminationInProgress]) {
        [machine cancelDetermination];
    }
}

#pragma mark Subjects

-(IBAction) addSubject:(id) sender {
    [subjects add];
    [[windowController subjectTable] selectRow:[subjects count]-1 byExtendingSelection:NO];
    [[windowController subjectTable] editColumn:0 row:[[windowController subjectTable] selectedRow] withEvent:nil select:YES];
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
