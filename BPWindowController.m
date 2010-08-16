//
//  BPWindowController.m
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPWindowController.h"


@implementation BPWindowController
@synthesize delegate,subjects,cancelButton,startButton,subjectTable,indicator,logView,window;

-(void) awakeFromNib {
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TKSubjectsDidChange:) name:TKSubjectsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TKBPControllerDidBeginDataCollection:) name:TKBPControllerDidBeginDataCollectionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TKBPControllerDidCancelDataCollection:) name:TKBPControllerDidCancelDataCollectionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TKBPControllerDidFinishDataCollection:) name:TKBPControllerDidFinishDataCollectionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TKBPControllerWillThrowError:) name:TKBPControllerWillThrowErrorNotification object:nil];
	// make window key
	[window makeKeyAndOrderFront:self];
}

-(void) dealloc {
    // de-register notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma mark BP CONTROLLER EVENT RESPONSES
-(void) TKBPControllerDidBeginDataCollection:(NSNotification *) aNote {
	[subjectTable setEnabled:NO];
	[indicator startAnimation:self];
}
-(void) TKBPControllerDidCancelDataCollection:(NSNotification *) aNote {
	[indicator stopAnimation:self];
	[subjectTable setEnabled:YES];
}
-(void) TKBPControllerDidFinishDataCollection:(NSNotification *) aNote {
	[indicator stopAnimation:self];
	[subjectTable setEnabled:YES];
}
-(void) TKBPControllerWillThrowError:(NSNotification *) aNote {
	[indicator stopAnimation:self];
	[subjectTable setEnabled:YES];
}

#pragma mark SUBJECT EVENT RESPONSES
-(void) TKSubjectsDidChange:(NSNotification *) aNote {
    [subjectTable reloadData];
}

#pragma mark TABLE VIEW
-(NSInteger) numberOfRowsInTableView:(NSTableView *) table {
	return [subjects count];
}
-(void) tableView:(NSTableView *) table sortDescriptorsDidChange:(NSArray *) oldDescriptors {
	NSArray *newDescriptors = [table sortDescriptors];
	[subjects sortUsingDescriptors:newDescriptors];
}
-(void) tableView:(NSTableView *) table setObjectValue:(id) newObject forTableColumn:(NSTableColumn *) column row:(NSInteger) row {
	[[subjects objectAtIndex:row] setValue:newObject forKey:[column identifier]];
}
-(id) tableView:(NSTableView *) table objectValueForTableColumn:(NSTableColumn *) column row:(NSInteger) row {
	return [[subjects objectAtIndex:row] valueForKey:[column identifier]];
}

#pragma mark WINDOW DELEGATE RESPONSIBILITIES
-(BOOL) windowShouldClose:(id) sender {
	return [delegate isClearedToEndSession];
}
-(void) windowWillClose:(NSNotification *) notification {
    [delegate quit:self];
}

@end
