//
//  BPWindowController.h
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>
#import "TKDinamapBPController.h"

@interface BPWindowController : NSObject {
	IBOutlet TKDinamapBPController *dinamap;
	IBOutlet NSTextField *subjectBox;
	IBOutlet NSTextField *noteBox;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *startButton;
	IBOutlet NSTextField *systolicBox;
	IBOutlet NSTextField *diastolicBox;
	IBOutlet NSTextField *heartRateBox;
}
@property (assign) IBOutlet TKDinamapBPController *dinamap;
@property (assign) IBOutlet NSTextField *subjectBox;
@property (assign) IBOutlet NSTextField *noteBox;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSButton *startButton;
@property (assign) IBOutlet NSTextField *systolicBox;
@property (assign) IBOutlet NSTextField *diastolicBox;
@property (assign) IBOutlet NSTextField *heartRateBox;
-(IBAction) beginNIBPDetermination:(id) sender;
-(IBAction) cancelNIBPDetermination:(id) sender;
-(void) dinamapDidBeginDataCollection:(id) sender;
-(void) dinamapDidFinishDataCollection:(id) sender;
@end
