//
//  DIYBGridBatch.h
//  Sequencer3
//
//  Created by charles on 9/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DIYBPrefData;
@class DIYBWindowController;

@interface DIYBGridBatch : NSWindowController
@property (weak) DIYBPrefData* prefData;
@property (weak) DIYBWindowController* controller;

@property (weak) NSArray* gridNames;
@property (weak) NSDictionary* grids;

@property (copy) NSString* sourceGrid;
@property (copy) NSString* destGrid;

@property (assign) CGFloat startTime;
@property (assign) CGFloat endTime;
@property (assign) CGFloat offset;

@property (assign) NSInteger divisor;

@property (assign) BOOL useOffset;

@property (assign) CGFloat duration;

@property (assign,nonatomic) BOOL shouldExpand;
@property (assign,nonatomic) BOOL shouldContract;

- (IBAction)cancelButton:(id)sender;


@end
