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
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"

/**
 Command Definitions For Dinamap BP
*/
#define BP_START_DETERMINATION @" NC0!E"
#define BP_CANCEL_DETERMINATION @" ND!5"
#define BP_READ_NIBP_STATUS @" NA!2"
#define BP_READ_HEART_RATE @" RC!8"
/**
 Ranges For Data Extraction
 */
#define BP_DIASTOLIC_RANGE NSMakeRange(13,3)
#define BP_HEART_RATE_RANGE NSMakeRange(4,3)
#define BP_MAP_RANGE NSMakeRange(16,3)
#define BP_STATUS_RANGE NSMakeRange(3,1)
#define BP_SYSTOLIC_RANGE NSMakeRange(10,3)
#define BP_TIME_COUNTER_RANGE NSMakeRange(6,4)
/**
 Behavior
 */
#define BP_POLLING_FREQUENCY 1
#define BP_READING_MIN_LENGTH 20 // if reading is less than this length, will not consider valid reading
/**
 Environment
 */
#define BP_DEFAULT_SUBJECT_FILE_NAME @"subjects.plist"
#define BP_SUBJECT_FILE_PATH [[NSBundle mainBundle] resourcePath]



@interface TKBPController : NSObject {
	@private
	SEL currentAction;				 // action to be performed when we read data from serial port
	NSMutableDictionary *currentSubject;	// the subject we are currently dealing with, as a
											// mutable dictionary
	id delegate;					 // should be whatever object will be handling data
	BOOL determinationIsInProgress;  // 
	NSString *determinationResponse; //
	NSString *deviceName;			 // full path to port i.e. /dev/cu.usbserial-A600b3gB
	NSString *diastolic;			 // resolved diastolic reading
	NSString *heartRate;			 // resolved heartRate reading
	NSString *heartRateReading;		 // This value represents the entire heart rate string
									 // returned from the machine
	NSString *map;					 // resolved mean arterial pressure
	NSString *newNIBPReading;		 // This value is used internally and represents the
									 // value taken after a determination is started, new
									 // and old NIBP readings will be compared to determine
									 // when the new reading is valid
	NSString *oldNIBPReading;		 // This reading is used internally and represents the
									 // value taken right before starting a new determination
	AMSerialPort *port;				 // Our Dinamap BP as a serial port
	BOOL shouldBreak;				 // used to terminate polling loop
	NSString *systolic;				 // resolved systolic reading
	NSMutableArray *subjects;		 // contains all saved subjects for this study, also
									 // contains BP data pertaining to this study
									 // each record is a dictionary with the keys:
									 // {name,id,study,last,hr,sys,dis,map}	
	NSString *targetString;			 //	
	struct timespec myTime;			 // value used in loops to wait for events	
}
@property (assign) id delegate;
@property (nonatomic, retain) NSString *deviceName;		// full path to port i.e. /dev/cu.usbserial-A600b3gB
@property (nonatomic, retain) NSString *diastolic;		// diastolic reading
@property (nonatomic, retain) NSString *heartRate;		// heart rate reading
@property (nonatomic, retain) NSString *map;			// map reading
@property (nonatomic, retain) NSString *systolic;		// systolic reading	

-(void) addSubject;
-(id) subjects;
-(void) removeSubjectAtIndex:(NSInteger) index;
/**
 @function startDetermination
 @abstract Initiates NIBP determination sequence for Dinamap BP machine on established port.
 */
-(void) startDetermination;

/**
 @function cancelDetermination
 @abstract Cancels any currently running NIBP determination sequence for Dinamap BP on established port.
 */
-(void) cancelDetermination;

/**
 @function diastolic
 @result The last recorded diastolic value or nil.
 @discussion This value is only assured to be accurate immediately after receiving a 'dinamapDidFinishDataCollection' message.
 */
-(NSString *) diastolic;

/**
 @function hasDeterminationInProgress
 @result Returns YES if a determination has been started but has not finished or cancelled
 */
-(BOOL) hasDeterminationInProgress;

/**
 @function heartRate
 @result The last recorded heartRate value or nil.
 @discussion This value is only assured to be accurate immediately after receiving a 'dinamapDidFinishDataCollection' message.
 */
-(NSString *) heartRate;

/**
 @function map
 @result The last recorded map value or nil.
 @discussion This value is only assured to be accurate immediately after receiving a 'dinamapDidFinishDataCollection' message.
 */
-(NSString *) map;

/**
 @function setCurrentSubject:
 @discussion Set the value of the subject on which we intent to perform some kind of operation
 */
-(void) setCurrentSubject:(NSInteger) index;

/**
 @function systolic
 @result The last recorded systolic value or nil.
 @discussion This value is only assured to be accurate immediately after receiving a 'dinamapDidFinishDataCollection' message.
 */
-(NSString *) systolic;

@end


@interface TKBPController (TKDinamapBPControllerPrivate)
-(void) awakeFromNib;
-(void) commitResults;
-(NSString *) heartRateReading;
-(void) initPort;
-(void) loadSubjects;
-(NSString *) newNIBPReading;
-(BOOL) NIBPReadingIsValid;
-(NSString *) oldNIBPReading;
-(AMSerialPort *) port;
-(NSString *) prepareStringForDinamap:(NSString *) string;
-(void) saveSubjects;
-(void) serialPortReadData:(NSDictionary *) dictionary;
-(void) sendCommand:(NSString *) string;
-(void) setHeartRateReading:(NSString *) newString;
-(void) setNewNIBPReading:(NSString *) newString;
-(void) setOldNIBPReading:(NSString *) newString;
-(void) setPort:(AMSerialPort *) newPort;
-(void) setTargetParameter:(NSString *) newString;
-(void) startPollingForValidReading;
-(NSInteger) timeCounterForReading:(NSString *) reading;
-(void) throwError:(NSInteger) errorCode;
-(void) waitForResult;
@end


@interface NSObject (TKDinamapBPControllerDelegate)

/* TODO: Change from delegate messages to notifications - this makes more sense going forward, but event / error occurences will still be passed to delegate to facilitate a chain of information handling */

/**
 @function dinamapDidBeginDataCollection:
 @abstract Sent to delegate after the Dinamap BP monitor is sent the message to start NIBP determination
 */
-(void) dinamapDidBeginDataCollection:(id) sender;

/**
 @function dinamapDidCancelDataCollection:
 @abstract Sent to delegate after the Dinamap BP monitor is sent the message to cancel NIBP determination, if and only if a determination is currently taking place
 */
-(void) dinamapDidCancelDataCollection:(id) sender;

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
