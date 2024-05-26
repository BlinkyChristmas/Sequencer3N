//
//  DIYBEffectItem.h
//  Sequencer3
//
//  Created by charles on 9/3/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DIYBURLCache;

@interface DIYBEffectItem : NSObject<NSMutableCopying,NSSecureCoding>

@property (strong) NSXMLElement* element;

@property(assign,nonatomic) NSInteger startMilli;
@property(assign,nonatomic) NSInteger endMilli;
@property(assign,nonatomic) NSInteger layer;

@property (assign) NSInteger scratchStart;
@property (assign) NSInteger scratchEnd;
@property (assign,nonatomic) BOOL isSelected;
@property (strong) CALayer* effectLayer;

@property(copy,nonatomic) NSString* effect;
@property(copy,nonatomic) NSString* grid;
@property(copy,nonatomic) NSString* pattern_light;

- (id)initWithItem:(DIYBEffectItem *)item;
- (id)initWithElement:(NSXMLElement*)element;

- (CGFloat)startTime;
- (void)setStartTime:(CGFloat)startTime;
- (CGFloat)endTime;
- (void)setEndTime:(CGFloat)endTime;

- (NSComparisonResult)displayOrder:(DIYBEffectItem*)entry;

- (NSComparisonResult)applyOrder:(DIYBEffectItem*)entry;

- (BOOL)isPattern;

- (void)resetScratch;
- (void)updateFromScratch;
- (NSRect)drawRect:(CGFloat)dotsPerSec height:(CGFloat)height layer:(NSInteger)layer;

- (NSArray*)transitionsWithCache:(DIYBURLCache*)cache baseURL:(NSURL*)url error:(NSError* __autoreleasing *)error;


@end
