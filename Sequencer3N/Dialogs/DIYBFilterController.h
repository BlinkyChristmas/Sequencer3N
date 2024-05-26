//
//  DIYBFilterController.h
//  Sequencer3
//
//  Created by charles on 9/15/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBFilterController : NSWindowController
@property (strong) NSArray* items;
- (IBAction)cancelButton:(id)sender;
- (IBAction)createButton:(id)sender;

@end
