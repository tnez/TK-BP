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

#import "TKBPController.h"



@implementation TKBPController
@synthesize dataDirectory,delegate,determinationIsInProgress,deviceName,diastolic,
            heartRate,map,pollingFrequency,readingMinimumLength,study,subject,systolic;

-(void) awakeFromNib {
	[AMSerialPortList sharedPortList];
}

-(void) cancelDetermination {
    if(determinationIsInProgress) {
        shouldBreak = YES;
        [self sendCommand:BP_CANCEL_DETERMINATION];
    }
}

-(void) commitResults {
	
	// if reading is valid...
	if([self NIBPReadingIsValid]) {
		// record the results in subject dictionary
		[self setDiastolic:[newNIBPReading substringWithRange:BP_DIASTOLIC_RANGE]];
		[self setHeartRate:[heartRateReading substringWithRange:BP_HEART_RATE_RANGE]];
		[self setMap:[newNIBPReading substringWithRange:BP_MAP_RANGE]];
		[self setSystolic:[newNIBPReading substringWithRange:BP_SYSTOLIC_RANGE]];

        // post notifications and delegate messages
        [[NSNotificationCenter defaultCenter] postNotificationName:TKBPControllerDidFinishDataCollectionNotification object:self];
		if([delegate respondsToSelector:@selector(event:didOccurrInComponent:)]) {
			// prepare data dictionary
			NSDictionary *info = [[NSDictionary dictionaryWithObjectsAndKeys: diastolic, @"diastolic",
								   heartRate, @"heartRate", systolic, @"systolic", nil] retain];
			// send data
			[delegate event:[info autorelease] didOccurrInComponent:self];
		}
        
		// perform simple logging of data
		[self performSimpleLogging];

	} else { // NIBP was not valid
		[self throwError:TKBPFailedDeterminationError];
	}
}

-(NSString *) datafile {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"MM-dd-yy"];
	NSString *filename = [[NSString stringWithFormat:@"%@-%@ %@ BP",
							[self study],[self subject],[formatter stringFromDate:[NSDate date]]] retain];
	return [filename autorelease];
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
		[self awakeFromNib];
		return self;
	} else {
		return nil;
	}
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
            shouldBreak = YES;
			[self setPort:nil];
            [self throwError:TKBPCouldNotEstablishPortError];
		}
	}
}

-(NSString *) newNIBPReading {
	return newNIBPReading;
}

-(NSString *) oldNIBPReading {
	return oldNIBPReading;
}

-(BOOL) NIBPReadingIsFinished {
	// if strings are long enough to evaluate . . .
	if (!([oldNIBPReading length] < [readingMinimumLength integerValue] || [newNIBPReading length] < [readingMinimumLength integerValue])) {
		NSInteger oldTime = 0;
		NSInteger newTime = 0;
		NSInteger status = 0;
		oldTime = [[oldNIBPReading substringWithRange:BP_TIME_COUNTER_RANGE] integerValue];
		newTime = [[newNIBPReading substringWithRange:BP_TIME_COUNTER_RANGE] integerValue];
		status = [[newNIBPReading substringWithRange:BP_STATUS_RANGE] integerValue];
		// newTime has been recorded (new measurement) or an error status has been reported
		return newTime < oldTime || status > 2;

	} else { // strings are too short to evaluate
		return NO;
	}
}

-(BOOL) NIBPReadingIsValid {
	return [[newNIBPReading substringWithRange:BP_STATUS_RANGE] integerValue] == 1;
}

-(void) performSimpleLogging {
	// prepare string for logging
	NSString *dataString = [[NSString stringWithFormat:@"%@\t%@\n%@\t%@\t%@\t%@\n\n",
							 [self datafile],[self time],heartRate,systolic,diastolic,map] retain];

	[[TKLogging mainLogger] writeToDirectory:[dataDirectory stringByStandardizingPath] file:BP_DATA_FILE_NAME contentsOfString:dataString overWriteOnFirstWrite:NO];
	[dataString autorelease];
}

-(AMSerialPort *) port {
	return port;
}

-(NSString *) prepareStringForDinamap:(NSString *) string {
	// TODO: reimplement checksum calculation and concatenation
	return [string stringByAppendingString:@"\r"];
}

