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
    [subjects readSubjects];
	[subjectTable reloadData];
	// make window key
	[window makeKeyAndOrderFront:self];
	
	// reset log view
	[logView setString:@""];
}

-(void) dealloc {
    [subjects writeSubjects];
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
	// initialize DINAMAP BP w/ table and pref data
	[dinamap setSubject:[[subjects objectAtIndex:[subjectTable selectedRow]] valueForKey:@"id"]];
	[dinamap setStudy:[[subjects objectAtIndex:[subjectTable selectedRow]] valueForKey:@"study"]];
	[dinamap setDataDirectory:[[TKPreferences defaultPrefs] valueForKey:@"dataDirectory"]];

	// start determination
	[dinamap startDetermination];
}
-(IBAction) cancelNIBPDetermination:(id) sender {
	if(![dinamap hasDeterminationInProgress]) {
		return; // there is nothing to do
	} else {	// go ahead and cancel
		[dinamap cancelDetermination];
		// re-activate subject table
		[subjectTable setEnabled:YES];
		// stop animation
		[indicator stopAnimation:self];
		// log
		[logView insertText:[NSString stringWithFormat:@"Cancelled determination for subject: %@-%@ . . .\n",
							 [dinamap study],[dinamap subject]]];
	}
}

-(IBAction) clearSubjects:(id) sender {
	// run panel to ask user whether they want to clear run times or all subject info
	NSAlert *box = [NSAlert alertWithMessageText:@"What do you want to clear?" defaultButton:@"Timestamps Only" alternateButton:@"All Subject Data" otherButton:@"Cancel" informativeTextWithFormat:@"You can clear subject timestamps or clear all subjects from memory"];
	NSInteger response = [box runModal];
	// select action based on response
	switch (response) {
		case NSAlertDefaultReturn:
			// clear last run time from subjects
			for(NSInteger i=0; i<[subjects count]; i++) {
				[[subjects objectAtIndex:i] removeObjectForKey:@"last"];
			}
			[subjectTable reloadData];
			break;
		case NSAlertAlternateReturn:
			// clear all data from subjects
			[subjects clear];
			[subjectTable reloadData];
			break;
		default:
			// do nothing
			break;
	}
}

-(IBAction) removeSelectedSubject:(id) sender {
	[subjects removeObjectAtIndex:[subjectTable selectedRow]];
	[subjectTable reloadData];
}

#pragma mark DINAMAP NOTIFICATIONS
-(void) dinamapDidBeginDataCollection:(id) sender {
	[subjectTable setEnabled:NO];
	[indicator startAnimation:self];
	[logView insertText:[NSString stringWithFormat:@"Began determination for subject: %@-%@ . . .\n",
						 [dinamap study],[dinamap subject]]];
}
-(void) dinamapDidFinishDataCollection:(id) sender {
	[indicator stopAnimation:self];
	[logView insertText:[NSString stringWithFormat:@"Finished determination for subject: %@-%@ . . .\n",
						 [dinamap study],[dinamap subject]]];	
	// update table
	[[subjects objectAtIndex:[subjectTable selectedRow]] setValue:[[NSDate date] description] forKey:@"last"];
	[subjectTable setEnabled:YES];
}
-(void) error:(NSError *) error didOccurrInComponent:(id) sender withDescription:(NSString *) desc {
	[[NSApp delegate] alertWithMessage:desc];
	if(sender==dinamap) {
		[indicator stopAnimation:self];
		[logView insertText:[NSString stringWithFormat:@"ERROR: Failed determination for subject: %@-%@ . . .\n",[dinamap study],[dinamap subject]]];
		[subjectTable setEnabled:YES];
	}
}
	
#pragma mark TABLE VIEW RESPONSIBILITIES
-(NSInteger) numberOfRowsInTableView:(NSTableView *) table {
	return [subjects count];
}
-(void) tableView:(NSTableView *) table sortDescriptorsDidChange:(NSArray *) oldDescriptors {
	NSArray *newDescriptors = [table sortDescriptors];
	[subjects sortUsingDescriptors:newDescriptors];
	[table reloadData];
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
	[subjects writeSubjects];
}

@end
