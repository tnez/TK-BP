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
@synthesize delegate, deviceName, port;

-(void) dealloc {
	[deviceName release];
	[port release];
}

-(void) initPort {
	if(![deviceName isEqualToString:[port bsdPath]]) {
		// close old port
		[port close];
		portIsOpen = NO;
		// set new port
		[self setPort:[[[AMSerialPort alloc] init:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
		// register self as delegate
		[port setDelegate:self];
		// open the port - may take a few seconds
		if([port open]) {
			// listen for data in a seperate thread
			[port readDataInBackground];
		} else { // an error occured while attempting to create port
			[self setPort:nil];
			[self throwError:101];
		}
	}
}

-(AMSerialPort *) port {
	return port;
}

-(NSString *) prepareStringForDinamap:(NSString *) string {
	char *p = [string cStringUsingEncoding:NSASCIIStringEncoding];
	int sum = 0;
	while(*p) {
		putchar(*p);
		sum += (*p++ - ' ' + 1);
		if(sum > 0xFFF) {
			sum -= 0xFFF;
		}
		putchar(' ' + (sum >> 6));
		putchar(' ' + (sum & 0x3F));
		putchar(13);
	}
	return [[NSString stringWithCString:sum encoding:NSASCIIStringEncoding] autorelease];
}

-(void) sendCommand:(NSString *) command {
	if(!port) {
		[self initPort];
	}
	if([port isOpen]) {
		[port writeString:[self prepareStringForDinamap:command] usingEncoding:NSUTF8StringEncoding error:NULL];
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

-(void) startDetermination {
	[self sendCommand:BP_START_DETERMINATION];
	if([delegate respondsToSelector:@selector(dinamapDidBeginDataCollection:)]) {
		[delegate dinamapDidBeginDataCollection:self];
	}
	[self pollForValidReading]; // TODO: create method to open a loop on a new thread that continually polls until expected results are achieved
}

-(void) throwError:(NSInteger) errorCode {
	NSError *error = [NSError errorWithDomain:@"TKDinamapBPController" code:errorCode userInfo:nil];
	if([delegate respondsToSelector:@selector(error:didOccurrInComponent:)]) {
		[delegate error:[error autorelease] didOccurrInComponent:self];
	}
	NSLog(@"Domain=TKDinamapBPController Code=%d",errorCode);
}

@end
