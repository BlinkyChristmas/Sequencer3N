//
//  DIYBItemEffectView.m
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBItemEffectView.h"
#import "DIYBItemController.h"
#import "DIYBSequenceItem.h"
#import "DIYBEffectItem.h"
#import "DIYBWindowController.h"
#import "DIYBDocument.h"
#import "DIYBGrid.h"
#import "DIYBPrefData.h"
#import "DIYBTimeEntry.h"
#import "DIYBEffectDialog.h"
#import "PixelEffect.h"

static void* FontSizeContext=&FontSizeContext;



@interface DIYBItemEffectView ()
@property (strong) DIYBEffectDialog* effectDialog;

@end
@implementation DIYBItemEffectView

//=======================================================================================================
- (void)dealloc
{
    [self unbind:@"effectHeight"];
    [self unbind:@"fontColor"];
    [self unbind:@"selectionColor"];
    [self unbind:@"effectColor"];
    //[self unbind:@"fontSize"];
    [[DIYBPrefData sharedInstance] removeObserver:self forKeyPath:@"patternFontSize"];
    
}
//=======================================================================================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setAutoresizingMask:NSViewWidthSizable];
        _style=[[NSMutableParagraphStyle alloc] init];
        [_style setLineBreakMode:NSLineBreakByTruncatingHead];

        [self bind:@"effectHeight" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"effectHeight" options:nil];
        [self bind:@"fontColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"patternNameColor" options:nil];
        [self bind:@"selectionColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"selectionColor" options:nil];
        [self bind:@"effectColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"lightEffectColor" options:nil];
        //[self bind:@"fontSize" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"patternFontSize" options:nil]
        [[DIYBPrefData sharedInstance] addObserver:self forKeyPath:@"patternFontSize" options:NSKeyValueObservingOptionNew context:FontSizeContext];
        self.fontSize=[[DIYBPrefData sharedInstance] patternFontSize];


    }
    return self;
}
//=======================================================================================================
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context==FontSizeContext)
    {
        self.fontSize=[[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
//=======================================================================================================
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSArray* array=[self effectsInDrawOrder];
    [self drawEffects:array useLabel:NO];
    [self drawEffects:array useLabel:YES];
}
//=====================================================================================================
- (void)setEffectHeight:(CGFloat)effectHeight
{
    _effectHeight=effectHeight;

}
//=====================================================================================================
- (void)setEffectColor:(NSColor *)effectColor
{
    _effectColor=effectColor ;
    [self setNeedsDisplay:YES];
    
}
//=====================================================================================================
- (void)setFontColor:(NSColor *)fontColor
{
    _fontColor=fontColor;
    _font=[NSFont fontWithName:@"Arial" size:_fontSize];
    _dictionary=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_font,_fontColor,_style, nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName,nil]];
    [self setNeedsDisplay:YES];
    
}
//=====================================================================================================
- (void)setSelectionColor:(NSColor *)selectionColor
{
    _selectionColor=selectionColor;
    [self setNeedsDisplay:YES];
}
//=====================================================================================================
- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize=fontSize;
    _font=[NSFont fontWithName:@"Arial" size:fontSize];
    _dictionary=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_font,_fontColor,_style, nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,NSParagraphStyleAttributeName,nil]];
    [self setNeedsDisplay:YES];
 
}
//=======================================================================================================
- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [super viewWillMoveToWindow:newWindow];
    if (newWindow)
    {
    }
    else
    {
    }
}
//======================================================================================================
- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if (self.window)
    {
        [self resetToolTips];
    }
}
//=======================================================================================================
- (NSArray*)effectsInDrawOrder
{
    return [[[[(DIYBItemController*)self.controller item] effects] allObjects] sortedArrayUsingSelector:@selector(displayOrder:)];
 
}
//=======================================================================================================
- (NSArray*)effectsInApplyOrder
{
    return [[[[(DIYBItemController*)self.controller item] effects] allObjects] sortedArrayUsingSelector:@selector(applyOrder:)];
    
}

