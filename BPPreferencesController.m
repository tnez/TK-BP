//
//  BPPreferencesController.m
//  BP
//
//  Created by Travis Nesland on 8/4/10.
//  Copyright 2010 University of Kentucky. All rights reserved.
//

#import "BPPreferencesController.h"


@implementation BPPreferencesController
@synthesize dataDirectoryField;
-(IBAction) browseForDataDirectory:(id) sender {
	// configure panel
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setDirectory:[dataDirectoryField stringValue]];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setAllowsMultipleSelection:NO];
	// run panel
	[panel runModal];
	// set data directory value (using key-value-observing compliant methods)
	[[TKPreferences defaultPrefs] setValue:[[panel filenames] objectAtIndex:0] forKey:@"dataDirectory"];
}
@end
