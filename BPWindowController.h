//
//  BPWindowController.h
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TKSubjects.h"
#import "TKBPController.h"
//#import "BPAppController.h"
@class BPAppController;

@interface BPWindowController : NSObject {
    IBOutlet id delegate;
    IBOutlet TKSubjects *subjects;
	IBOutlet NSProgressIndicator *indicator;
	IBOutlet NSTableView *subjectTable;
	IBOutlet NSTextView *logView;
	IBOutlet NSToolbarItem *cancelButton;
	IBOutlet NSToolbarItem *startButton;
	IBOutlet NSWindow *window;
}

@property (assign) IBOutlet id delegate;
@property (assign) IBOutlet TKSubjects *subjects;
@property (assign) IBOutlet NSToolbarItem *cancelButton;
@property (assign) IBOutlet NSToolbarItem *startButton;
@property (assign) IBOutlet NSTableView *subjectTable;
@property (assign) IBOutlet NSProgressIndicator *indicator;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet NSWindow *window;

#pragma mark BP CONTROLLER EVENT RESPONSES
-(void) TKBPControllerDidBeginDataCollection:(NSNotification *) aNote;
-(void) TKBPControllerDidCancelDataCollection:(NSNotification *) aNote;
-(void) TKBPControllerDidFinishDataCollection:(NSNotification *) aNote;
-(void) TKBPControllerWillThrowError:(NSNotification *) aNote;

#pragma mark SUBJECT EVENT RESPONSES
-(void) TKSubjectsDidChange:(NSNotification *) aNote;

#pragma mark TABLE VIEW
-(NSInteger) numberOfRowsInTableView:(NSTableView *) table;
-(void) tableView:(NSTableView *) table sortDescriptorsDidChange:(NSArray *) oldDescriptors;
-(void) tableView:(NSTableView *) table setObjectValue:(id) newObject forTableColumn:(NSTableColumn *) column row:(NSInteger) row;
-(id) tableView:(NSTableView *) table objectValueForTableColumn:(NSTableColumn *) column row:(NSInteger) row;

#pragma mark WINDOW DELEGATE EVENT RESPONSES
-(BOOL) windowShouldClose:(id) sender;
-(void) windowWillClose:(NSNotification *) notification;

@end
