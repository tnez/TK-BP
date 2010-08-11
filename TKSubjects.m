//
//  TKSubjects.m
//  BP
//
//  Created by Travis Nesland on 8/10/10.
//  Copyright 2010 University of Kentucky. All rights reserved.
//

#import "TKSubjects.h"


@implementation TKSubjects

@synthesize subjects;

-(void) dealloc {
	[self writeSubjects];
	[subjects release];
	[super dealloc];
}

-(id) init {
	if(self=[super init]) {
		[self readSubjects];
		return self;
	} else {
		return nil;
	}
}

-(void) add {
	[subjects addObject:[NSMutableDictionary dictionaryWithObject:@"New Subject" forKey:@"name"]];
}

-(NSInteger) count {
	return [subjects count];
}

-(NSMutableDictionary *) objectAtIndex:(NSInteger) index {
	return [subjects objectAtIndex:index];
}

-(void) removeObjectAtIndex:(NSInteger) index {
	[subjects removeObjectAtIndex:index];
}

-(void) readSubjects {
	subjects = [[NSMutableArray arrayWithContentsOfFile:TK_SUBJECTS_DEFAULT_FILE] retain];
}

-(void) writeSubjects {
	[subjects writeToFile:TK_SUBJECTS_DEFAULT_FILE atomically:YES];
	[subjects release];
}

@end
