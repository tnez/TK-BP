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
-(NSInteger) count;
-(NSMutableDictionary *) objectAtIndex:(NSInteger) index;
-(void) readSubjects;
-(void) removeObjectAtIndex:(NSInteger) index;
-(void) writeSubjects;
@end