//=======================================================================================================
- (void)drawEffects:(NSArray*)array useLabel:(BOOL)useLabel
{
    BOOL expanded=[self.controller isExpanded];
    NSInteger layer=0;
    for (DIYBEffectItem* effect in array)
    {
        if (expanded)
        {
            layer=effect.layer;
        }
        if (!useLabel)
        {
            [self drawEffect:effect layer:layer];
        }
        else
            [self drawLabel:effect layer:layer];
    }
}
//=======================================================================================================
- (void)drawEffect:(DIYBEffectItem*)effect layer:(NSInteger)layer
{
    NSColor* color=[NSColor blackColor];
    if (effect)
    {
        if (effect.isPattern)
        {
            if (effect.isSelected)
            {
                color=_selectionColor;
            }
            else
            {
                DIYBGrid* grid=[[[(DIYBWindowController*)self.window.windowController seqFile] grids] objectForKey:effect.grid];
                if (grid)
                {
                    color = grid.drawColor;
                    
                }
            }
            NSRect rect=[effect drawRect:self.dotsPerSecond height:_effectHeight layer:layer];
            [color setFill];
            
            NSRectFill(rect);

        }
        else
        {
            if (effect.isSelected)
            {
                color=_selectionColor;
            }
            else
            {
                color=_effectColor;
            }
            NSRect rect=[effect drawRect:self.dotsPerSecond height:_effectHeight layer:layer];
            [color setFill];
            
            NSRectFill(rect);
            
        }
    }
 
}

//=======================================================================================================
- (void)drawLabel:(DIYBEffectItem*)effect layer:(NSInteger)layer
{
    if (effect)
    {
        NSRect rect=[effect drawRect:self.dotsPerSecond height:_effectHeight layer:layer];
        //[effect.pattern_light drawWithRect:rect options:NSStringDrawingTruncatesLastVisibleLine attributes:_dictionary];
        //[effect.pattern_light drawAtPoint:rect.origin withAttributes:_dictionary];
        [effect.pattern_light drawInRect:rect withAttributes:_dictionary];
    }
    
}

//=======================================================================================================
- (BOOL)isFlipped
{
    return YES;
}
//=======================================================================================================
- (void)resetToolTips
{
    [self removeAllToolTips];
    BOOL expanded=[self.controller isExpanded];

    NSArray* array=[self effectsInDrawOrder];
    NSInteger layer=0;
    for (DIYBEffectItem* effect in array)
    {
        if (expanded)
        {
            layer=effect.layer;
        }
        else
            layer=0;
        NSRect rect=[effect drawRect:self.dotsPerSecond height:_effectHeight layer:layer];
        [self addToolTipRect:rect owner:effect userData:nil];
    }
}

//=======================================================================================================
- (NSMenu*)menuForEvent:(NSEvent *)event
{
    NSMenu* menu=[[NSMenu alloc] initWithTitle:@"Popup"];
    NSMenuItem* item=nil;

    [[self window] makeFirstResponder:self];
    NSPoint point=[self convertPoint:[event locationInWindow] fromView:nil];
     _clickTime=point.x/self.dotsPerSecond;
    NSArray* array=[self effectsInApplyOrder];
    NSArray* possible=[self effectsForPoint:point effects:array];
    DIYBEffectItem* selectedEffect=[self selectedItem:possible];
    
    item=[[NSMenuItem alloc] initWithTitle:@"Create effect" action:@selector(createEffect:) keyEquivalent:@""];
    [menu addItem:item];
    if (selectedEffect)
    {
        item=[[NSMenuItem alloc] initWithTitle:@"Edit effect" action:@selector(editEffect:) keyEquivalent:@""];
        [menu addItem:item];
        item.representedObject=selectedEffect;

    }
    [menu addItem:[NSMenuItem separatorItem]];
    
    for (DIYBEffectItem* effect in possible)
    {
        item=[[NSMenuItem alloc] initWithTitle:[effect description] action:@selector(selectEffect:) keyEquivalent:@""];
        [item setRepresentedObject:effect];
        if (effect.isSelected)
        {
            item.state=NSControlStateValueOn;
        }
        [menu addItem:item];
    }
    return menu;
}

