//
//  DIYBGrid.h
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DIYBTimeEntry;
@interface DIYBGrid : NSObject<NSMutableCopying>
@property (strong) NSXMLElement* element;
@property (strong) NSMutableSet* entries;
+ (NSInteger)convertTime:(CGFloat)time;
+ (NSInteger)milliTolerance;
- (id)initWithName:(NSString*)name;
- (id)initWithElement:(NSXMLElement*)element;
- (id)initWithGrid:(DIYBGrid*)grid;

- (NSString*)name;
- (void)setName:(NSString*)name;
- (NSString*)color;
- (void)setColor:(NSString*)color;
- (NSColor*)drawColor;
- (NSArray*)sortedEntries;
- (DIYBTimeEntry*)entryForMilli:(NSInteger)milli;
- (DIYBTimeEntry*)entryAfterMilli:(NSInteger)milli;
- (DIYBTimeEntry*)entryBeforeMilli:(NSInteger)milli;
- (DIYBTimeEntry*)closestMilli:(NSInteger)milli;
- (NSArray*)entriesBetweenMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli;
- (DIYBTimeEntry*)findMilli:(NSInteger)milli withTolerance:(NSInteger)toler;
- (DIYBTimeEntry*)entryForStartMilli:(NSInteger)milli afterEntryCount:(NSInteger)entryCount;
- (DIYBTimeEntry*)addEntryForMilli:(NSInteger)milli;
- (void)removeEntryForMilli:(NSInteger)milli;
- (void)removeEntry:(DIYBTimeEntry*)entry;
- (NSComparisonResult) sortByName:(DIYBGrid*)grid;
- (void)addEntry:(DIYBTimeEntry*)entry;


@end
