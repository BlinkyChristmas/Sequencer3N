//
//  DIYBRemoveSeqItemDialog.h
//  Sequencer3
//
//  Created by charles on 9/16/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBRemoveSeqItemDialog : NSWindowController
@property (copy) NSString* selectedSeq;
@property (weak) NSArray* items;

- (IBAction)cancelButton:(id)sender;
- (IBAction)createButton:(id)sender;
@end
