//
//  DIYBWindowController.m
//  Sequencer3
//
//  Created by charles on 9/1/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBWindowController.h"
#import "NSColor+Serialization.h"
#import "SynchroScrollView.h"
#import "DIYBMediaPlayer.h"
#import "DIYBPrefData.h"
#import "DIYBDocument.h"

#import "../Visual/Accessory/VisualSelectionController.h"

#import "DIYBEffectView.h"
#import "DIYBBaseView.h"
#import "DIYBGridView.h"
#import "DIYBScratchView.h"
#import "DIYBGrid.h"
#import "DIYBTimeEntry.h"
#import "DIYBContainerView.h"

#import "DIYBItemController.h"
#import "DIYBItemView.h"
#import "DIYBItemEffectView.h"
#import "DIYBEffectItem.h"
#import "DIYBSequenceItem.h"
#import "DIYBGridBatch.h"
#import "DIYBCreateGridDialog.h"
#import "DIYBRemoveGridDialog.h"

#import "DIYBImageCache.h"
#import "DIYBURLCache.h"

#import "DIYBVisualController.h"
#import "DIYBExportGroup.h"
#import "DIYBFilterController.h"
#import "DIYBFilterItem.h"
#import "DIYBLightGroup.h"
#import "DIYBLightStorage.h"

#import "DIYBCreateSequenceItemDialog.h"
#import "DIYBRemoveSeqItemDialog.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++ context ++++++++++++++++++++++++++++++++++++++
static void *LoadErrorContext = &LoadErrorContext;
static void *LoadCompleteContext=&LoadCompleteContext;
static void *LoadGridNamesContext=&LoadGridNamesContext;
static void *IsPlayingContext=&IsPlayingContext;
static void *IsExpandedContext=&IsExpandedContext;
static void *SeekTimeContext=&SeekTimeContext;
static void *RowHeightContext=&RowHeightContext;

@interface DIYBWindowController ()
@property (strong) DIYBGridBatch* gridBatch;
- (void)mediaLoadError;
- (void)updateMediaFile:(NSString*)mediaFile;
- (void)updateViews;
- (void)seekToTime:(CGFloat)time;
- (void)addsequenceItemEntries:(NSSet*)seqitems order:(NSInteger)order;
- (NSInteger)nextOrder;
@end

@implementation DIYBWindowController
@synthesize frameRate=_frameRate;
@synthesize duration=_duration;
@synthesize mediaFile=_mediaFile;