//=======================================================================================================
- (NSArray*)effectsForPoint:(NSPoint)point effects:(NSArray*)effects
{
    BOOL expanded=[self.controller isExpanded];
    NSInteger layer=0;
    NSMutableArray* array=[NSMutableArray arrayWithCapacity:10];
    for (DIYBEffectItem* effect in effects)
    {
        if (expanded)
        {
            layer=effect.layer;
        }
        else
        {
            layer=0;
        }
        NSRect rect=[effect drawRect:self.dotsPerSecond height:_effectHeight layer:layer];
        if (NSPointInRect(point, rect))
        {
            [array addObject:effect];
        }
    }
    return array;
}

//=======================================================================================================
- (IBAction)selectEffect:(id)sender
{
    [self selectedItem:[self effectsInDrawOrder]].isSelected=NO;
    DIYBEffectItem* effect=[sender representedObject];
    if (effect)
    {
        [effect setIsSelected:YES];
    }
    [self setNeedsDisplay:YES];
}
//=======================================================================================================
- (IBAction)editEffect:(id)sender
{
    DIYBEffectItem* effect=[sender representedObject];
    _effectDialog=[[DIYBEffectDialog alloc] initWithWindowNibName:@"DIYBEffectDialog"];
    _effectDialog.sequenceItem=[(DIYBItemController*)self.controller item];
    _effectDialog.effect=[effect mutableCopy];
    _effectDialog.controller=self.window.windowController;
    [[self window] beginSheet:_effectDialog.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode==NSModalResponseOK){
            
            [(DIYBWindowController*)self.window.windowController updateEffect:effect withEffect:self->_effectDialog.effect view:self];
            
        }
    }];
}
//=======================================================================================================
- (IBAction)createEffect:(id)sender
{
    DIYBEffectItem* effect=[[DIYBEffectItem alloc] init];
    _effectDialog=[[DIYBEffectDialog alloc] initWithWindowNibName:@"DIYBEffectDialog"];
    _effectDialog.sequenceItem=[(DIYBItemController*)self.controller item];
    _effectDialog.controller=self.window.windowController;
    effect.effect=[PatternEffect copy];
    effect.startTime=_clickTime;
    effect.endTime=_clickTime;
    DIYBGrid* grid=[_effectDialog.controller activeGrid];
    if (grid)
    {
        effect.grid=grid.name;
        DIYBTimeEntry* entry=[grid closestMilli:effect.startMilli];
        if (entry)
        {
            effect.startMilli=entry.milli;
            effect.endMilli=effect.startMilli+1;
            entry=[grid entryAfterMilli:effect.endMilli];
            if (entry)
            {
                effect.endMilli=entry.milli;
            }
        }

    }
    [effect resetScratch];
    _effectDialog.effect=[effect mutableCopy];

    [[self window] beginSheet:_effectDialog.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode==NSModalResponseOK){
            
            [(DIYBWindowController*)self.window.windowController addEffect:[self->_effectDialog.effect mutableCopy] item:[(DIYBItemController*)self.controller item] view:self];
            
        }
    }];
   
}
//=======================================================================================================
- (BOOL)acceptsFirstResponder
{
    return YES;
}

