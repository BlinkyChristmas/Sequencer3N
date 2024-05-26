//
//  DIYBPrefController.h
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@class DIYBPrefData;
@interface DIYBPrefController : NSWindowController
@property (weak) IBOutlet DIYBPrefData* prefData;

- (IBAction)selectURL:(id)sender;
@end