//===============================================================================
+ (NSSet *)keyPathsForValuesAffectingDotsPerSecond
{
    return [NSSet setWithObjects:@"scale", nil];
}
//===============================================================================
- (id)init
{
    self=[super initWithWindowNibName:@"DIYBDocument"];
    if (self)
    {
    }
    return self;
}
//===============================================================================
- (void)dealloc
{
    [_mediaPlayer removeObserver:self forKeyPath:@"loadError"];
    [_mediaPlayer removeObserver:self forKeyPath:@"isLoaded"];
    [_mediaPlayer removeObserver:self forKeyPath:@"currentTime"];
    [_mediaPlayer removeObserver:self forKeyPath:@"isPlaying"];
    [_seqFile removeObserver:self forKeyPath:@"gridNames"];
    [[DIYBPrefData sharedInstance] removeObserver:self forKeyPath:@"effectHeight"];
    [self unbind:@"mediaFile"];
    for (DIYBItemController* controller in [_itemControllers allObjects])
    {
        [controller removeObserver:self forKeyPath:@"isExpanded"];
    }
}
//===============================================================================
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        _scale=1.0;
        _prefData=[DIYBPrefData sharedInstance];
        _itemControllers=[NSMutableSet setWithCapacity:100];
        [_prefData addObserver:self forKeyPath:@"effectHeight" options:NSKeyValueObservingOptionNew context:RowHeightContext];
        
        _visualController=[[DIYBVisualController alloc] initWithWindowNibName:@"DIYBVisualController"];
        //[_visuals addObject:_visualController] ;
        _exportGroup=[[DIYBExportGroup alloc] init];
    }
    return self;
}
//===============================================================================
- (void)awakeFromNib
{
    _seqFile=self.document;
    if (_seqFile.frameRate< (CGFloat)0.037)
    {
        _seqFile.frameRate=[_prefData frameRate];
    }
    [self willChangeValueForKey:@"frameRate"];
    _frameRate=_seqFile.frameRate;
    [self didChangeValueForKey:@"frameRate"];
    [_stepTime setIncrement:_frameRate];
    [_mediaPlayer setUpdateRate:_frameRate];
    [_mediaPlayer addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:SeekTimeContext];
    [_mediaPlayer addObserver:self forKeyPath:@"loadError" options:NSKeyValueObservingOptionNew context:LoadErrorContext];
    [_mediaPlayer addObserver:self forKeyPath:@"isLoaded" options:NSKeyValueObservingOptionNew context:LoadCompleteContext];
    [_mediaPlayer addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:IsPlayingContext];
    [_seqFile addObserver:self forKeyPath:@"gridNames" options:NSKeyValueObservingOptionNew context:LoadGridNamesContext];
    _effectView=[[DIYBEffectView alloc] initWithFrame:NSMakeRect(0.0, 0.0, self.duration*self.dotsPerSecond, 0.0)];
    _containerView=[[DIYBContainerView alloc] initWithFrame:NSMakeRect(0.0, 0.0, self.duration*self.dotsPerSecond, 0.0)];
    _displayView=[[DIYBBaseView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 320, 0.0)];
    _gridView=[[DIYBGridView alloc] initWithFrame:NSMakeRect(0.0, 0.0, self.duration*self.dotsPerSecond, 0.0)];
    [_containerView addSubview:_effectView];
    [_containerView addSubview:_gridView];
    [_effectScroll setDocumentView:_containerView];
    [_sequenceItemScroll setDocumentView:_displayView];
    self.gridNames=_seqFile.gridNames;
    if (_seqFile.media)
    {
        self.mediaFile = _seqFile.media ;
        self.mediaFile= [_seqFile.media stringByReplacingOccurrencesOfString:@".mov" withString:@".wav"];
        
        [_mediaPlayer loadURL:[_prefData.mediaDirectory URLByAppendingPathComponent:_mediaFile]];
    }
    [self addsequenceItemEntries:_seqFile.sequenceItems order:0];
    [_visualController setMainController:self];
    NSString* visual=[_seqFile visualization];
    if (visual)
    {
        NSURL* url=[[[DIYBPrefData sharedInstance] visualDirectory] URLByAppendingPathComponent:visual];
        if ([_visualController loadURL:url])
        {
            _visualController.visualFile=visual;
        }
        
    }
}
//==============================================================================
- (void)addsequenceItemEntries:(NSSet*)seqitems order:(NSInteger)order
{
    NSEnumerator *enumerator = [seqitems objectEnumerator];
    DIYBSequenceItem* item;
    
    while ((item = [enumerator nextObject]))
    {
        
        DIYBItemController* controller=[[DIYBItemController alloc] initWithItem:item displayOrder:item.displayOrder];
        order++;
        [_itemControllers addObject:controller];
        [_displayView addSubview:controller.view];
        [_effectView addSubview:controller.effectView];
        [controller addObserver:self forKeyPath:@"isExpanded" options:NSKeyValueObservingOptionNew context:IsExpandedContext];
    }

}
//===============================================================================
- (void)windowDidLoad
{
    [super windowDidLoad];

    [_effectScroll setVSynchronizedScrollView:_sequenceItemScroll];
    [_sequenceItemScroll setVSynchronizedScrollView:_effectScroll];
    [_effectScroll setHasHorizontalRuler:YES];
    
    NSArray* upArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0], nil];
    NSArray* downArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.2], nil];
    [NSRulerView registerUnitWithName:@"time" abbreviation:@"sec" unitToPointsConversionFactor:[self dotsPerSecond] stepUpCycle:upArray stepDownCycle:downArray];

    [[_effectScroll horizontalRulerView] setMeasurementUnits:@"time"];
    [_effectScroll setRulersVisible:YES];
    [self updateViews];
}
//===============================================================================
- (void)updateViews
{
    CGFloat height;
    NSInteger layers=[[DIYBPrefData sharedInstance] maxLayer];
    CGFloat effectHeight=[[DIYBPrefData sharedInstance] effectHeight];
    NSPredicate* visiblepred=[NSPredicate predicateWithFormat:@"isVisible==%hhd",YES];
    //NSPredicate* novisiblepred=[NSPredicate predicateWithFormat:@"isVisible==%hhd",NO];
    NSPredicate* expandpred=[NSPredicate predicateWithFormat:@"isExpanded==%hhd",YES];
    NSPredicate* noexpandpred=[NSPredicate predicateWithFormat:@"isExpanded==%hhd",NO];

    
    NSSet* set=[_itemControllers filteredSetUsingPredicate:visiblepred];

    NSSet* result=[set filteredSetUsingPredicate:expandpred];
    height=result.count*layers*effectHeight;
    result=[set filteredSetUsingPredicate:noexpandpred];
    height=height+result.count*effectHeight;
    [_displayView setFrameSize:NSMakeSize(_displayView.bounds.size.width, height)];
    [_containerView setFrameSize:NSMakeSize(_containerView.bounds.size.width, height)];
    NSSortDescriptor* descriptor=[NSSortDescriptor sortDescriptorWithKey:@"orderDisplay" ascending:YES];
    NSArray* array=[set sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    CGFloat y=0;
    for (DIYBItemController* controller in array)
    {
    
        NSRect frame=controller.view.frame;
        NSRect efframe=controller.effectView.frame;
        frame.origin.y=y;
        efframe.origin.y=y;
        if (controller.isExpanded)
        {
            frame.size.height=layers*effectHeight;
            efframe.size.height=frame.size.height;
            efframe.size.width=_containerView.bounds.size.width;
        }
        else
        {
            frame.size.height=effectHeight;
            efframe.size.height=frame.size.height;
            efframe.size.width=_containerView.bounds.size.width;
        }
        [controller.view setFrame:frame];
        [controller.effectView setFrame:efframe];
        [controller.effectView resetToolTips];
        
        y=y+frame.size.height;
        
    }
    [_gridView setFrameSize:_containerView.bounds.size];
    [_gridView setNeedsDisplay:YES];
    [_displayView setNeedsDisplay:YES];
    [_containerView setNeedsDisplay:YES];
}
//===============================================================================
- (CGFloat)dotsPerSecond
{
    return 170.0*_scale;
}
//===============================================================================
- (void)setScale:(CGFloat)scale
{
    CGFloat oldDots=self.dotsPerSecond;
    _scale=scale;
    NSPoint current=[self.effectScroll.contentView documentVisibleRect].origin;
    NSSize newsize=NSMakeSize(_duration*[self dotsPerSecond], _containerView.bounds.size.height);
    [_containerView setFrameSize:newsize];
    NSArray* upArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0], nil];
    NSArray* downArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.2], nil];
    [NSRulerView registerUnitWithName:@"time" abbreviation:@"sec" unitToPointsConversionFactor:[self dotsPerSecond] stepUpCycle:upArray stepDownCycle:downArray];
    [[_effectScroll horizontalRulerView] setMeasurementUnits:@"time"];
    if (oldDots>0.0)
    {
        CGFloat time=current.x/oldDots;
        current.x=self.dotsPerSecond * time;
        [[self.effectScroll documentView] scrollPoint:current];
        
    }
    [_containerView setNeedsDisplay:YES];
    //[_gridView.scratchView setTimeNow:[_mediaPlayer currentTime]];
    
}
//===============================================================================
- (void)setFrameRate:(CGFloat)frameRate
{
    _frameRate=frameRate;
    [_mediaPlayer setUpdateRate:frameRate];
    [_stepTime setIncrement:frameRate];
}

