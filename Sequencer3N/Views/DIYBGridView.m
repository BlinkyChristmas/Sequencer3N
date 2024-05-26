//
//  DIYBGridView.m
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBGridView.h"
#import "DIYBPrefData.h"
#import "DIYBGrid.h"
#import "DIYBTimeEntry.h"
#import "DIYBWindowController.h"
#import "DIYBScratchView.h"
#import "DIYBTimeEntryController.h"
#import "DIYBWindowController.h"

@implementation DIYBGridView
CGFloat temp_currentTime = 0.0 ;

//==========================================================================================================
- (void)dealloc
{
    [self unbind:@"selectedColor"];
}
//==========================================================================================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _background=[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        // Initialization code here.
        [self bind:@"selectedColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"selectionColor" options:nil];
        _dash[0]=12.0;
        _dash[1]=24.0;
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
        [self buildPaths];
        _scratchView=[[DIYBScratchView alloc] initWithFrame:frame];
        //[_scratchView setNextResponder:self];
        [self addSubview:_scratchView];
        [self setWantsLayer:YES];

    }
    return self;
}

//==========================================================================================================
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [_background setFill];
    NSRectFill(self.bounds);
    [self drawGrids:dirtyRect];
    [self drawSelected];
    
    // Drawing code here.
}
//============================================================================
- (void)buildPaths
{
    NSBezierPath * path=[NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(0.0, 0.0)];
    [path lineToPoint:NSMakePoint(0.0, self.bounds.size.height)];
    _ref1Path=path;
    _ref2Path=[NSBezierPath bezierPath];
    [_ref2Path appendBezierPath:path];
    _activePath=[NSBezierPath bezierPath];
    [_activePath appendBezierPath:path];
    
    [_ref1Path setLineWidth:2.0];
    [_ref2Path setLineWidth:2.0];
    [_activePath setLineWidth:2.0];
    
    [_ref1Path setLineDash:_dash count:2 phase:0.0];
    [_ref2Path setLineDash:_dash count:2 phase:12.0];
    [_activePath setLineDash:_dash count:2 phase:24.0];
    
    _pathNow =[NSBezierPath bezierPath];
    [_pathNow moveToPoint:NSMakePoint(0.0, 0.0)];
    [_pathNow lineToPoint:NSMakePoint(0.0, self.bounds.size.height)];
    
}
//==========================================
- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [_scratchView setFrame:frameRect];
    [self buildPaths];
    [self setNeedsDisplay:YES];
}
//==========================================
- (void)setFrameSize:(NSSize)size
{
    [super setFrameSize:size];
    [_scratchView setFrameSize:size];
    [self buildPaths];
    [self setNeedsDisplay:YES];
}
//==========================================================================
- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [super viewWillMoveToWindow:newWindow];
    if (newWindow)
    {
        [self bind:@"dotsPerSecond" toObject:newWindow.windowController withKeyPath:@"dotsPerSecond" options:nil];
        [self bind:@"ref1Grid" toObject:newWindow.windowController withKeyPath:@"ref1Grid" options:nil];
        [self bind:@"ref2Grid" toObject:newWindow.windowController withKeyPath:@"ref2Grid" options:nil];
        [self bind:@"activeGrid" toObject:newWindow.windowController withKeyPath:@"activeGrid" options:nil];
    }
    else
    {
        [self unbind:@"dotsPerSecond"];
        [self unbind:@"ref1Grid"];
        [self unbind:@"ref2Grid"];
        [self unbind:@"activeGrid"];
    }
}
//==========================================================================
- (void)drawGrids:(NSRect)rect
{
    NSInteger startMilli=(rect.origin.x/self.dotsPerSecond)*10000;
    startMilli=startMilli/10;
    NSInteger endMilli=((rect.origin.x+rect.size.width)/self.dotsPerSecond)*10000;
    endMilli=endMilli/10;
    
    NSPredicate * predicate=[NSPredicate predicateWithFormat:@"milli>=%ld AND milli<=%ld",startMilli,endMilli];
    if (self.ref1Grid)
    {
        [[self.ref1Grid drawColor] setStroke];
        [self drawGrid:self.ref1Grid predicate:predicate refPath:_ref1Path];
    }
    if (self.ref2Grid)
    {
        [[self.ref2Grid drawColor] setStroke];
        [self drawGrid:self.ref2Grid predicate:predicate refPath:_ref2Path];
    }
    if (self.activeGrid)
    {
        [[self.activeGrid drawColor] setStroke];
        [self drawGrid:self.activeGrid predicate:predicate refPath:_activePath];
    }
}
//===========================================================================
- (void)drawGrid:(DIYBGrid*)grid predicate:(NSPredicate*)predicate refPath:(NSBezierPath*)refPath
{
    NSArray * array=[[grid.entries filteredSetUsingPredicate:predicate] allObjects];
    CGFloat dash[2];
    NSInteger pattern;
    CGFloat phase;
    [refPath getLineDash:dash count:&pattern phase:&phase];
    CGFloat width;
    width=[refPath lineWidth];
    for (DIYBTimeEntry* entry in array)
    {
        if (entry!=_selectedEntry)
        {
            NSBezierPath* path=[NSBezierPath bezierPath] ;
            [path appendBezierPath:refPath ];
            
            CGFloat x= (entry.milli/1000.0)*self.dotsPerSecond  ;
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy: x yBy: 0];
            [path transformUsingAffineTransform:transform];
            [path setLineDash:dash count:pattern phase:phase];
            [path setLineWidth:width];
            [path stroke];
        }
    }
    
}
//=======================================================
- (void)drawSelected
{
    if (_selectedEntry)
    {
        
        NSBezierPath* path=[NSBezierPath bezierPath];
        [path appendBezierPath:_pathNow];
        [path setLineWidth:2.0];
        CGFloat x= (_copiedEntry.milli/1000.0)*self.dotsPerSecond;
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy: x yBy: 0];
        [path transformUsingAffineTransform:transform];
        [_selectedColor setStroke];
        [path stroke];
    }
}

