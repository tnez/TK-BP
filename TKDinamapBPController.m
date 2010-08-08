/***************************************************************
 
 TKDinamapBPController.m
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100804 - tn
 
 IN
 --------------------------------------------------------------
 delegate
 deviceName
 shouldReadSystolic
 shouldReadDiastolic
 shouldReadHeartRate
 
 ***************************************************************/

#import "TKDinamapBPController.h"


@implementation TKDinamapBPController
@synthesize delegate,deviceName,diastolic,heartRate,systolic;

-(void) awakeFromNib {
	// register for port add/remove notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovePorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];	
	[AMSerialPortList sharedPortList]; // initialize port list to arm notifications
}

-(void) cancelDetermination {
	shouldBreak = YES;
	[self sendCommand:BP_CANCEL_DETERMINATION];
}

-(void) commitResults {
	// record the results
	[self setDiastolic:[newNIBPReading substringWithRange:BP_DIASTOLIC_RANGE]];
	[self setHeartRate:[heartRateReading substringWithRange:BP_HEART_RATE_RANGE]];
	[self setSystolic:[newNIBPReading substringWithRange:BP_SYSTOLIC_RANGE]];
	
	// send delegate messages
	if([delegate respondsToSelector:@selector(dinamapDidFinishDataCollection:)]) {
		[delegate dinamapDidFinishDataCollection:self];
	}
	if([delegate respondsToSelector:@selector(event:didOccurrInComponent:)]) {
		// prepare data dictionary
		NSDictionary *info = [[NSDictionary dictionaryWithObjectsAndKeys: diastolic, @"diastolic",
							   heartRate, @"heartRate", systolic, @"systolic", nil] retain];
		// send data
		[delegate event:[info autorelease] didOccurrInComponent:self];
	}
	// reset determination flag
	determinationIsInProgress = NO;
}

-(void) dealloc {
	[deviceName release];
	[diastolic release];
	[heartRate release];
	[port release];
	[systolic release];
	[super dealloc];
}

-(NSString *) determinationResponse {
	return determinationResponse;
}

-(BOOL) hasDeterminationInProgress {
	return determinationIsInProgress;
}

-(NSString *) heartRateReading {
	return heartRateReading;
}

-(id) init {
	if(self=[super init]) {
		return self;
	}
	return nil;
}

-(void) initPort {
	if(![deviceName isEqualToString:[port bsdPath]]) {
		// close old port
		[port close];
		// set new port
		[self setPort:[[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDRS232Type)] autorelease]];
		// register self as delegate
		[port setDelegate:self];
		// open the port - may take a few seconds
		if([port open]) {
			// ...
		} else { // an error occured while attempting to create port
			[self setPort:nil];
			[self throwError:101];
		}
	}
}

-(NSString *) newNIBPReading {
	return newNIBPReading;
}

-(NSString *) oldNIBPReading {
	return oldNIBPReading;
}

-(BOOL) NIBPReadingIsValid {
	NSInteger oldTime = 0;
	NSInteger newTime = 0;
	oldTime = [[oldNIBPReading substringWithRange:BP_TIME_COUNTER_RANGE] integerValue];
	newTime = [[newNIBPReading substringWithRange:BP_TIME_COUNTER_RANGE] integerValue];
	return newTime < oldTime;
}
	
-(AMSerialPort *) port {
	return port;
}

-(NSString *) prepareStringForDinamap:(NSString *) string {
	// TODO: reimplement checksum calculation and concatenation
	return [string stringByAppendingString:@"\r"];
}

-(void) sendCommand:(NSString *) command {
	if(!port) {
		[self initPort];
	}

	if([port isOpen]) {
		[port writeString:[self prepareStringForDinamap:command] usingEncoding:NSASCIIStringEncoding error:NULL];
		NSString *result = [[port readUpToChar:(char)13 usingEncoding:NSASCIIStringEncoding error:nil] retain];
		[self performSelector:currentAction withObject:result];
		[result release];
	} else { // port is not open
		NSLog(@"Expected open port, but alas :( it is closed");
	}
}

