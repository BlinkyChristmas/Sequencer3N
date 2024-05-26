//
//  DIYBGridView.h
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBBaseView.h"
@class DIYBGrid;
@class DIYBTimeEntry;
@class DIYBScratchView;
@class DIYBTimeEntryController;

@interface DIYBGridView : NSView
{
    CGFloat _dash[2];
}
@property (strong) DIYBTimeEntryController* timeController;
@property (strong) NSColor* background;
@property (weak,nonatomic) DIYBGrid* ref1Grid;
@property (weak,nonatomic) DIYBGrid* ref2Grid;
@property (weak,nonatomic) DIYBGrid* ref3Grid;
@property (weak,nonatomic) DIYBGrid* activeGrid;
@property (strong,nonatomic) NSColor* selectedColor;
@property (strong) NSBezierPath* ref1Path;
@property (strong) NSBezierPath* ref2Path;
@property (strong) NSBezierPath* ref3Path;
@property (strong) NSBezierPath* activePath;
@property (strong) NSBezierPath* pathNow;

@property (assign) CGFloat dotsPerSecond;
@property (weak,nonatomic) DIYBTimeEntry* selectedEntry;
@property (strong) DIYBTimeEntry* copiedEntry;
@property (assign) BOOL isActive;

@property (assign) NSInteger clickTime;

@property(strong) DIYBScratchView* scratchView;

- (void)buildPaths;
- (DIYBTimeEntry*)entryForMilli:(NSInteger)milli;
- (void)drawGrids:(NSRect)rect;
- (void)drawGrid:(DIYBGrid*)grid predicate:(NSPredicate*)predicate refPath:(NSBezierPath*)refPath;

- (void)resetToolTips;
- (void)setUpdateScratch:(BOOL)value;
@end