//=====================================================================
- (void)resetToolTips
{
    [self removeAllToolTips];
    for (DIYBTimeEntry* entry in self.activeGrid.entries)
    {
        CGFloat x= (entry.milli/1000.0)*self.dotsPerSecond;
        
        [self addToolTipRect:NSMakeRect(x, 0, 1.5, self.bounds.size.height) owner:entry userData:nil];
    }
}
//=====================================================================
- (void)setActiveGrid:(DIYBGrid *)activeGrid
{
    _activeGrid=activeGrid;
    [self resetToolTips];
}
//=====================================================================
- (void)setSelectedColor:(NSColor *)selectedColor
{
    _selectedColor=selectedColor;
    [self setNeedsDisplay:YES];
}

//=======================================================
- (BOOL)resignFirstResponder
{
    if (_copiedEntry)
    {
        _copiedEntry=nil;
    }
    _selectedEntry=nil;
    [self setNeedsDisplay:YES];
    return YES;
}
//==========================================================
- (DIYBTimeEntry*)entryForMilli:(NSInteger)milli
{
    DIYBTimeEntry* entry=nil;
    if (_activeGrid)
    {
        NSPredicate* predicate=[NSPredicate predicateWithFormat:@"milli>=%ld AND milli<=%ld",milli-50,milli+50];
        NSSet* set=[_activeGrid.entries filteredSetUsingPredicate:predicate];
        if (set)
        {
            entry=[set anyObject];
        }
        
    }
    return entry;
}
//=======================================================================================================
- (NSMenu*)menuForEvent:(NSEvent *)event
{
    NSMenu* menu=nil;
    if (_isActive)
    {
        /*
        NSPoint point=[self convertPoint:[event locationInWindow] fromView:nil];
        NSInteger milli=(point.x/self.dotsPerSecond)*10000;
        milli=milli/10;
         */
        NSPoint point=[self convertPoint:[event locationInWindow] fromView:nil];
        NSInteger milli=(point.x/self.dotsPerSecond)*10000;
        temp_currentTime = milli/10000.0 ;
        
        menu=[[NSMenu alloc] initWithTitle:@"Popup"];
        NSMenuItem* item=nil;
        [[self window] makeFirstResponder:self];
        item=[[NSMenuItem alloc] initWithTitle:@"Create time entry" action:@selector(createTimeEntry:) keyEquivalent:@""];
        [menu addItem:item];
        if (_selectedEntry)
        {
            item=[[NSMenuItem alloc] initWithTitle:@"Delete time entry" action:@selector(removeTimeEntry:) keyEquivalent:@""];
            [menu addItem:item];
            item=[[NSMenuItem alloc] initWithTitle:@"Edit time entry" action:@selector(editTimeEntry:) keyEquivalent:@""];
            [menu addItem:item];
            
        }
    }
    else
        menu=[super menuForEvent:event];
    return menu;
}