-(void) sendCommand:(NSString *) command {
    
    // if we have already performed break, we should not be sending commands
    if(shouldBreak) { return; }

	// open port if it does not exist
	if(!port) {
		[self initPort];
	}
	if([port isOpen]) { // when port is open, continue processing
		// flush any old data
		[port flushInput:YES output:YES];
		// send command
		[port writeString:[self prepareStringForDinamap:command] usingEncoding:NSASCIIStringEncoding error:NULL];
		// catch result (synchronously)
		NSString *result = [[port readUpToChar:(char)13 usingEncoding:NSASCIIStringEncoding error:nil] retain];
		[self performSelector:currentAction withObject:result];
		[result release];
	} else { // port is not open . . .
        // . . . so set result equal to empty string
        [self performSelector:currentAction withObject:@""];
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

-(BOOL) shouldContinuePolling {
	// check for errors and quit flags
	if(shouldBreak) {
        return NO;
    }
	if(![port isOpen]) {
        [self throwError:TKBPCouldNotEstablishPortError];
        shouldBreak = YES;
		return NO;
	}
	if(!newNIBPReading) {
		[self throwError:TKBPNullResultsError];
        shouldBreak = YES;
		return NO;
	}
	// if we've made it past all those errors, check the expected case
	return ![self NIBPReadingIsFinished];
}

-(void) startDetermination {
	
	// if there is already a determination in progress, exit immediately
	if(determinationIsInProgress) {
		return;
	}
	
	// check that our datafile exists
	BOOL exists; BOOL asDir;
	exists = [[NSFileManager defaultManager] fileExistsAtPath:[dataDirectory stringByStandardizingPath] isDirectory:&asDir];
	if(!exists || !asDir) {
		[self throwError:TKBPInvalidDataDirectoryError];
		return;
	}
	
	// notififcation that determination has begun
    [[NSNotificationCenter defaultCenter] postNotificationName:TKBPControllerDidBeginDataCollectionNotification object:self];
	
	// set flags and initialize values
	determinationIsInProgress = YES, shouldBreak = NO;
	[self setOldNIBPReading:@""];
	[self setNewNIBPReading:@""];
	[self setHeartRateReading:@""];
	
	// get current data (we will need this to know when our data is valid)
	currentAction = @selector(setOldNIBPReading:);
	[self sendCommand:BP_READ_NIBP_STATUS];
	
	// start the determination process
	currentAction=@selector(setDeterminationResponse:);
	[self sendCommand:BP_START_DETERMINATION];
	[NSThread detachNewThreadSelector:@selector(startPollingForValidReading:) toTarget:self withObject:self];
}

-(void) startPollingForValidReading: (id)anObject {
	
	// create a pool for new objects
	NSAutoreleasePool *pollingPool = [[NSAutoreleasePool alloc] init];
	
	// grab new reading at each polling interval
	do {
		currentAction = @selector(setNewNIBPReading:);
		[self sendCommand:BP_READ_NIBP_STATUS];
		sleep([pollingFrequency integerValue]);
	} while ([self shouldContinuePolling]);
	
    if(!shouldBreak) { // if we did not force quit the determination
        // grab heart rate data
        currentAction = @selector(setHeartRateReading:);
        [self sendCommand:BP_READ_HEART_RATE];
        // resolve the results
        [self commitResults];
    }
	
	[pollingPool drain];
	determinationIsInProgress = NO;				// reset determination flag
}

-(NSString *) time {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HH:mm:ss"];
	return [formatter stringFromDate:[NSDate date]];
}

-(void) throwError:(TKBPControllerErrorCode) errorCode {
    // create dictionary from error file
    NSMutableDictionary *info = [[NSMutableDictionary dictionaryWithDictionary:[ERRORS valueForKey:[[NSNumber numberWithInteger:errorCode] stringValue]]] retain];
    // create error
	NSError *error = [[NSError errorWithDomain:@"TKDinamapBPController" code:errorCode userInfo:(NSDictionary *)[info autorelease]] retain];
    // log
	NSLog(@"Domain=TKDinamapBPController Code=%d Desc=%@",errorCode,[info valueForKey:@"description"]);
    // notify of intention to send error
    [[NSNotificationCenter defaultCenter] postNotificationName:TKBPControllerWillThrowErrorNotification object:self];
    // post error to app
    if([[NSApp delegate] respondsToSelector:@selector(presentError:)]) {
        [[NSApp delegate] presentError:[error autorelease]];
    } else {
        [NSApp presentError:[error autorelease]];
    }
}

@end


/** Keys */
NSString * const TKBPDeviceNameKey              = @"TKBPDeviceName";
NSString * const TKBPPollingFrequencyKey         = @"TKPollingFrequency";
NSString * const TKBPReadingMinimumLengthKey    = @"TKReadingMinimumLength";


/** Notifications */
NSString * const TKBPControllerDidBeginDataCollectionNotification   = @"TKBPControllerDidBeginDataCollection";
NSString * const TKBPControllerDidCancelDataCollectionNotification  = @"TKConrollerDidCancelDataCollection";
NSString * const TKBPControllerDidFinishDataCollectionNotification  = @"TKBPControllerDidFinishDataCollection";
NSString * const TKBPControllerWillThrowErrorNotification           = @"TKBPControllerWillThrowError";
