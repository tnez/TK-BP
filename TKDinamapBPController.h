/***************************************************************
 
 TKDinamapBPController.h
 TKUtility
 
 Author: Travis Nesland <tnesland@gmail.com>
 Maintainer: Travis Nesland <tnesland@gmail.com>
 
 Copyright 2010 Residential Research Facility
 (University of Kentucky). All rights reserved.
 
 LastMod: 20100804 - tn
 
 IN
 --------------------------------------------------------------
 bpPort
 delegate
 
 ***************************************************************/

#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"
#import "AMSerialPortAdditions.h"

/**
 Command Definitions For Dinamap BP
*/
#define BP_START_DETERMINATION @" NC0"
#define BP_CANCEL_DETERMINATION @" ND"
#define BP_READ_NIBP_STATUS @" NA"
#define BP_READ_HEART_RATE @" RC"

/**
 Public API
*/
@interface TKDinamapBPController : NSObject {
@public
	id delegate;
	NSString *deviceName;
	BOOL shouldReadSystolic;
	BOOL shouldReadDiastolic;
	BOOL shouldReadHeartRate;
@private
	AMSerialPort *port;
}
@property (assign) id delegate;
@property (nonatomic, retain) NSString *deviceName;
@property (readwrite) BOOL shouldReadSystolic;
@property (readwrite) BOOL shouldReadDiastolic;
@property (readwrite) BOOL shouldReadHeartRate;
/**
 Public Methods
 */
-(void) startDetermination;
-(void) cancelDetermination;
-(NSString *) systolic;
-(NSString *) diastolic;
-(NSString *) heartRate;
@end

/**
 Private Methods
*/ 
@interface TKDinamapBPController ()
-(void) initPort;
-(AMSerialPort *) port;
-(NSString *) prepareStringForDinamap:(NSString *) string;
-(void) serialPortReadData:(NSDictionary *) dictionary;
-(void) sendCommand:(NSString *) string;
-(void) setPort:(AMSerialPort *) newPort;
-(void) throwError:(NSInteger) errorCode;
@end

/**
 Delegate Methods
*/ 
@interface NSObject (TKDinamapBPControllerDelegate)
/**
 @function dinamapDidBeginDataCollection:
 @abstract Sent to delegate after the Dinamap BP monitor is sent the message to start NIBP determination
 */
-(void) dinamapDidBeginDataCollection:(id) sender;
/**
 @function dinamapDidFinishDataCollection:
 @abstract Sent to delegate after a valid reading for NIBP has been returned
 */
-(void) dinamapDidFinishDataCollection:(id) sender;
/**
 @function error:hasOccurredInComponent:
 @abstract Sent to delegate when an error is encounterd
 @availability Pending
 */
-(void) error:(NSError *) error didOccurrInComponent:(id) sender;
/**
 @function event:didOccurrInComponent:
 @abstract Sends data to delegate when event occurs
 @parameter eventInfo NSDictionary containing systolic, diastolic and heart rate data if the previous have been set to collect
 @parameter sender The componenet seding the message
 */
-(void) event:(NSDictionary *) eventInfo didOccurrInComponent:(id) sender;
@end
