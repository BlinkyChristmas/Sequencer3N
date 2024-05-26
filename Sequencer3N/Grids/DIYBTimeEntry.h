//
//  DIYBTimeEntry.h
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBTimeEntry : NSObject<NSMutableCopying>
@property (strong) NSXMLElement* element;
- (id)initWithMilli:(NSInteger)milli;
- (id)initWithElement:(NSXMLElement*)element;
- (id)initWithTimeEntry:(DIYBTimeEntry*)entry;

- (NSInteger)milli;
- (void)setMilli:(NSInteger)milli;
- (CGFloat)time;
- (void)setTime:(CGFloat)time;

- (NSComparisonResult)compare:(DIYBTimeEntry*)entry;
@end
