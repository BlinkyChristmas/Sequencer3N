//
//  DIYBTimeNowView.m
//  Sequencer3
//
//  Created by charles on 9/18/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBTimeNowView.h"
#import "DIYBPrefData.h"
@implementation DIYBTimeNowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setAutoresizingMask: NSViewHeightSizable];
        _clearColor=[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        [self bind:@"timeColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"timeNowColor" options:nil];
    }
    return self;
}
- (void)dealloc
{
    [self unbind:@"timeColor"];
}
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [_timeColor setFill];
    NSRectFill( [ self bounds]);

    // Drawing code here.
}

@end