//===============================================================================
- (IBAction)showVisualSelection:(id)sender
{
    [_accessorySelection setMasterController:self] ;
    [[self window] beginSheet:[_accessorySelection window] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}
//===============================================================================
- (IBAction)showVisuals:(id)sender {
    [_visualController showWindow:nil] ;
    NSArray* visuals = [_accessorySelection entries] ;
    if (visuals) {
        NSInteger count = [visuals count] ;
        for (NSInteger i = 0 ; i<count ; i++ ) {
            [[visuals[i] visualController] showWindow:nil];
        }
    }
}


//===============================================================================
- (IBAction)selectMedia:(id)sender
{
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
//    [panel setAllowedFileTypes:[DIYBMediaPlayer utis]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[DIYBMediaPlayer utis]]];

    [panel setTitle:@"Media select"];
    [panel setPrompt:@"Select"];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:YES];
    [panel setDirectoryURL:[[DIYBPrefData sharedInstance] mediaDirectory]];
    if ([panel runModal]==NSModalResponseOK)
    {
        NSString* file=[[panel URL] lastPathComponent];
        [self updateMediaFile:file];
    }
}

//===============================================================================
- (void)updateMediaFile:(NSString*)mediaFile
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] updateMediaFile:self.seqFile.media];
    if (mediaFile)
    {
        [_mediaPlayer loadURL:[_prefData.mediaDirectory URLByAppendingPathComponent:mediaFile]];
    }
    else
        [self.seqFile setMedia:nil];

}
//===============================================================================
- (void)setDuration:(CGFloat)duration
{
    _duration=duration;
    // Resize our views
    NSSize newsize=NSMakeSize(_duration*[self dotsPerSecond], _containerView.bounds.size.height);
    [_containerView setFrameSize:newsize];
    [_containerView setNeedsDisplay:YES];

}
//===============================================================================
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context==LoadErrorContext)
    {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]==YES)
        {
            [self mediaLoadError];
        }
    }
    else if (context==LoadCompleteContext)
    {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]==YES)
        {
            [self.seqFile setMedia:self.mediaFile];
            self.duration=_mediaPlayer.duration;
        }
    }
    else if (context==LoadGridNamesContext)
    {
        NSArray* array=[change objectForKey:NSKeyValueChangeNewKey];
        self.gridNames=array;
    }
    else if (context==IsExpandedContext)
    {
        [self updateViews];
    }
    else if (context==SeekTimeContext)
    {
        [self seekToTime:[_mediaPlayer currentTime]];
    }
    else if (context==RowHeightContext)
    {
        [self updateViews];
    }
    else if (context==IsPlayingContext)
    {
        BOOL value=[[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        if (value && _gridEnable)
        {
            
            [self.gridView setUpdateScratch:NO];
            [[self window] makeFirstResponder:_gridView.scratchView];
        }
        else if (!value)
        {
            [self.gridView setUpdateScratch:YES];
        }
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
//==================================================================================
- (void)mediaLoadError
{
    NSAlert* alert=[NSAlert alertWithError:_mediaPlayer.error];
    [alert  beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (self->_mediaFile)
        {
            [[self.seqFile undoManager] undo];
            
        }
        
    }];
}

//====================================================================================
- (void)setRef1Name:(NSString *)ref1Name
{
    //_ref1Name=[ref1Name copy];
    _ref1Name  = [ref1Name copy] ;
    
    if (ref1Name)
    {
        self.ref1Grid=[_seqFile.grids objectForKey:ref1Name];
    }
    else
        self.ref1Grid=nil;
    [_gridView setNeedsDisplay:YES];
}
//====================================================================================
- (void)setRef2Name:(NSString *)ref2Name
{
    _ref2Name=[ref2Name copy];
    if (ref2Name)
    {
        self.ref2Grid=[_seqFile.grids objectForKey:ref2Name];
    }
    else
        self.ref2Grid=nil;
    [_gridView setNeedsDisplay:YES];
}
//====================================================================================
- (void)setRef3Name:(NSString *)ref3Name
{
    _ref3Name=[ref3Name copy];
    if (ref3Name)
    {
        self.ref3Grid=[_seqFile.grids objectForKey:ref3Name];
    }
    else
        self.ref3Grid=nil;
    [_gridView setNeedsDisplay:YES];
}
//====================================================================================
- (void)setActiveName:(NSString *)activeName
{
    _activeName=[activeName copy];
    if (activeName)
    {
        self.activeGrid=[_seqFile.grids objectForKey:activeName];
        [self willChangeValueForKey:@"activeColor"];
        _activeColor=[self.activeGrid drawColor];
        [self didChangeValueForKey:@"activeColor"];
    }
    else
    {
        self.activeGrid=nil;
        [self willChangeValueForKey:@"activeColor"];
        _activeColor=[NSColor blackColor];
        [self didChangeValueForKey:@"activeColor"];
        
    }
    [_gridView setNeedsDisplay:YES];
}
//===================================================================================
- (void)setActiveColor:(NSColor *)activeColor
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] setActiveColor:self.activeGrid.drawColor];
    _activeColor=activeColor;
    [self.activeGrid setColor:[activeColor stringValue]];
    [_gridView setNeedsDisplay:YES];
    [self updateEffectViews];
}
//===================================================================================
- (void)setGridEnable:(BOOL)gridEnable
{
    _gridEnable=gridEnable;
    [_gridView setIsActive:gridEnable];
    if (gridEnable)
    {
        [self.window makeFirstResponder:(NSResponder*)_gridView.scratchView ];
    }
    else
        [self.window makeFirstResponder:_containerView];
}
//====================================================================================
- (IBAction)clearGrid:(id)sender
{
    if ([sender tag]==0)
    {
        self.ref1Name=nil;
    }
    else if ( [sender tag]==1)
    {
        self.ref2Name=nil;
    }
    else if ( [sender tag]==2)
    {
        self.ref3Name=nil;
    }
    else
        self.activeGrid=nil;
}

