//
//  DIYBURLToString.m
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBURLToString.h"

@implementation DIYBURLToString


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+ (BOOL)allowsReverseTransformation
{
    return YES;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
- (id)transformedValue:(id)value
{
    NSString* rvalue=nil;
    if ((value!=nil) && ([value isKindOfClass:[NSURL class]]))
    {
        rvalue= [(NSURL*)value path] ;
    }
    return rvalue;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
- (id)reverseTransformedValue:(id)value
{
    NSString* rvalue=nil;
    if ((value!=nil) && ([value isKindOfClass:[NSString class]]))
    {
        rvalue= [[ NSURL fileURLWithPath:(NSString*)value ] path];
    }
    return rvalue ;
}

@end
