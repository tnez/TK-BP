//
//  TKSubjects.h
//  BP
//
//  Created by Travis Nesland on 8/10/10.
//  Copyright 2010 University of Kentucky. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define TK_SUBJECTS_DEFAULT_FILE [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"subjects.plist"]

@interface TKSubjects : NSObject {
	NSMutableArray *subjects;
}
@property (retain) NSMutableArray *subjects;
-(void) add;
-(void) clear;
-(void) clearDataForKey:(NSString *) key;
-(NSInteger) count;
-(NSMutableDictionary *) objectAtIndex:(NSInteger) index;
-(void) readSubjects;
-(void) removeSubjects:(NSIndexSet *) index;
-(void) sortUsingDescriptors:(NSArray *) newDescriptors;
-(void) writeSubjects;

#pragma mark Table View Data Source Protocol
-(NSInteger) numberOfRowsInTableView:(NSTableView *) table;
-(void) tableView:(NSTableView *) table sortDescriptorsDidChange:(NSArray *) oldDescriptors;
-(void) tableView:(NSTableView *) table setObjectValue:(id) newObject forTableColumn:(NSTableColumn *) column row:(NSInteger) row;
-(id) tableView:(NSTableView *) table objectValueForTableColumn:(NSTableColumn *) column row:(NSInteger) row;

@end

#pragma mark Notifications
extern NSString * const TKSubjectsDidChangeNotification;