//========================================================================
- (void)updateTimeEntry:(DIYBTimeEntry*)entry grid:(DIYBGrid*)grid time:(NSInteger)milli
{
    NSInteger oldtime=entry.milli;
    
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] updateTimeEntry:entry grid:grid time:oldtime];
    entry.milli=milli;
    if ([_gridView selectedEntry]==entry)
    {
        [[_gridView copiedEntry ] setMilli:milli];
        [_gridView resetToolTips];
    }
    [self.effectView setNeedsDisplay:YES];
    
}
//========================================================================
- (void)removeTimeEntry:(DIYBTimeEntry*)entry grid:(DIYBGrid*)grid
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] addTimeEntry:entry grid:grid];
    if ([_gridView selectedEntry])
    {
        [_gridView setSelectedEntry:nil];
    }
    [grid removeEntry:entry];
    [_gridView setNeedsDisplay:YES];
}
//========================================================================
- (void)addTimeEntry:(DIYBTimeEntry*)entry grid:(DIYBGrid*)grid
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] removeTimeEntry:entry grid:grid];
    [grid addEntry:entry];
    [_gridView setSelectedEntry:entry];
    [_gridView setNeedsDisplay:YES];
    [_gridView resetToolTips];
    
}

//========================================================================
- (void)seekToTime:(CGFloat)time
{
    NSPoint current=[self.effectScroll.contentView documentVisibleRect].origin;
    CGFloat point=(time*self.dotsPerSecond)-(NSWidth([self.effectScroll.contentView bounds])/2.0);
    if (point<0.0)
    {
        point=0.0;
    }
    current.x=point;
    [[self.effectScroll documentView] scrollPoint:current];
    
}
//========================================================================
- (IBAction)resetPlayTime:(id)sender
{
    _mediaPlayer.currentTime=_resetTime;
}