//=======================================================================================================
- (DIYBEffectItem*)selectedItem:(NSArray*)effects
{
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"isSelected==%hhd",YES];
    return [effects filteredArrayUsingPredicate:predicate].firstObject;
    
}
//=======================================================================================================
- (void)mouseDown:(NSEvent *)event
{

    [[self window] makeFirstResponder:self];
    NSPoint point=[self convertPoint:[event locationInWindow] fromView:nil];
    _clickTime=(point.x/self.dotsPerSecond);
    NSInteger clickMilli=_clickTime*10000;
    clickMilli=clickMilli/10;
    
    NSArray* allEffects=[self effectsInDrawOrder];
    NSArray* possible=[self effectsForPoint:point effects:allEffects];
    DIYBEffectItem* item=[self selectedItem:allEffects];
    if (item)
    {
        // There is a selected item, is it in our list of possibles
        if (![possible containsObject:item])
        {
            item.isSelected=NO;
            item=possible.lastObject;
            item.isSelected=YES;
        }
    }
    else
    {
        item=possible.lastObject;
        item.isSelected=YES;
    }
    if (item)
    {
        _dragging=[self dragTypeForItem:item milli:clickMilli];
        if (_dragging)
        {
            if (_dragType==1)
            {
                [self setCursor:[NSCursor resizeLeftCursor]];
            }
            else if (_dragType==2)
            {
                [self setCursor:[NSCursor resizeRightCursor]];
            }
            else
            {
                [self setCursor:[NSCursor openHandCursor]];
                
            }
        }
        else
        {
            [self setCursor:nil];
        }

    }
    [self setNeedsDisplay:YES];
}
//=======================================================================================================
- (void)mouseDragged:(NSEvent *)event
{
    [[self window] makeFirstResponder:self];
    NSPoint point=[self convertPoint:[event locationInWindow] fromView:nil];
    NSArray* allEffects=[self effectsInDrawOrder];
//    NSArray* possible=[self effectsForPoint:point effects:allEffects];
    DIYBEffectItem* item=[self selectedItem:allEffects];

    if (_dragging && item)
    {
        NSInteger milli=(point.x/self.dotsPerSecond)*10000;
        milli=milli/10;
        NSInteger offset=milli-_timeOffset;
        [self autoscroll:event];
        if (_dragType==1)
        {
            item.scratchStart =offset;
        }
        else if (_dragType==2)
        {
            item.scratchEnd=offset;
        }
        else
        {
            _timeOffset=milli;
            [item setScratchStart:item.scratchStart +offset];
            [item setScratchEnd:item.scratchEnd +offset];
           
        }
        [self setNeedsDisplay:YES];
    }
   
}
//=======================================================================================================
- (void)mouseUp:(NSEvent *)event
{
    [[self window] makeFirstResponder:self];
//    NSPoint point=[self convertPoint:[event locationInWindow] fromView:nil];
    NSArray* allEffects=[self effectsInDrawOrder];
//    NSArray* possible=[self effectsForPoint:point effects:allEffects];
    DIYBEffectItem* effect=[self selectedItem:allEffects];
    if (_dragging && effect)
    {
        if ([effect isPattern])
        {
            DIYBGrid* grid=[[[(DIYBWindowController*)self.window.windowController seqFile] grids] objectForKey:effect.grid];
            if (grid)
            {
                NSInteger startMilli=effect.scratchStart;
                NSInteger endMilli=effect.scratchEnd;
                DIYBTimeEntry* closestStart=[grid closestMilli:startMilli];
                DIYBTimeEntry* closestEnd=[grid closestMilli:endMilli];
                if (closestEnd && closestStart && (closestEnd.milli>closestStart.milli))
                {
                    startMilli=closestStart.milli;
                    endMilli=closestEnd.milli;
                
                    if ((startMilli<endMilli )  && ((startMilli!=effect.startMilli) || (effect.endMilli!=endMilli)))
                    {
                        effect.scratchEnd=endMilli;
                        effect.scratchStart=startMilli;
                        DIYBEffectItem* temp=[effect mutableCopy];
                        [temp updateFromScratch];
                        [(DIYBWindowController*)self.window.windowController updateEffect:effect withEffect:temp view:self];
                        [self setNeedsDisplay:YES];
                        
                    }
                    else
                    {
                        [effect resetScratch];
                        [self setNeedsDisplay:YES];
                    }
                }
                else
                {
                    [effect resetScratch];
                    [self setNeedsDisplay:YES];
                }
               
            }
            else
            {
                [effect resetScratch];
                [self setNeedsDisplay:YES];
            }
        }
        else
        {
            if (effect.scratchEnd> effect.scratchStart)
            {
                DIYBEffectItem* temp=[effect mutableCopy];
                [temp updateFromScratch];
                [(DIYBWindowController*)self.window.windowController updateEffect:effect withEffect:temp view:self];
            }
            else
            {
                [effect resetScratch];
                [self setNeedsDisplay:YES];
                
            }
        }
        [self setCursor:nil];
    }
    
    
}
//==============================================================================
-(void)resetCursorRects
{
    [super resetCursorRects];
    if (_cursor)
    {
        
        [self addCursorRect:[self bounds] cursor:_cursor];
    }
    
}
//==============================================================================
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}
//=============================================================================
- (void)setCursor:(NSCursor *)cursor
{
    _cursor=cursor;
    [self.window invalidateCursorRectsForView:self];
}
//=======================================================================================================
- (BOOL)resignFirstResponder
{
    NSArray* array=[self effectsInDrawOrder];
    DIYBEffectItem* item=[self selectedItem:array];
    if (item)
    {
        item.isSelected=NO;
        [self setNeedsDisplay:YES];
    }
    return YES;
}

