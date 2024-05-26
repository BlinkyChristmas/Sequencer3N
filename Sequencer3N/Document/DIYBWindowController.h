//
//  DIYBWindowController.h
//  Sequencer3
//
//  Created by charles on 9/1/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@class SynchroScrollView;
@class DIYBMediaPlayer;
@class DIYBPrefData;
@class DIYBDocument;
@class DIYBBaseView;
@class DIYBEffectView;
@class DIYBGridView;
@class DIYBGrid;
@class DIYBTimeEntry;
@class DIYBContainerView;
@class DIYBEffectItem;
@class DIYBSequenceItem;
@class DIYBVisualController;
@class DIYBExportGroup;
@interface DIYBWindowController : NSWindowController
@property (weak) IBOutlet SynchroScrollView* effectScroll;
@property (weak) IBOutlet SynchroScrollView* sequenceItemScroll;
@property (weak) IBOutlet DIYBMediaPlayer* mediaPlayer;
@property (weak) IBOutlet NSStepper* stepTime;
@property (assign,nonatomic) CGFloat dotsPerSecond;
@property (assign,nonatomic) CGFloat scale;
@property (assign,nonatomic) CGFloat duration;
@property (assign) CGFloat resetTime;
@property (weak) DIYBDocument* seqFile;
@property (copy) NSString* mediaFile;
@property (strong) DIYBEffectView* effectView;
@property (strong) DIYBBaseView* displayView;
@property (strong) DIYBContainerView* containerView;
@property (assign,nonatomic) CGFloat frameRate;
@property (weak) DIYBPrefData* prefData;

@property (weak) DIYBGrid* ref1Grid;
@property (weak) DIYBGrid* ref2Grid;
@property (weak) DIYBGrid* ref3Grid;
@property (weak) DIYBGrid* activeGrid;
@property (assign,nonatomic)BOOL gridEnable;

@property (copy,nonatomic) NSString* ref1Name;
@property (copy,nonatomic) NSString* ref2Name;
@property (copy,nonatomic) NSString* ref3Name;
@property (copy,nonatomic) NSString* activeName;
@property (strong,nonatomic) NSColor* activeColor;
@property (weak) NSArray* gridNames;
@property (strong) DIYBGridView* gridView;

@property (strong) NSMutableSet* itemControllers;

@property (strong) DIYBVisualController* visualController;
@property (strong) DIYBExportGroup* exportGroup;

@property (assign) NSInteger maxFrame;
@property (assign) NSInteger frameLength;
@property (strong) NSData* renderedData;
@property (strong) NSDictionary* sequenceOffsets;
@property (assign,nonatomic) BOOL isRendering;
@property (assign) BOOL renderOnPlay;
@property (assign) BOOL shouldPlay;


- (IBAction)selectMedia:(id)sender;
- (IBAction)clearGrid:(id)sender;
- (IBAction)resetPlayTime:(id)sender;
- (IBAction)importSequence:(id)sender;
- (IBAction)importGrids:(id)sender;
- (void)windowWillClose:(NSNotification *)notification;
- (void)updateTimeEntry:(DIYBTimeEntry*)entry grid:(DIYBGrid*)grid time:(NSInteger)milli;
- (void)removeTimeEntry:(DIYBTimeEntry*)entry grid:(DIYBGrid*)grid;
- (void)addTimeEntry:(DIYBTimeEntry*)entry grid:(DIYBGrid*)grid;
- (void)updateEffect:(DIYBEffectItem*)effect withEffect:(DIYBEffectItem*)updatedItem view:(id)view;
- (void)removeEffect:(DIYBEffectItem*)effect item:(DIYBSequenceItem*)item view:(id)view;
- (void)addEffect:(DIYBEffectItem*)effect item:(DIYBSequenceItem*)item view:(id)view;

- (void)updateEffectViews;
- (IBAction)playButton:(id)sender;
- (IBAction)batchTimeEntry:(id)sender;
- (IBAction)removeGridDialog:(id)sender;
- (IBAction)createGridDialog:(id)sender;
- (IBAction)createSequenceDialog:(id)sender;
- (IBAction)removeSequenceDialog:(id)sender;
- (IBAction)clearScratch:(id)sender;

- (IBAction)renderData:(id)sender;
- (IBAction)filterItems:(id)sender;
- (IBAction)setExportFile:(id)sender;
- (IBAction)exportData:(id)sender;
@end