//========================================================================
- (void)updateEffect:(DIYBEffectItem*)effect withEffect:(DIYBEffectItem*)updatedItem view:(id)view
{
    DIYBEffectItem* oldItem=[effect mutableCopy];
    effect.layer=updatedItem.layer;
    effect.startMilli=updatedItem.startMilli;
    effect.endMilli=updatedItem.endMilli;
    effect.effect=updatedItem.effect;
    effect.pattern_light=updatedItem.pattern_light;
    effect.grid=updatedItem.grid;
    effect.scratchEnd=updatedItem.scratchEnd;
    effect.scratchStart=updatedItem.scratchStart;
    effect.isSelected=updatedItem.isSelected;
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] updateEffect:effect withEffect:oldItem view:view];
    [view resetToolTips];
    

    [view setNeedsDisplay:YES];
    
}

//========================================================================
- (void)removeEffect:(DIYBEffectItem*)effect item:(DIYBSequenceItem*)item view:(id)view
{
    [item removeEffect:effect];
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] addEffect:effect item:item view:view];
    [view resetToolTips];
    [view setNeedsDisplay:YES];
   
}
//========================================================================
- (void)addEffect:(DIYBEffectItem*)effect item:(DIYBSequenceItem*)item view:(id)view
{
    [item addEffect:effect];
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] removeEffect:effect item:item view:view];

    [view resetToolTips];
    [view setNeedsDisplay:YES];
}
//========================================================================
- (void)updateEffectViews
{
    NSArray* array=[_effectView subviews];
    for (NSView* view in array) {
        if ([view isKindOfClass:[DIYBItemEffectView class]])
        {
            [(DIYBItemEffectView*)view resetToolTips];

        }
        [view setNeedsDisplay:YES];
    }
}
//========================================================================
- (IBAction)batchTimeEntry:(id)sender
{
    _gridBatch=[[DIYBGridBatch alloc] initWithWindowNibName:@"DIYBGridBatch"];
    _gridBatch.controller=self;
    _gridBatch.gridNames=self.seqFile.gridNames;
    _gridBatch.startTime=0.f;
    _gridBatch.endTime=self.duration;
    _gridBatch.duration=self.duration;
    _gridBatch.sourceGrid=self.activeName;
    
    [self.window beginSheet:_gridBatch.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode==NSModalResponseOK)
        {
            DIYBGrid* sourcegrid=[self->_seqFile.grids objectForKey:self->_gridBatch.sourceGrid];
            DIYBGrid* destgrid=[self->_seqFile.grids objectForKey:self->_gridBatch.destGrid];
            NSInteger startMilli=self->_gridBatch.startTime*10000;
            startMilli=startMilli/10;
            NSInteger endMilli=self->_gridBatch.endTime*10000;
            endMilli=endMilli/10;
            if (endMilli>startMilli)
            {
                NSArray* entries=[sourcegrid entriesBetweenMilli:startMilli endMilli:endMilli];
                if (entries.count>0)
                {
                    CGFloat offset=0.0;
                    CGFloat timeOffset=0.0;
                    entries=[entries sortedArrayUsingSelector:@selector(compare:)];
                    if (self->_gridBatch.useOffset)
                    {
                        timeOffset=[entries.firstObject time];
                        offset=self->_gridBatch.offset;
                    }
                    NSMutableArray* duplicates=[NSMutableArray arrayWithCapacity:entries.count];
                    for (DIYBTimeEntry* entry in entries)
                    {
                        DIYBTimeEntry* dup=[entry mutableCopy];
                        dup.time=dup.time-timeOffset+offset;
                        [duplicates addObject:dup];
                    }
                    NSMutableArray* resultArray=[NSMutableArray arrayWithCapacity:200];
                    if (self->_gridBatch.shouldContract)
                    {
                        NSUInteger index=0;
                        for (index=0; index<duplicates.count; index=index+1+self->_gridBatch.divisor)
                        {
                            if (index < duplicates.count)
                            {
                                DIYBTimeEntry* child=[duplicates objectAtIndex:index];
                                [resultArray addObject:[child mutableCopy]];
                            }
                        }
                    }
                    else
                    {
                        NSUInteger index=0;
                        NSInteger divisor=self->_gridBatch.divisor+1;
                        for (index=0; index<duplicates.count-1; index++)
                        {
                            DIYBTimeEntry* firstentry=[duplicates objectAtIndex:index];
                            DIYBTimeEntry* lastentry=[duplicates objectAtIndex:index+1];
                            NSInteger delta=(lastentry.milli-firstentry.milli)/divisor;
                            NSInteger startMilli=firstentry.milli;
                            //NSInteger endMilli=firstentry.milli;
                            NSInteger count=0;
                            for (count=0; count<divisor; count++)
                            {
                                DIYBTimeEntry* item=[[DIYBTimeEntry alloc] initWithMilli:startMilli+count*delta];
                                [resultArray addObject:item];
                            }
                        }
                        if (duplicates.count>1)
                        {
                            [resultArray addObject:[duplicates.lastObject mutableCopy]];
                        }
                        
                    }
                    // We have the new ones to add
//                    BOOL didAdd=NO;
                    for (DIYBTimeEntry* entry in resultArray)
                    {
                        DIYBTimeEntry* lookup=[destgrid entryForMilli:entry.milli];
                        if (!lookup)
                        {
                            [destgrid addEntry:[entry mutableCopy]];
//                            didAdd=YES;
                        }
                     }
                    [self->_seqFile updateChangeCount:NSChangeDone];
                    [self->_gridView setNeedsDisplay:YES];
                    
                }
            }
            
        }
    }];
}

