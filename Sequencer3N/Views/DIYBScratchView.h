//
//  DIYBScratchView.h
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DIYBScratchEntry;
@class DIYBTimeNowView;
@interface DIYBScratchView : NSView
@property (strong) NSColor* clearColor;
@property (strong) DIYBTimeNowView* timeView;
@property (strong,nonatomic) NSColor* scratchColor;
@property (strong,nonatomic) NSColor* timeNowColor;
@property (strong) NSBezierPath* path;
@property (assign,nonatomic) CGFloat timeNow;
@property (strong) NSMutableSet* scratchSet;
@property (assign) CGFloat dotsPerSecond;
@property (assign) BOOL isActive;
@property (assign,nonatomic) BOOL updateScratch;

- (NSInteger)timeMilli;
- (void)drawScratch:(DIYBScratchEntry*)entry;
- (void)spaceBar;
- (void)resetToolTips;
- (void)clearScratch;
@end
