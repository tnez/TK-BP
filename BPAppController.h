//
//  BPAppController.h
//  BP
//
//  Created by Travis Nesland on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>
@class TKDinamapBPController;


#define BP_PORT [[TKPreferences defaultPrefs] valueForKey:@"bpSerialPortName"]
#define BP_WINDOW_NIB_FILE @"BPWindow"
#define DATA_DIRECTORY [[TKPreferences defaultPrefs] valueForKey:@"dataDirectory"]
#define DATA_FILE [DATA_DIRECTORY stringByAppendingPathComponent:DATA_FILE_NAME]
#define DATA_FILE_EDITOR [[TKPreferences defaultPrefs] valueForKey:@"dataFileEditor"]
#define DATA_FILE_NAME [[TKPreferences defaultPrefs] valueForKey:@"dataFileName"]
#define SHOULD_RUN_ON_LAUNCH [[TKPreferences defaultPrefs] valueForKey:@"shouldRunOnLaunch"]


@interface BPAppController : NSObject {
@private
	NSTask *dataFileTask;
	TKDinamapBPController *BPInstance;
}

/**
 @function awakeFromNib
 @abstract Take care of any thing that needs initializing
*/
-(void) awakeFromNib;

/**
 @function isClearedToBeginSession
 @abstract Runs a series of tests to determine if the applications requirements are met
 @result Returns TRUE if the application can proceed
*/
-(BOOL) isClearedToBeginSession;

/**
 @function openNewBPWindow:(id) sender
 @abstract Opens a window in which the user can control the Dinamap-BP machine
*/
-(IBAction) openNewBPWindow:(id) sender;

/**
 @function openDataFile:(id) sender
 @abstract Open the datafile in text editor of choice (text editor can be selected in the preferences window).
*/ 
-(IBAction) openDataFile:(id) sender;

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

@end
