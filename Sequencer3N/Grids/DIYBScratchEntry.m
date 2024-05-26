//
//  DIYBScratchEntry.m
//  Sequencer2
//
//  Created by charles on 8/29/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBScratchEntry.h"

@implementation DIYBScratchEntry
@synthesize time=_time;

//==================================================================
- (id)initWithTime:(CGFloat)time
{
    self=[super init];
    if (self)
    {
        _time=time;
    }
    return self;
}
//==================================================================
- (NSInteger)milli
{
    NSInteger milli=self.time*10000;
    return milli/10;
}

//==================================================================
- (NSComparisonResult)sortByMilli:(DIYBScratchEntry*)entry
{
    NSComparisonResult result=NSOrderedSame;
    if (self.milli>entry.milli)
    {
        result=NSOrderedDescending;
    }
    else if (self.milli< entry.milli)
    {
        result=NSOrderedAscending;
    }
    return result;
}

//==================================================================
- (NSString*)description
{
    return [NSString stringWithFormat:@"%.3f",_time];
}
@end
