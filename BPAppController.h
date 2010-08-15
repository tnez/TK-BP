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
}
@property (assign) IBOutlet BPWindowController *windowController;
@property (assign) IBOutlet TKBPController *machine;
/**
 @function addSubject
 @abstract Add a new subject record
 */
-(IBAction) addSubject:(id) sender;
/**
 @function awakeFromNib
 @abstract Take care of any thing that needs initializing
*/
-(void) awakeFromNib;
/**
 @function clearData
 @abstract Clear either all subject records or all timestamp records of subjects
 */
-(IBAction) clearData:(id) sender;
/**
 @function isClearedToEndSession
 @abstract Runs a series of tests to determine if the applications is okay to quit
 @result Returns TRUE if the application is okay to quit; i.e. no data collection is currently taking place
 */
-(BOOL) isClearedToEndSession;
/**
 @function openNewBPWindow:(id) sender
 @abstract Opens a window in which the user can control the Dinamap-BP machine
*/
-(IBAction) openNewBPWindow:(id) sender;
/**
 @function openPreferences:(id) sender
 @abstract Open the preferences window
*/
-(IBAction) openPreferences:(id) sender;
/**
 @function quit:(id) sender
 @abstract Quit the application
*/ 
-(IBAction) quit:(id) sender;
/**
 @function removeSubject
 @abstract Remove the selected subject record
 */
-(IBAction) removeSubject:(id) sender;
#pragma mark NSApplicationDelegate
-(void) applicationDidFinishLaunching:(NSNotification *) aNote;
-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *) app;
@end
