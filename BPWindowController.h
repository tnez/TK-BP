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

@interface BPWindowController : NSObject {
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *startButton;
	IBOutlet NSTableView *subjectTable;
	IBOutlet TKBPController *dinamap;
}
@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSButton *startButton;
@property (assign) IBOutlet NSTableView *subjectTable;
@property (assign) IBOutlet TKBPController *dinamap;
#pragma mark UI COMMANDS
-(IBAction) addSubject:(id) sender;
-(IBAction) beginNIBPDetermination:(id) sender;
-(IBAction) cancelNIBPDetermination:(id) sender;
-(IBAction) removeSubject:(id) sender;
-(IBAction) toggleLogView:(id) sender;
#pragma mark DINAMAP NOTIFICATIONS
-(void) dinamapDidBeginDataCollection:(id) sender;
-(void) dinamapDidFinishDataCollection:(id) sender;
#pragma mark TABLE VIEW DATA SOURCE METHODS
-(int) numberOfRowsInTableView:(NSTableView *) tableView;
-(id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) column row:(int) rowIndex;
#pragma mark WINDOW DELEGATE RESPONSIBILITIES
-(BOOL) windowShouldClose:(id) sender;
-(void) windowWillClose:(NSNotification *) notification;

@end