-(void) setDeterminationResponse:(NSString *) newString {
	id scratch = nil;
	if(![newString isEqualToString:determinationResponse]) {
		scratch = determinationResponse;
		determinationResponse = [newString retain];
		[scratch release];
	}
}

-(void) setHeartRateReading:(NSString *) newString {
	id scratch = nil;
	if(![newString isEqualToString:heartRateReading]) {
		scratch = heartRateReading;
		heartRateReading = [newString retain];
		[scratch release];
	}
}

-(void) setNewNIBPReading:(NSString *) newString {
	id scratch = nil;
	if(![newString isEqualToString:newNIBPReading]) {
		scratch = newNIBPReading;
		newNIBPReading = [newString retain];
		[scratch release];
	}
}

-(void) setOldNIBPReading:(NSString *) newString {
	id scratch = nil;
	if(![newString isEqualToString:oldNIBPReading]) {
		scratch = oldNIBPReading;
		oldNIBPReading = [newString retain];
		[scratch release];
	}
}
	
-(void) setPort:(AMSerialPort *) newPort {
	id oldPort = nil;
	if(newPort != port) {
		oldPort = port;
		port = [newPort retain];
		[oldPort release];
	}
}

-(void) setTargetParamater:(NSString *) newString {
	[self performSelector:currentAction withObject:newString];
	currentAction = nil;
}
		
-(void) startDetermination {
	
	// if there is already a determination in progress, exit immediately
	if(determinationIsInProgress) {
		// TODO: send error notification to delegate
		return;
	}

	// notify delegate that determination has begun
	if([delegate respondsToSelector:@selector(dinamapDidBeginDataCollection:)]) {
		[delegate dinamapDidBeginDataCollection:self];
	}
	
	// set flags
	determinationIsInProgress = YES, shouldBreak = NO;
	
	// get current data (we will need this to know when our data is valid)
	currentAction = @selector(setOldNIBPReading:);
	[self sendCommand:BP_READ_NIBP_STATUS];
	
	// start the determination process
	currentAction=@selector(setDeterminationResponse:);
	[self sendCommand:BP_START_DETERMINATION];
	[NSThread detachNewThreadSelector:@selector(startPollingForValidReading) toTarget:self withObject:self];
}

-(void) startPollingForValidReading {

	// create a pool for new objects
	NSAutoreleasePool *pollingPool = [[NSAutoreleasePool alloc] init];
	
	// grab new reading at each polling interval
	do {
		currentAction = @selector(setNewNIBPReading:);
		[self sendCommand:BP_READ_NIBP_STATUS];
		sleep(BP_POLLING_FREQUENCY);
	} while (![self NIBPReadingIsValid] && [port isOpen] && !shouldBreak);
	
	// if the result if valid . . .
	if([self NIBPReadingIsValid]) {
		
		// grab heart rate data
		currentAction = @selector(setHeartRateReading:);
		[self sendCommand:BP_READ_HEART_RATE];
		
		// handle results
		[self commitResults];
		
	// . . . if the results are not valid
	} else {
		
		// attempt to cancel determination and reset flags
		[self sendCommand:BP_CANCEL_DETERMINATION];
		determinationIsInProgress = NO;
	}
	// release the autorelease pool
	[pollingPool drain], [pollingPool release];
}
	
-(void) throwError:(NSInteger) errorCode {
	NSError *error = [NSError errorWithDomain:@"TKDinamapBPController" code:errorCode userInfo:nil];
	if([delegate respondsToSelector:@selector(error:didOccurrInComponent:)]) {
		[delegate error:[error autorelease] didOccurrInComponent:self];
	}
	NSLog(@"Domain=TKDinamapBPController Code=%d",errorCode);
}

-(void) waitForResult {
	// TODO: fix wait for result
	/* myTime.tv_sec = 0, myTime.tv_nsec = 500000;
	// while there is an action to be resolved . . .
	while(currentAction) {
		// ... sleep for a short time
		nanosleep(&myTime, NULL);
	} */
	sleep(2);
}

@end
