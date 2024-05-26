//
//  DIYBRemoveGridDialog.h
//  Sequencer3
//
//  Created by charles on 9/8/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBRemoveGridDialog : NSWindowController
@property (copy) NSString* selectedGrid;
@property (weak) NSArray* gridNames;
@end
