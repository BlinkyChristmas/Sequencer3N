//
//  DIYBEffectView.m
//  Sequencer3
//
//  Created by charles on 9/4/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBEffectView.h"

@implementation DIYBEffectView

//==========================================================================================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    }
    return self;
}

//==========================================================================================================
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect: [self bounds]];
    
    // Drawing code here.
}

//=======================================================================================================
- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [super viewWillMoveToWindow:newWindow];
    if (!newWindow)
    {
        [self unbind:@"dotsPerSecond"];
    }
    
}
//=======================================================================================================
- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if (self.window)
    {
        [self bind:@"dotsPerSecond" toObject:self.window.windowController withKeyPath:@"dotsPerSecond" options:nil];
    }
}
//=======================================================================================================
- (void)setDotsPerSecond:(CGFloat)dotsPerSecond
{
    _dotsPerSecond=dotsPerSecond;
    [self setNeedsDisplay:YES];
}
@end
