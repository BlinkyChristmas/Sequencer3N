//
//  DIYBCreateGridDialog.h
//  Sequencer3
//
//  Created by charles on 9/8/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBCreateGridDialog : NSWindowController
@property (weak) NSArray* gridNames;
@property (copy) NSString* grid;
@property (strong) NSColor* color;
@end
