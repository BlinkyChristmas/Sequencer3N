//
//  DIYBTimeEntryController.h
//  Sequencer3
//
//  Created by charles on 9/15/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBTimeEntryController : NSWindowController
@property (assign)CGFloat time;
- (IBAction)createButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

- (NSInteger)milli;
@end
