//
//  BPAppController.h
//  BP
//
//  Created by Travis Nesland on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>
#import "BPWindowController.h"
#import "TKBPController.h"
#import "TKSubjects.h"

#define BP_PORT [[TKPreferences defaultPrefs] valueForKey:@"bpSerialPortName"]
#define BP_WINDOW_NIB_FILE @"BPWindow"
#define DATA_DIRECTORY [[TKPreferences defaultPrefs] valueForKey:@"dataDirectory"]
#define DATA_FILE [DATA_DIRECTORY stringByAppendingPathComponent:DATA_FILE_NAME]
#define DATA_FILE_EDITOR [[TKPreferences defaultPrefs] valueForKey:@"dataFileEditor"]
#define DATA_FILE_NAME [[TKPreferences defaultPrefs] valueForKey:@"dataFileName"]
#define SHOULD_RUN_ON_LAUNCH [[TKPreferences defaultPrefs] valueForKey:@"shouldRunOnLaunch"]

@interface BPAppController : NSObject {
    IBOutlet BPWindowController *windowController;
    IBOutlet TKBPController *machine;
    TKSubjects *subjects;
}

@property (assign) IBOutlet BPWindowController *windowController;
@property (assign) IBOutlet TKBPController *machine;
@property (retain) TKSubjects *subjects;

#pragma mark Application
-(void) applicationDidFinishLaunching:(NSNotification *) aNote;
-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *) app;
-(BOOL) isClearedToEndSession;
-(void) loadPreferences:(NSNotification *) aNote;
-(void) presentError:(NSError *) error;
-(IBAction) quit:(id) sender;

#pragma mark Windows
-(IBAction) openNewBPWindow:(id) sender;
-(IBAction) openPreferences:(id) sender;
-(BOOL) windowShouldClose:(id) sender;
-(void) windowWillClose:(NSNotification *) aNote;

#pragma mark Subjects
-(IBAction) addSubject:(id) sender;
-(IBAction) clearSubjectData:(id) sender;
-(IBAction) removeSubjects:(id) sender;

#pragma mark Readings
-(IBAction) start:(id) sender;
-(IBAction) cancel:(id) sender;

@end
