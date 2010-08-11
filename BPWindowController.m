//
//  BPWindowController.m
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPWindowController.h"


@implementation BPWindowController
@synthesize cancelButton,startButton,subjects,subjectTable,logView,window,dinamap;

-(void) awakeFromNib {
	// set device name for dinamap
	[dinamap setDeviceName:[[TKPreferences defaultPrefs] valueForKey:@"bpSerialPortName"]];
	// register for notifications from dinamap

	// load subject data
	subjects = [[TKSubjects alloc] init];
	[subjectTable reloadData];
	// make window key
	[window makeKeyAndOrderFront:self];
}

-(void) dealloc {
	[subjects release];
	[super dealloc];
}

#pragma mark UI COMMANDS
-(IBAction) addNewSubject:(id) sender {
	[subjects add];
	[subjectTable reloadData];
	// select the row in table and begin editing
	[subjectTable selectRow:([subjects count]-1) byExtendingSelection:NO];
	[subjectTable editColumn:0 row:([subjects count]-1) withEvent:nil select:YES];
}
-(IBAction) beginNIBPDetermination:(id) sender {
	// set current subject and study in dinamap
	[dinamap setSubject:[[subjects objectAtIndex:[subjectTable selectedRow]] valueForKey:@"id"]];
	[dinamap setSubject:[[subjects objectAtIndex:[subjectTable selectedRow]] valueForKey:@"study"]];
	// start determination
	[dinamap startDetermination];
	// temporarily disable subject table
	[subjectTable setEnabled:NO];
}
-(IBAction) cancelNIBPDetermination:(id) sender {
	[dinamap cancelDetermination];
	// re-activate subject table
	[subjectTable setEnabled:YES];
	
}
-(IBAction) removeSelectedSubject:(id) sender {
	[subjects removeObjectAtIndex:[subjectTable selectedRow]];
	[subjectTable reloadData];
}
-(IBAction) toggleLogView:(id) sender {
	[logView setHidden:![logView isHidden]];
}

#pragma mark DINAMAP NOTIFICATIONS
-(void) dinamapDidBeginDataCollection:(id) sender {
	//
}
-(void) dinamapDidFinishDataCollection:(id) sender {
	//
}

#pragma mark TABLE VIEW RESPONSIBILITIES
-(NSInteger) numberOfRowsInTableView:(NSTableView *) table {
	return [subjects count];
}
-(void) tableView:(NSTableView *) table setObjectValue:(id) newObject forTableColumn:(NSTableColumn *) column row:(NSInteger) row {
	[[subjects objectAtIndex:row] setValue:newObject forKey:[column identifier]];
}
-(id) tableView:(NSTableView *) table objectValueForTableColumn:(NSTableColumn *) column row:(NSInteger) row {
	return [[subjects objectAtIndex:row] valueForKey:[column identifier]];
}
#pragma mark WINDOW DELEGATE RESPONSIBILITIES
-(BOOL) windowShouldClose:(id) sender {
	return ![dinamap hasDeterminationInProgress];
}
-(void) windowWillClose:(NSNotification *) notification {
	[subjects release];
}

@end
