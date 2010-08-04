//
//  BPPreferencesController.h
//  BP
//
//  Created by Travis Nesland on 8/4/10.
//  Copyright 2010 University of Kentucky. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>

@interface BPPreferencesController : NSObject {
	IBOutlet NSTextField *dataDirectoryField;
}
@property (assign) IBOutlet NSTextField *dataDirectoryField;
-(IBAction) browseForDataDirectory:(id) sender;
@end
