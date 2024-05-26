//
//  DIYBScratchEntry.h
//  Sequencer2
//
//  Created by charles on 8/29/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIYBScratchEntry : NSObject
@property (assign) CGFloat time;

- (NSInteger)milli;
- (id)initWithTime:(CGFloat)time;
- (NSComparisonResult)sortByMilli:(DIYBScratchEntry*)entry;
@end
