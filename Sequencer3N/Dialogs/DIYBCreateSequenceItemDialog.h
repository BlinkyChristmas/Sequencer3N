//
//  DIYBCreateSequenceItemDialog.h
//  Sequencer3
//
//  Created by charles on 9/16/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBCreateSequenceItemDialog : NSWindowController
@property (copy) NSString* seqName;
@property (copy) NSString* source;
@property (weak) NSArray* lightGroups;

- (IBAction)cancelButton:(id)sender;
- (IBAction)createButton:(id)sender;
@end
