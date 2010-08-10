//
//  BPWindowController.m
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPWindowController.h"


@implementation BPWindowController
@synthesize cancelButton,startButton,subjectTable,dinamap;

-(void) awakeFromNib {

	// set device name for dinamap
	[dinamap setDeviceName:[[TKPreferences defaultPrefs] valueForKey:@"bpSerialPortName"]];

	// load subject data
	[dinamap loadSubjects];
	[subjectTable reloadData];

}

-(void) dealloc {
	// ...
	[super dealloc];
}

-(IBAction) addSubject:(id) sender {
	[dinamap addSubject];
	[subjectTable reloadData];
}

-(IBAction) beginNIBPDetermination:(id) sender {
	// set current subject in model
	[dinamap setCurrentSubject:[subjectTable selectedRow]];
	// start determination
	[dinamap startDetermination];
}

-(IBAction) cancelNIBPDetermination:(id) sender {
	[dinamap cancelDetermination];
}

-(IBAction) removeSubject:(id) sender {
	[dinamap removeSubjectAtIndex:[subjectTable selectedRow]];
	[subjectTable reloadData];
}

-(IBAction) toggleLogView:(id) sender {
	// TODO: Implement toggle log view
}

-(void) dinamapDidBeginDataCollection:(id) sender {
	//
}

-(void) dinamapDidFinishDataCollection:(id) sender {
	//
}

-(int) numberOfRowsInTableView:(NSTableView *) tableView {
	return [[dinamap subjects] count];
}

-(id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) column row:(int) row {
	return [[[dinamap subjects] objectAtIndex:row] valueForKey:[column identifier]];
}

-(BOOL) windowShouldClose:(id) sender {
	return ![dinamap hasDeterminationInProgress];
}

-(void) windowWillClose:(NSNotification *) notification {
	// tell model to save our subject info
	[dinamap saveSubjects];
}

@end
