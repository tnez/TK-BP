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
#import <TKUtility/TKUtility.h>
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
 Environment
 */
#define BP_DATA_FILE_NAME [[self datafile] stringByAppendingString:@".tsv"]
/**
 Preference Keys
 */
extern NSString * const TKBPDeviceNameKey;
extern NSString * const TKBPPollingFrequencyKey;
extern NSString * const TKBPReadingMinimumLengthKey;
/**
 Error Codes
 */
#define ERRORS [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TKBPController_Errors" ofType:@"plist"]]


@interface TKBPController : NSObject {
	@private
	SEL currentAction;					// action to be performed when we read data from serial port
	NSString *dataDirectory;			// should be pulled from preferences but this allows flexibility
	id delegate;						// should be whatever object will be handling data
	BOOL determinationIsInProgress;		// 
	NSString *determinationResponse;	//
	NSString *deviceName;				// full path to port i.e. /dev/cu.usbserial-A600b3gB
	NSString *diastolic;				// resolved diastolic reading
	NSString *heartRate;				// resolved heartRate reading
	NSString *heartRateReading;			// This value represents the entire heart rate string
										// returned from the machine
	NSString *map;						// resolved mean arterial pressure
	NSString *newNIBPReading;			// This value is used internally and represents the
										// value taken after a determination is started, new
										// and old NIBP readings will be compared to determine
										// when the new reading is valid
	NSString *oldNIBPReading;			// This reading is used internally and represents the
										// value taken right before starting a new determination
    NSNumber *pollingFrequency;         // frequency in seconds with which to poll for valid reading
	AMSerialPort *port;					// Our Dinamap BP as a serial port
    NSNumber *readingMinimumLength;     // used to decide what the minimum length is to begin evaluating
                                        // a reading
	BOOL shouldBreak;					// used to terminate polling loop
	NSString *study;					// study id for current reading
	NSString *subject;					// subject id for current reading
	NSString *systolic;					// resolved systolic reading
	NSString *targetString;				//
	struct timespec myTime;				// value used in loops to wait for events	
}

@property (retain) NSString *dataDirectory;                     // path to data directory
@property (assign) id delegate;                                 //
@property (readonly) BOOL determinationIsInProgress;            //
@property (nonatomic, retain) NSString *deviceName;             // full path to port i.e. /dev/cu.usbserial-A600b3gB
@property (nonatomic, retain) NSString *diastolic;              // diastolic reading
@property (nonatomic, retain) NSString *heartRate;              // heart rate reading
@property (nonatomic, retain) NSString *map;                    // map reading
@property (nonatomic, retain) NSNumber *pollingFrequency;       // seconds to wait between polling for valid reading
@property (nonatomic, retain) NSNumber *readingMinimumLength;   // min to even evaluate for validity of reading
@property (nonatomic, retain) NSString *study;                  // study for current reading
@property (nonatomic, retain) NSString *subject;                // subject for current reading
@property (nonatomic, retain) NSString *systolic;               // systolic reading	

-(void) startDetermination;
-(void) cancelDetermination;
-(NSString *) diastolic;
-(BOOL) hasDeterminationInProgress;
-(NSString *) heartRate;
-(NSString *) map;
-(NSString *) systolic;

#pragma mark Error Codes

typedef enum TKBPControllerErrorCode {
    TKBPInvalidDataDirectoryError   = 1000,     // specified data directory is not valid
    TKBPCouldNotEstablishPortError  = 1010,     // port could not be opened
    TKBPNullResultsError            = 1015,     // bp machine is not responding (null results)
    TKBPFailedDeterminationError    = 1020      // determination has failed
} TKBPControllerErrorCode;

@end

@interface TKBPController (TKDinamapBPControllerPrivate)
-(void) awakeFromNib;
-(void) commitResults;
-(NSString *) datafile;
-(NSString *) heartRateReading;
-(void) initPort;
-(void) loadSubjects;
-(NSString *) newNIBPReading;
-(BOOL) NIBPReadingIsFinished;
-(BOOL) NIBPReadingIsValid;
-(NSString *) oldNIBPReading;
-(void) performSimpleLogging;
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
-(BOOL) shouldContinuePolling;
-(void) startPollingForValidReading;
-(NSString *) time;
-(NSInteger) timeCounterForReading:(NSString *) reading;
-(void) throwError:(TKBPControllerErrorCode) errorCode;
-(void) waitForResult;

@end

@interface NSObject (TKDinamapBPControllerDelegate)
-(void) error:(NSError *) error didOccurrInComponent:(id) sender withDescription:(NSString *) desc;
-(void) event:(NSDictionary *) eventInfo didOccurrInComponent:(id) sender;
@end

#pragma mark Notifcations
extern NSString * const TKBPControllerDidBeginDataCollectionNotification;
extern NSString * const TKBPControllerDidCancelDataCollectionNotification;
extern NSString * const TKBPControllerDidFinishDataCollectionNotification;
extern NSString * const TKBPControllerWillThrowErrorNotification;
