//
//  BPWindowController.h
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TKBPController.h"
#import "TKSubjects.h"
@class BPAppController;


@interface BPWindowController : NSObject {
    IBOutlet id delegate;
	IBOutlet NSProgressIndicator *indicator;
	IBOutlet NSTableView *subjectTable;
	IBOutlet NSTextView *logView;
	IBOutlet NSToolbarItem *cancelButton;
	IBOutlet NSToolbarItem *startButton;
	IBOutlet NSWindow *window;
}

@property (assign) IBOutlet id delegate;
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

@end
