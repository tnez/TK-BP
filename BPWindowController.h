//
//  BPWindowController.h
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>
#import "TKBPController.h"
#import "TKSubjects.h"

@interface BPWindowController : NSObject {
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *startButton;
	IBOutlet NSTableView *subjectTable;
	IBOutlet NSTextView *logView;
	IBOutlet NSWindow *window;
	IBOutlet TKBPController *dinamap;
	TKSubjects *subjects;
}
@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *startButton;
@property (assign) IBOutlet NSTableView *subjectTable;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet TKBPController *dinamap;
@property (retain) TKSubjects *subjects;

#pragma mark UI COMMANDS
-(IBAction) addNewSubject:(id) sender;
-(IBAction) beginNIBPDetermination:(id) sender;
-(IBAction) cancelNIBPDetermination:(id) sender;
-(IBAction) removeSelectedSubject:(id) sender;
-(IBAction) toggleLogView:(id) sender;

#pragma mark DINAMAP NOTIFICATIONS
-(void) dinamapDidBeginDataCollection:(id) sender;
-(void) dinamapDidFinishDataCollection:(id) sender;

#pragma mark TABLE VIEW RESPONSIBILITIES
-(NSInteger) numberOfRowsInTableView:(NSTableView *) table;
-(void) tableView:(NSTableView *) table setObjectValue:(id) newObject forTableColumn:(NSTableColumn *) column row:(NSInteger) row;
-(id) tableView:(NSTableView *) table objectValueForTableColumn:(NSTableColumn *) column row:(NSInteger) row;

#pragma mark WINDOW DELEGATE RESPONSIBILITIES
-(BOOL) windowShouldClose:(id) sender;
-(void) windowWillClose:(NSNotification *) notification;

@end
