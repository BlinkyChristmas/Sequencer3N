//
//  DIYBBaseView.m
//  Sequencer3
//
//  Created by charles on 9/4/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBBaseView.h"
#import "DIYBPrefData.h"

@implementation DIYBBaseView
//==========================================================================================================
- (void)dealloc
{
    [self unbind:@"backgroundColor"];
}
//==========================================================================================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self bind:@"backgroundColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"backgroundColor" options:nil];
        [self setAutoresizesSubviews:YES];
        [self setWantsLayer:YES];
    }
    return self;
}

//==========================================================================================================
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [_backgroundColor setFill];
    NSRectFill([self bounds]);
}

//==========================================================================================================
- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor=backgroundColor;
    [self setNeedsDisplay:YES];
}
//===========================================================================================================
- (BOOL)isOpaque
{
    return YES;
}
//===========================================================================================================
- (BOOL)isFlipped
{
    return YES;
}
@end