//========================================================================
- (IBAction)createGridDialog:(id)sender
{
    DIYBCreateGridDialog* dialog=[[DIYBCreateGridDialog alloc] initWithWindowNibName:@"DIYBCreateGridDialog"];
    dialog.gridNames=_seqFile.gridNames;
    [self.window beginSheet:dialog.window completionHandler:^(NSModalResponse returnCode)
    {
        if (returnCode==NSModalResponseOK)
        {
            DIYBGrid* grid=[[DIYBGrid alloc] initWithName:dialog.grid];
            grid.color=[dialog.color stringValue];
            [self addGrid:grid];
        }
        
    }];
}
//========================================================================
- (IBAction)removeGridDialog:(id)sender
{
    DIYBRemoveGridDialog* dialog=[[DIYBRemoveGridDialog alloc] initWithWindowNibName:@"DIYBRemoveGridDialog"];
    dialog.gridNames=_seqFile.gridNames;
    [self.window beginSheet:dialog.window completionHandler:^(NSModalResponse returnCode)
     {
         if (returnCode==NSModalResponseOK)
         {
             DIYBGrid* grid=[self.seqFile.grids objectForKey:dialog.selectedGrid];
             if (grid)
             {
                 [self removeGrid:grid];
             }
         }
         
     }];
}

