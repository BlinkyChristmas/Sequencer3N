//
//  DIYBScratchView.m
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBScratchView.h"
#import "DIYBScratchEntry.h"
#import "DIYBPrefData.h"
#import "DIYBWindowController.h"
#import "DIYBGridView.h"
#import "DIYBTimeNowView.h"
@implementation DIYBScratchView
//=====================================================================
- (void)dealloc
{
    [self unbind:@"timeNowColor"];
    [self unbind:@"scratchColor"];
}
//=====================================================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _clearColor=[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self setWantsLayer:YES];
        [self buildPaths];
        [self bind:@"timeNowColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"timeNowColor" options:nil];
        [self bind:@"scratchColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"scratchColor" options:nil];
        _scratchSet=[NSMutableSet setWithCapacity:200];
        _timeView=[[DIYBTimeNowView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 2.0, frame.size.height)];
        [self addSubview:_timeView];
    }
    return self;
}
//=====================================================================
- (void)setScratchColor:(NSColor *)scratchColor
{
    _scratchColor=scratchColor;
    [self setNeedsDisplay:YES];
}
//=====================================================================
- (void)setTimeNowColor:(NSColor *)timeNowColor
{
    _timeNowColor=timeNowColor;
    [self setNeedsDisplay:YES];
}
//=====================================================================
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
//    if (_updateScratch)
    {
        [self drawScratchesForRect:dirtyRect];
    }
//    [self drawTimeNow];
    // Drawing code here.
}
//==========================================================================
- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [super viewWillMoveToWindow:newWindow];
    if (newWindow)
    {
        [self bind:@"dotsPerSecond" toObject:newWindow.windowController withKeyPath:@"dotsPerSecond" options:nil];
        
        [self bind:@"timeNow" toObject:[(DIYBWindowController*)newWindow.windowController mediaPlayer] withKeyPath:@"currentTime" options:nil       ];
    }
    else
    {
        [self unbind:@"dotsPerSecond"];
        [self unbind:@"timeNow"];
    }
}
//=======================================================================
- (void)keyDown:(NSEvent *)theEvent
{
    if ([(DIYBGridView*)self.superview isActive])
    {
        if ([theEvent keyCode]==49)
        {
            [self spaceBar];
        }
        else
            [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
            //[super keyDown:theEvent];
    }
    else
        [super keyDown:theEvent];
}
//=======================================================================
- (NSInteger)timeMilli;
{
    NSInteger milli=[self timeNow]*10000;
    return milli/10;
}
//=====================================================================
- (void)resetToolTips
{
    [self removeAllToolTips];
    for (DIYBScratchEntry* entry in _scratchSet)
    {
        CGFloat x= (entry.milli/1000.0)*self.dotsPerSecond;
        
        [self addToolTipRect:NSMakeRect(x, 0, 1.5, self.bounds.size.height) owner:entry userData:nil];
    }
}
//=======================================================================
- (void)setTimeNow:(CGFloat)timeNow
{
    CGFloat x= ([self timeMilli]/1000.0)*self.dotsPerSecond;
//    NSRect cleanRect=NSMakeRect(x, 0.0, 1.5, self.bounds.size.height);
    
//    [self setNeedsDisplayInRect:cleanRect];
    _timeNow=timeNow;
    x= ([self timeMilli]/1000.0)*self.dotsPerSecond;
//    cleanRect=NSMakeRect(x, 0.0, 1.5, self.bounds.size.height);
//    [self setNeedsDisplayInRect:cleanRect];
    [_timeView setFrameOrigin:NSMakePoint(x, 0.0)];
    
}

//=======================================================================
- (void)drawTimeNow
{
    CGFloat x= ([self timeMilli]/1000.0)*self.dotsPerSecond;
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy: x yBy: 0];
    NSBezierPath* path=[NSBezierPath bezierPath];
    [path appendBezierPath:_path];
    [path setLineWidth:1.5];
    [path transformUsingAffineTransform:transform];
    [_timeNowColor setStroke];
    [path stroke];
}

//=======================================================================
- (void)drawScratchesForRect:(NSRect)dirtyRect
{
    
    NSInteger startMilli= (dirtyRect.origin.x/self.dotsPerSecond)*10000;
    startMilli=startMilli/10;
    NSInteger endMilli=((dirtyRect.origin.x+dirtyRect.size.width)/self.dotsPerSecond)*10000;
    endMilli=endMilli/10;
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"milli>=%ld AND milli<=%ld",startMilli,endMilli];
    NSSet* set=[_scratchSet filteredSetUsingPredicate:predicate];
    [_scratchColor setStroke];
    for (DIYBScratchEntry* entry in [set allObjects])
    {
        [self drawScratch:entry];
    }
}
//=======================================================================
- (void)drawScratch:(DIYBScratchEntry*)entry
{
    CGFloat x= (entry.milli/1000.0)*self.dotsPerSecond;
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy: x yBy: 0];
    NSBezierPath* path=[NSBezierPath bezierPath];
    [path appendBezierPath:_path];
    [path setLineWidth:1.5];
    [path transformUsingAffineTransform:transform];
    [path stroke];
    
}
//=====================================================================
- (void)spaceBar
{
    DIYBScratchEntry* entry=[[DIYBScratchEntry alloc] initWithTime:self.timeNow];
    [_scratchSet addObject:entry];
    if (_updateScratch)
    {
        CGFloat x= ([entry milli]/1000.0)*self.dotsPerSecond;
        NSRect rect=NSMakeRect(x-1.0, 0, 3.0, self.bounds.size.height);
        
        [self setNeedsDisplayInRect:rect];
        [self resetToolTips];
    }
    
}
//==========================================
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self buildPaths];
    [self setNeedsDisplay:YES];
}
//==========================================
- (void)setFrameSize:(NSSize)size
{
    [super setFrameSize:size];
    [self buildPaths];
    [self setNeedsDisplay:YES];
}
//==========================================
- (void)buildPaths
{
    _path=[NSBezierPath bezierPath];
    [_path moveToPoint:NSMakePoint(0.0, 0.0)];
    [_path lineToPoint:NSMakePoint(0.0, self.bounds.size.height)];
}

//==========================================
- (void)clearScratch
{
    [_scratchSet removeAllObjects];
}
//==========================================
- (void)deleteBackward:(id)sender
{
    [self.superview deleteBackward:self];
}
//==========================================
- (void)deleteForward:(id)sender
{
    [self.superview deleteForward:self];
}
@end
