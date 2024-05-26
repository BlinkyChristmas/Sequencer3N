//
//  NSColor+Serialization.m
//  Sequencer2
//
//  Created by charles on 8/18/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "NSColor+Serialization.h"

@implementation NSColor (Serialization)
//===============================================
+ (NSColor*)colorForString:(NSString*)string
{
    NSColor* rvalue=[NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    NSArray* array=[string componentsSeparatedByString:@","];
    if (array.count==3)
    {
        rvalue=[NSColor colorWithDeviceRed:[[array objectAtIndex:0] doubleValue] green:[[array objectAtIndex:1] doubleValue] blue:[[array objectAtIndex:2] doubleValue] alpha:1.0];
    }
    return rvalue;
    
}
//===============================================
- (NSString*)stringValue
{
    NSColor* color=[self colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    return [NSString stringWithFormat:@"%f,%f,%f",[color redComponent],[color greenComponent],[color blueComponent]];

}

@end