//========================================================================
- (void)addGrid:(DIYBGrid*)grid
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] removeGrid:grid];
    [self.seqFile addGrid:grid];
    self.gridNames=self.seqFile.gridNames;
}
//========================================================================
- (void)removeGrid:(DIYBGrid*)grid
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] addGrid:grid];
    [self.seqFile removeGrid:grid];
    self.gridNames=self.seqFile.gridNames;
    if ([_activeName isEqualToString:grid.name] )
    {
        self.activeName=nil;
        [_gridView setNeedsDisplay:YES];
    }
    if ([_ref1Name isEqualToString:grid.name])
    {
        self.ref1Name=nil;
        [_gridView setNeedsDisplay:YES];
    }
    if ([_ref2Name isEqualToString:grid.name])
    {
        self.ref2Name=nil;
        [_gridView setNeedsDisplay:YES];
    }
    if ([_ref3Name isEqualToString:grid.name])
    {
        self.ref3Name=nil;
        [_gridView setNeedsDisplay:YES];
    }

}
//========================================================================
- (IBAction)createSequenceDialog:(id)sender
{
    DIYBCreateSequenceItemDialog* dialog=[[DIYBCreateSequenceItemDialog alloc] initWithWindowNibName:@"DIYBCreateSequenceItemDialog"];
    NSArray* array=[[[[DIYBLightStorage sharedInstance] storage] allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    dialog.lightGroups=array;
    [self.window beginSheet:dialog.window completionHandler:^(NSModalResponse returnCode)
     {
         if (returnCode==NSModalResponseOK)
         {
             DIYBSequenceItem* item=[[DIYBSequenceItem alloc] init];
             item.name=dialog.seqName;
             item.source=dialog.source;
             [self addSequenceItem:item];
         }
         
     }];
}
//========================================================================
- (void)removeSequenceItem:(DIYBSequenceItem*)item
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] addSequenceItem:item];
    
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"item==%@",item];
    NSSet* array=[_itemControllers filteredSetUsingPredicate:predicate];
    
    DIYBItemController* controller=array.anyObject;
    if (controller)
    {
        [_itemControllers removeObject:controller];
        [controller.view removeFromSuperview];
        [controller.effectView removeFromSuperview];
        [controller removeObserver:self forKeyPath:@"isExpanded"];
        [_seqFile removeSequenceItem:item];
        [self updateViews];
    }
    
}
//========================================================================
- (void)addSequenceItem:(DIYBSequenceItem*)item
{
    [[[self.seqFile undoManager] prepareWithInvocationTarget:self] removeSequenceItem:item];
    [_seqFile addSequenceItem:item];
    NSInteger order=[self nextOrder];
    DIYBItemController* controller=[[DIYBItemController alloc] initWithItem:item displayOrder:order];
    [_itemControllers addObject:controller];
    [_displayView addSubview:controller.view];
    [_effectView addSubview:controller.effectView];
    [controller addObserver:self forKeyPath:@"isExpanded" options:NSKeyValueObservingOptionNew context:IsExpandedContext];
    [self updateViews];
   
}
//========================================================================
- (IBAction)removeSequenceDialog:(id)sender
{
    DIYBRemoveSeqItemDialog* dialog=[[DIYBRemoveSeqItemDialog alloc] initWithWindowNibName:@"DIYBRemoveSeqItemDialog"];
    NSArray* array=[[[[DIYBLightStorage sharedInstance] storage] allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    dialog.items=array;
    [self.window beginSheet:dialog.window completionHandler:^(NSModalResponse returnCode)
     {
         if (returnCode==NSModalResponseOK)
         {
             NSPredicate* pred= [ NSPredicate predicateWithFormat:@"name==%@",dialog.selectedSeq];
             NSSet* set=[self->_seqFile.sequenceItems filteredSetUsingPredicate:pred];
             DIYBSequenceItem* item=set.anyObject;
             if (item)
             {
                 [self removeSequenceItem:item];
             }
         }
         
     }];
    
}
//========================================================================
- (IBAction)clearScratch:(id)sender
{
    [(DIYBScratchView*)self.gridView.scratchView clearScratch];
    [self.gridView.scratchView setNeedsDisplay:YES];
}
//========================================================================
- (IBAction)setExportFile:(id)sender
{
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setTitle:@"Export mapping file selection"];
//    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"txt"]]];

    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    if ([panel runModal]==NSModalResponseOK)
    {
        if ([_exportGroup loadExportURL:[panel URL]])
        {
            [_exportGroup updateOffsets:_seqFile.sequenceOffsets document:_seqFile];
        }

    }
}
//========================================================================
- (IBAction)exportData:(id)sender
{
    NSSavePanel* panel=[NSSavePanel savePanel];
    [panel setTitle:@"Exported Data File Name"];
#if 1
    //[panel setAllowedFileTypes:[NSArray arrayWithObject:@"light"]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"light"]]];
#else
    //[panel setAllowedFileTypes:[NSArray arrayWithObject:@"diybpb"]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"diybpb"]]];

#endif
    [panel setCanCreateDirectories:YES];
    if ([panel runModal]==NSModalResponseOK)
    {
        NSData * data=[_exportGroup formatData:_renderedData frameRate:_frameRate frameLength:_frameLength sequenceOffsets:_seqFile.sequenceOffsets document:_seqFile];
        [data writeToURL:[panel URL] atomically:YES];

    }
    
    
}
//========================================================================
- (IBAction)renderData:(id)sender
{
//    NSInteger frameCount;
    self.isRendering=YES;
    DIYBURLCache* patternCache=[[DIYBURLCache alloc] init];
    DIYBImageCache* imageCache=[[DIYBImageCache alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* error=nil;
        NSData* temp;
        NSInteger myframeLength;
        NSInteger mymaxFrame;
        temp=[self->_seqFile renderDataWithImage:imageCache pattern:patternCache frameLength:&myframeLength  frameCount:&mymaxFrame error:&error];
        if (!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self willChangeValueForKey:@"frameLength"];
                [self willChangeValueForKey:@"maxFrame"];
                self->_frameLength=myframeLength;
                self->_maxFrame=mymaxFrame;
                [self didChangeValueForKey:@"frameLength"];
                [self didChangeValueForKey:@"maxFrame"];
                self.renderedData=temp;
                self.sequenceOffsets=self->_seqFile.sequenceOffsets;
                [self->_visualController updateSequence];
                [self->_exportGroup updateOffsets:self->_seqFile.sequenceOffsets document:self->_seqFile];
                self.isRendering=NO;
            });
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:nil contextInfo:NULL];
                self.isRendering=NO;
            });
        }
    });
}

