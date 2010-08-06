//
//  BPWindowController.m
//  BP
//
//  Created by Travis Nesland on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BPWindowController.h"


@implementation BPWindowController
@synthesize dinamap,subjectBox,noteBox,progressIndicator,startButton,systolicBox,diastolicBox,heartRateBox;

-(void) awakeFromNib {
	[dinamap setDeviceName:[[TKPreferences defaultPrefs] valueForKey:@"bpSerialPortName"]];
}

-(void) dealloc {
	// ...
	[super dealloc];
}

-(IBAction) beginNIBPDetermination:(id) sender {
	[dinamap startDetermination];
}

-(IBAction) cancelNIBPDetermination:(id) sender {
	[dinamap cancelDetermination];
}

-(void) dinamapDidBeginDataCollection:(id) sender {
	[progressIndicator startAnimation:self];
}

-(void) dinamapDidFinishDataCollection:(id) sender {
	[progressIndicator stopAnimation:self];
	[systolicBox setStringValue:[dinamap systolic]];
	[diastolicBox setStringValue:[dinamap diastolic]];
	[heartRateBox setStringValue:[dinamap heartRate]];
}
	
@end