//============================================================================
- (BOOL)dragTypeForItem:(DIYBEffectItem*)data milli:(NSInteger)milli
{
    BOOL rvalue=NO;
    if (((data.startMilli+100) >= milli) && ((data.startMilli-100)<=milli))
    {
        _dragType=1;
        _timeOffset=milli-data.startMilli;
        rvalue=YES;
    }
    else if(((data.endMilli+100) >= milli) && ((data.endMilli-100)<=milli))
    {
        _dragType=2;
        _timeOffset=milli-data.endMilli;
        rvalue=YES;
        
    }
    else if ((data.startMilli<=milli) && (data.endMilli>= milli))
    {
        _timeOffset=milli;
        _dragType=3;
        rvalue=YES;
        
    }
    return rvalue;
}
//=====================================================
- (IBAction)deleteBackward:(id)sender
{
    [self deleteForward:sender];
}


//=====================================================
- (IBAction)deleteForward:(id)sender
{
    NSArray* array=[self effectsInDrawOrder];
    DIYBEffectItem* effect=[self selectedItem:array] ;
    if (effect)
    {
        [(DIYBWindowController*)self.window.windowController removeEffect:effect  item:[(DIYBItemController*)self.controller item] view:self];
        
    }
}

//===================================================
- (IBAction)cancelOperation:(id)sender
{
    NSArray* array=[self effectsInDrawOrder];
    DIYBEffectItem* effect=[self selectedItem:array] ;
    if (effect)
    {
        effect.isSelected=NO;
        [effect resetScratch];
        [self setNeedsDisplay:YES];
    }
    if (_cursor)
    {
        _dragging=NO;
        [self setCursor:nil];
    }
}

//============================================================
- (IBAction)copy:(id)sender
{
    NSArray* array=[self effectsInDrawOrder];
    DIYBEffectItem* effect=[self selectedItem:array];
    
    if (effect)
    {
        //NSMutableData * data=[NSMutableData dataWithCapacity:5];
        //NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
        
        [effect encodeWithCoder:archiver];
        [archiver finishEncoding];
        NSPasteboard *pb=[NSPasteboard generalPasteboard];
        [pb clearContents];
        //[pb setData:data forType:@"com.diybllc-sequenceEffect"];
        [pb setData:[archiver encodedData] forType:@"com.diybllc-sequenceEffect"];
       
    }
    
}
//============================================================
- (IBAction)cut:(id)sender
{
    [self copy:sender];
    [self deleteForward:sender];
}