//=======================================================================
- (void)setIsRendering:(BOOL)isRendering
{
    if (_isRendering && !isRendering && _shouldPlay)
    {
        _shouldPlay=NO;
        [_mediaPlayer playAction:self ];
    }
    _isRendering=isRendering;
}
//=======================================================================
- (IBAction)playButton:(id)sender
{
    if (_renderOnPlay && [_mediaPlayer.buttonTitle isEqualToString:@"Play"])
    {
        self.shouldPlay=YES;
        [self renderData:sender];
    }
    else
    {
        [_mediaPlayer playAction:sender];
    }
}
//========================================================================
- (IBAction)importSequence:(id)sender
{
    NSOpenPanel * panel=[NSOpenPanel openPanel];
    [panel setTitle:@"Import Sequence Selection"];
    [panel setPrompt:@"Select"];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    //[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"diybseq",@"com.diybllc.sequence", nil]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"diybseq"]]];

    if ([panel runModal]== NSModalResponseOK)
    {
        DIYBDocument* import=[[DIYBDocument alloc] init];
        NSError* error=nil;
        if ([import readFromURL:[panel URL] ofType:@"com.diybllc.sequence" error:&error])
        {
            NSSortDescriptor* descript=[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
            
            NSArray* itemarray=[import.sequenceItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:descript]];
            DIYBSequenceItem* newitem;
            
            NSInteger order=[self nextOrder];
            for (DIYBSequenceItem* item in itemarray)
            {
                newitem=[item mutableCopy];
                [_seqFile addSequenceItem:newitem];
                
                DIYBItemController* controller=[[DIYBItemController alloc] initWithItem:newitem displayOrder:order];
                order++;
                [_itemControllers addObject:controller];
                [_displayView addSubview:controller.view];
                [_effectView addSubview:controller.effectView];
                [controller addObserver:self forKeyPath:@"isExpanded" options:NSKeyValueObservingOptionNew context:IsExpandedContext];
                
            }
            _seqFile.frameRate=import.frameRate;
            [self willChangeValueForKey:@"frameRate"];
            _frameRate=_seqFile.frameRate;
            [self didChangeValueForKey:@"frameRate"];
            [_stepTime setIncrement:_frameRate];
            [_mediaPlayer setUpdateRate:_frameRate];

            [self appendGrids:import.grids.allValues];
            //_seqFile.media = import.media ;
            _seqFile.media = [[import.media stringByReplacingOccurrencesOfString:@".mov" withString:@".wav"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            if (_seqFile.media)
            {
                self.mediaFile = _seqFile.media;
                //self.mediaFile= [ _seqFile.media stringByReplacingOccurrencesOfString:@".mov" withString:@".wav"];
                [_mediaPlayer loadURL:[_prefData.mediaDirectory URLByAppendingPathComponent:_mediaFile]];
            }
            
            [self updateViews];
            [_seqFile updateChangeCount:NSChangeDone];
            
        }
        else
            [self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:nil contextInfo:NULL];
    }
}

//=============================================================================================
- (NSInteger)nextOrder
{
    NSSortDescriptor* descrip=[NSSortDescriptor sortDescriptorWithKey:@"orderDisplay" ascending:NO];
    NSArray* orderedarray=[_itemControllers sortedArrayUsingDescriptors:[NSArray arrayWithObject:descrip]];
    DIYBItemController* control=orderedarray.firstObject;
    return control.orderDisplay+1;

}
//=============================================================================================
- (IBAction)importGrids:(id)sender
{
    NSOpenPanel * panel=[NSOpenPanel openPanel];
    [panel setTitle:@"Import Sequence Grid Selection"];
    [panel setPrompt:@"Select"];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
//    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"diybseq",@"com.diybllc.sequence", nil]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"diybseq"]]];

    if ([panel runModal]== NSModalResponseOK)
    {
        DIYBDocument* import=[[DIYBDocument alloc] init];
        NSError* error=nil;
        if ([import readFromURL:[panel URL] ofType:@"com.diybllc.sequence" error:&error])
        {
            
            [self appendGrids:import.grids.allValues];
            [_seqFile updateChangeCount:NSChangeDone];
            
        }
        else
            [self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:nil contextInfo:NULL];
    }
    
}
//=============================================================================================
- (void)appendGrids:(NSArray*)grids
{
    for (DIYBGrid* grid in grids)
    {
        DIYBGrid* newgrid=[grid mutableCopy];
        [_seqFile.gridContainer addChild:newgrid.element];
        
        [_seqFile.grids setObject:newgrid forKey:newgrid.name];
    }
    _seqFile.gridNames=[[_seqFile.grids allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

}
// ===================================================================================
- (void)windowWillClose:(NSNotification *)notification
{
    [_mediaPlayer play:NO] ;
    [_visualController close] ;
    NSArray* visuals = [_accessorySelection entries] ;
    if (visuals){
        NSInteger count = [visuals count] ;
        for (NSInteger i = 0 ; i<count ; i++ ) {
            [[visuals[i] visualController] close];
            [visuals[i]  setVisualController:nil] ;
        }
        
    }
}
//=============================================================================================
- (IBAction)filterItems:(id)sender
{
    NSMutableArray* array=[NSMutableArray arrayWithCapacity:_itemControllers.count];
    for (DIYBItemController* controller in _itemControllers)
    {
        DIYBFilterItem* filter=[[DIYBFilterItem alloc] init];
        filter.itemController=controller;
        filter.itemName=controller.item.name;
        filter.order=controller.orderDisplay;
        filter.isVisible=controller.isVisible;
        [array addObject:filter];
        
    }
    DIYBFilterController* filtercontroller=[[DIYBFilterController alloc] initWithWindowNibName:@"DIYBFilterController"];
    filtercontroller.items=array;
    [self.window beginSheet:filtercontroller.window completionHandler:^(NSModalResponse returnCode)
     {
         if (returnCode==NSModalResponseOK)
         {
             for (DIYBFilterItem* item in filtercontroller.items)
             {
                 item.itemController.isVisible=item.isVisible;
                 item.itemController.orderDisplay=item.order;
             }
             [self updateViews];
         }
         
     }];

}



@end
