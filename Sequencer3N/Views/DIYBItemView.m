//
//  DIYBItemView.m
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBItemView.h"
#import "DIYBPrefData.h"
@implementation DIYBItemView

//==========================================================================================================
- (void)dealloc
{
    [self unbind:@"separatorColor"];
}
//==========================================================================================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self bind:@"separatorColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"separatorColor" options:nil];
        _prefData=[DIYBPrefData sharedInstance];
        [self setAutoresizingMask:NSViewNotSizable];
        [self setFocusRingType:NSFocusRingTypeExterior];

    }
    return self;
}

//==========================================================================================================
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self drawSeparator];
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
//========================================================================================================
- (void)setSeparatorColor:(NSColor *)separatorColor
{
    _separatorColor=separatorColor;
    [self setNeedsDisplay:YES];
}
//========================================================================================================
- (void)drawSeparator
{
    [_separatorColor setStroke];

    NSRect rect=[self bounds];
    NSBezierPath* path=[NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(0.0, 0.0)];
    [path lineToPoint:NSMakePoint(rect.size.width, 0.0)];
    [path setLineWidth:1.0];
    [path stroke];
    path=[NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(0.0, rect.size.height-1.0)];
    [path lineToPoint:NSMakePoint(rect.size.width, rect.size.height-1.0)];
    [path setLineWidth:1.0];
    [path stroke];
    
    
    
}
//========================================================================================================
- (BOOL)isFlipped
{
    return NO;
}
/*
//========================================================================================================
- (void)drawFocusRingMask {
    NSRectFill([self bounds]);
}

//========================================================================================================
- (NSRect)focusRingMaskBounds {
    return [self bounds];
}

- (BOOL)acceptsFirstResponder
{
    return YES  ;
}
 */
@end