//============================================================
- (IBAction)paste:(id)sender
{
    NSPasteboard *pb= [NSPasteboard generalPasteboard];
    NSString * type=[pb availableTypeFromArray:[NSArray arrayWithObjects:@"com.diybllc-sequenceEffect",nil]];
    DIYBEffectItem* effect=nil;
    if ([type isEqualToString:@"com.diybllc-sequenceEffect"])
    {
        NSData* data=[pb dataForType:type];
        //NSKeyedUnarchiver * coder=[[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSKeyedUnarchiver * coder=[[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        
        effect=[[DIYBEffectItem alloc] initWithCoder:coder];
    }
    if (effect)
    {
        NSInteger clickMilli=_clickTime*10000;
        clickMilli=clickMilli/10;
        NSInteger delta=clickMilli-[effect startMilli];
        NSInteger startMilli=[effect startMilli]+delta;
        NSInteger endMilli=[effect endMilli]+ delta;
        [effect setStartMilli:startMilli];
        [effect setEndMilli:endMilli];
        NSError* error=nil;
        if ([effect isPattern])
        {
            DIYBGrid* grid=[[[(DIYBWindowController*)self.window.windowController seqFile] grids] objectForKey:effect.grid];
            if (grid)
            {
                DIYBTimeEntry* startEntry=[grid closestMilli:effect.startMilli];
                DIYBTimeEntry* endEntry=[grid closestMilli:effect.endMilli];
                if (startEntry && endEntry)
                {
                    
                    if (startEntry.milli<endEntry.milli)
                    {
                        effect.startMilli=startEntry.milli;
                        effect.endMilli=endEntry.milli ;
                    }
                    else
                        error=[NSError errorWithDomain:@"DIYBSequencer" code:40 userInfo:[NSDictionary dictionaryWithObject:@"Can not determine approprate start/end times based on grid" forKey:NSLocalizedDescriptionKey]];
                    
                }
                else
                {
                    error=[NSError errorWithDomain:@"DIYBSequencer" code:40 userInfo:[NSDictionary dictionaryWithObject:@"Can not determine approprate start/end times based on grid" forKey:NSLocalizedDescriptionKey]];
                }
            }
            else
            {
                error=[NSError errorWithDomain:@"DIYBSequencer" code:40 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Can not find grid %@",effect.grid] forKey:NSLocalizedDescriptionKey]];
            }
        }
        if (!error)
        {
            [effect resetScratch];
            [(DIYBWindowController*)self.window.windowController addEffect:effect item:[(DIYBItemController*)self.controller item] view:self];

        }
        else
        {
            [self.window.windowController presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
        }
        
        
    }
}

//==============================================
- (void)keyDown:(NSEvent *)theEvent
{
    NSArray* array=[self effectsInDrawOrder];
    DIYBEffectItem* effect=[self selectedItem:array];
    if (effect)
    {
        if ([theEvent keyCode]==123)
        {
            if ([theEvent modifierFlags] & NSEventModifierFlagCommand)
            {
//                [self shrinkRight:nil];
            }
            else if ([theEvent modifierFlags] &NSEventModifierFlagShift)
            {
//                [self expandRight:nil];
            }
            else
            {
                [self moveLeft:nil];
            }
        }
        else if ([theEvent keyCode]==124)
        {
            if ([theEvent modifierFlags] & NSEventModifierFlagCommand)
            {
//                [self shrinkLeft:nil];
            }
            else if ([theEvent modifierFlags] &NSEventModifierFlagShift)
            {
//                [self expandLeft:nil];
            }
            else
            {
                [self moveRight:nil];
            }
        }
        else
            [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    }
    else
        [super keyDown:theEvent];
}

- (IBAction)moveLeft:(id)sender
{
    
}
- (IBAction)moveRight:(id)sender
{
    
}
@end
