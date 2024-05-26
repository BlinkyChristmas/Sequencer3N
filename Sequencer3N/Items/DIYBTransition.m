//
//  DIYBTransition.m
//  Sequencer3
//
//  Created by charles on 9/8/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBTransition.h"

@implementation DIYBTransition

//=====================================================================================
- (id)initWithElement:(NSXMLElement *)element
{
    self=[super init];
    if (self)
    {
        _effect=[element.name copy];
        NSXMLNode * node=[element attributeForName:@"startImage"];
        if (node)
        {
            _startImage=[[node stringValue] copy];
        }
        node=[element attributeForName:@"endImage"];
        if (node) {
            _endImage=[[node stringValue] copy];
        }
        node=[element attributeForName:@"maskImage"];
        if (node) {
            _maskImage=[[node stringValue] copy];
        }
        node=[element attributeForName:@"startOrigin"];
        if (node) {
            _startOrigin=[self pointForString:node.stringValue];
        }
        else
            _startOrigin=NSMakePoint(0.0, 0.0)  ;
        node=[element attributeForName:@"endOrigin"];
        if (node) {
            _endOrigin=[self pointForString:node.stringValue];
        }
        else
            _endOrigin=NSMakePoint(0.0, 0.0)  ;
        node=[element attributeForName:@"maskOrigin"];
        if (node) {
            _maskOrigin=[self pointForString:node.stringValue];
        }
        else
            _maskOrigin=NSMakePoint(0.0, 0.0)  ;
        
    }
    return self;
}

//=======================================
- (NSPoint)pointForString:(NSString *)string
{
    NSPoint origin=NSMakePoint(0.0, 0.0);
    NSArray* array=[string componentsSeparatedByString:@","];
    if (array.count==2)
    {
        origin=NSMakePoint([[array objectAtIndex:0] doubleValue], [[array objectAtIndex:1] doubleValue]);
    }
    return origin;
}


@end
