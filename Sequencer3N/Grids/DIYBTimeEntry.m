//
//  DIYBTimeEntry.m
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBTimeEntry.h"

@implementation DIYBTimeEntry
@synthesize element=_element;

//===========================================================
+ (NSSet *)keyPathsForValuesAffectingMilli {
    return [NSSet setWithObjects:@"time", nil];
}
//===========================================================
+ (NSSet *)keyPathsForValuesAffectingTime {
    return [NSSet setWithObjects:@"milli", nil];
}
//===========================================================
- (id)initWithMilli:(NSInteger)milli
{
    self=[super init];
    if (self)
    {
        _element=[NSXMLElement elementWithName:@"timing"];
        
        NSXMLNode* node=[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%.3f",milli/1000.0]];
        [_element addAttribute:node];
    }
    return self;
}

//===========================================================
- (id)initWithElement:(NSXMLElement *)element
{
    self=[super init];
    if (self)
    {
        if (element && [element.name isEqualToString:@"timing"])
        {
            _element=element;
            
            NSXMLNode* node=[element attributeForName:@"centisecond"];
            if (node)
            {
                [node detach];
                NSInteger milli=[[node stringValue] integerValue]*10;
                node=[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%.3f",milli/1000.0]];
                [element addAttribute:node];
            }
            node=[element attributeForName:@"milli"];
            if (node)
            {
                [node detach];
                NSInteger milli=[[node stringValue] integerValue];
                
                node=[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%.3f",milli/1000.0]];
                [element addAttribute:node];
                
            }
        }
        else
        {
            NSException* exception=[NSException exceptionWithName:@"InvalidElement" reason:[NSString stringWithFormat:@"Element for timing is invalid: %@",element.name] userInfo:nil];
            self=nil;
            @throw exception;
        }
    }
    return self;
}
//==========================================================
- (id)initWithTimeEntry:(DIYBTimeEntry *)entry
{
    return [self initWithMilli:entry.milli];
}
//==========================================================
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[DIYBTimeEntry alloc] initWithTimeEntry:self];
}
//===========================================================
- (NSInteger)milli
{
    NSInteger milli=[self time]*10000;
    milli=milli/10;
    return milli;
}
//===========================================================
- (void)setMilli:(NSInteger)milli
{
    [self setTime:milli/1000.0];
}
//============================================================
- (CGFloat)time
{
    CGFloat rvalue=0.0;
    NSXMLNode* node=[self.element attributeForName:@"time"];
    if (node)
    {
        rvalue=[[node stringValue] doubleValue];
        
    }
    return rvalue;

}
//============================================================
- (void)setTime:(CGFloat)time
{
    NSXMLNode* node=[self.element attributeForName:@"time"];
    if (node)
    {
        [node setStringValue:[NSString stringWithFormat:@"%.3f",time]];
    }
    else
    {
        node = [NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%.3f",time]];
        [self.element addAttribute:node];
    }
    
}

//===============================
- (NSComparisonResult)compare:(DIYBTimeEntry*)entry
{
    NSComparisonResult rvalue=NSOrderedSame;
    if (entry.milli >self.milli)
    {
        rvalue=NSOrderedAscending;
    }
    else if (entry.milli<self.milli)
    {
        rvalue=NSOrderedDescending;
    }
    else
        rvalue=NSOrderedSame;
    
    return rvalue;
}
//=====================================================
- (NSString*)description
{
    return [NSString stringWithFormat:@"%.3f",self.milli/1000.0];
}


@end