//=======================================================
- (void)mouseDown:(NSEvent *)theEvent
{
    if (_isActive)
    {
        [[self window] makeFirstResponder:self];
        NSPoint point=[self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSInteger milli=(point.x/self.dotsPerSecond)*10000;
        milli=milli/10;
        if ([theEvent modifierFlags]&NSEventModifierFlagCommand )
        {
            // Add an entry
            if (_activeGrid)
            {
                DIYBTimeEntry* entry=[_activeGrid entryForMilli:milli];
                if (!entry)
                {
                    [(DIYBWindowController*) self.window.windowController addTimeEntry:[[DIYBTimeEntry alloc] initWithMilli:milli] grid:_activeGrid];
                    
                }
            }
        }
        else
        {
            [self setSelectedEntry:[self entryForMilli:milli]];
            if (_selectedEntry)
            {
                _clickTime=milli-_selectedEntry.milli;
            }
            else
                self.selectedEntry=nil;
            [self setNeedsDisplay:YES];
            
        }
    }
    else
    {
        [super mouseDown:theEvent];
    }
}
//=======================================================
- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_isActive)
    {
        NSPoint point=[self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSInteger milli=(point.x/self.dotsPerSecond)*10000;
        milli=milli/10;
        [self autoscroll:theEvent];
        
        if (_selectedEntry)
        {
            _copiedEntry.milli=milli-_clickTime;
            [self setNeedsDisplay:YES];
        }
    }
    else
    {
        [super mouseDragged:theEvent];
    }
}
//=======================================================
- (void)mouseUp:(NSEvent *)theEvent
{
    if (_isActive)
    {
        if (_selectedEntry)
        {
            if (_copiedEntry.milli !=_selectedEntry.milli)
            {
                // Add an entry
                if (_activeGrid)
                {
                    DIYBTimeEntry* entry=[_activeGrid entryForMilli:_copiedEntry.milli];
                    if (!entry)
                    {
                        [(DIYBWindowController*) self.window.windowController updateTimeEntry:_selectedEntry grid:_activeGrid time:_copiedEntry.milli];
                    }
                    else
                    {
                        _copiedEntry.milli=_selectedEntry.milli;
                        [self setNeedsDisplay:YES];
                        [self resetToolTips];
                    }
                }
                else
                {
                    _copiedEntry.milli=_selectedEntry.milli;
                    [self setNeedsDisplay:YES];
                    [self resetToolTips];
                   
                }
                
            }
            else
                _copiedEntry.milli=_selectedEntry.milli;
            [self setNeedsDisplay:YES];
            [self resetToolTips];
        }
    }
    else
    {
        [super mouseUp:theEvent];
    }
}

//=======================================================
- (void)setSelectedEntry:(DIYBTimeEntry *)selectedEntry
{
    if (_copiedEntry)
    {
        _copiedEntry=nil;
        
    }
    _selectedEntry=selectedEntry;
    if (selectedEntry)
    {
        _copiedEntry=[selectedEntry mutableCopy];
    }
}
//=================================================================
- (BOOL)acceptsFirstResponder
{
    
    return _isActive;
}
//==================================================================
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return _isActive;
}
//==================================================================
- (BOOL)isOpaque
{
    return NO;
}

//==========================================================================================================
- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    
    [self setNeedsDisplay:YES];
}
//==================================================================
- (void)deleteBackward:(id)sender
{
    [self deleteForward:sender];
}
//==================================================================
- (void)deleteForward:(id)sender
{
    if (_selectedEntry)
    {
        [(DIYBWindowController*) self.window.windowController removeTimeEntry:_selectedEntry grid:_activeGrid];
        
    }
}
//=======================================================================
- (void)keyDown:(NSEvent *)theEvent
{
            [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

//==================================================================
- (IBAction)createTimeEntry:(id)sender
{
    _timeController=[[DIYBTimeEntryController alloc] initWithWindowNibName:@"DIYBTimeEntryController"];
    _timeController.time = temp_currentTime ;
    [[self window] beginSheet:_timeController.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode==NSModalResponseOK)
        {
            DIYBTimeEntry* entry=[self->_activeGrid entryForMilli:self->_timeController.milli];
            if (!entry)
            {
                [(DIYBWindowController*) self.window.windowController addTimeEntry:[[DIYBTimeEntry alloc] initWithMilli:self->_timeController.milli] grid:self->_activeGrid];
                
            }
            
        }
    }];
    
}
//==================================================================
- (IBAction)removeTimeEntry:(id)sender
{
    [self deleteForward:self];
}
//==================================================================
- (IBAction)editTimeEntry:(id)sender
{
    _timeController=[[DIYBTimeEntryController alloc] initWithWindowNibName:@"DIYBTimeEntryController"];
    if (_selectedEntry)
    {
        _timeController.time=_selectedEntry.time;
    }
    [[self window] beginSheet:_timeController.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode==NSModalResponseOK)
        {
            DIYBTimeEntry* entry=[self->_activeGrid entryForMilli:self->_timeController.milli];
            if (!entry)
            {
               
            }
            else
                [(DIYBWindowController*) self.window.windowController removeTimeEntry:self->_selectedEntry grid:self->_activeGrid ];;
            
            
        }
    }];
}
//==================================================================
- (IBAction)cancelOperation:(id)sender
{
    if (_selectedEntry)
    {
        _copiedEntry=nil;
        _selectedEntry=nil;
        [self setNeedsDisplay:YES];
    }
}

//==================================================================
- (void)setUpdateScratch:(BOOL)value
{
    _scratchView.updateScratch=value;
    if (value)
    {
        [_scratchView setNeedsDisplay:YES];
    }
}
@end
