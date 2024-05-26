//
//  DIYBEffectItem.m
//  Sequencer3
//
//  Created by charles on 9/3/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBEffectItem.h"
#import "PixelEffect.h"
#import "DIYBURLCache.h"
@implementation DIYBEffectItem

//===========================================================================
+ (NSSet*)keyPathsForValuesAffectingScratchEnd
{
    return [NSSet setWithObject:@"isSelected"];
}
//===========================================================================
+ (NSSet*)keyPathsForValuesAffectingScratchStart
{
    return [NSSet setWithObject:@"isSelected"];
}
//===========================================================================
+ (BOOL)supportsSecureCoding
{
    return YES;
}
//===========================================================================
- (id)init
{
    self =[super init];
    if (self)
    {
        _element=[NSXMLElement elementWithName:@"effect"];
        //_effectLayer=[CALayer layer];
        //[_effectLayer setHidden:YES];
    }
    return self;
}
//===========================================================================
- (id)initWithItem:(DIYBEffectItem *)item
{
    self = [self init];
    if (self)
    {
        self.effect=item.effect;
        self.pattern_light=item.pattern_light;
        self.layer=item.layer;
        self.startTime=item.startTime;
        self.endTime=item.endTime;
        self.grid=item.grid;
        self.scratchEnd=item.scratchEnd;
        self.scratchStart=item.scratchStart;
        _isSelected=item.isSelected;
    }
    return self;
}
//===========================================================================
- (id)initWithElement:(NSXMLElement *)element
{
    self=[self init];
    if (self)
    {
        _element=element;
    }
    return self;
}
//===========================================================================
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[self init];
    if (self)
    {
        NSString* string=[aDecoder decodeObjectOfClass:[NSString class] forKey:@"EFFECT"];
        [self setEffect:string];
        string=[aDecoder decodeObjectOfClass:[NSString class] forKey:@"PATTERN_LIGHT"];
        [self setPattern_light:string];
        if ([self isPattern])
        {
            string=[aDecoder decodeObjectOfClass:[NSString class] forKey:@"GRID"];
            [self setGrid:string];
        }
        [self setStartTime:[aDecoder decodeDoubleForKey:@"STARTTIME"]];
        [self setEndTime:[aDecoder decodeDoubleForKey:@"ENDTIME"]];
        [self setLayer:[aDecoder decodeIntegerForKey:@"LAYER"]];
    }
    return self;
}
//===========================================================================
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[DIYBEffectItem alloc] initWithItem:self];
}
//===========================================================================
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.effect forKey:@"EFFECT"];
    [aCoder encodeDouble:self.startTime forKey:@"STARTTIME"];
    [aCoder encodeDouble:self.endTime forKey:@"ENDTIME"];
    [aCoder encodeInteger:self.layer forKey:@"LAYER"];
    [aCoder encodeObject:self.pattern_light forKey:@"PATTERN_LIGHT"];
    [aCoder encodeObject:self.grid forKey:@"GRID"];
}

//===========================================================================
- (NSInteger)layer
{
    NSInteger rvalue=0;
    NSXMLNode* node=[_element attributeForName:@"layer"];
    if (node)
    {
        rvalue=[[node stringValue] integerValue];
    }
    return rvalue;
}
//===========================================================================
- (void)setLayer:(NSInteger)layer
{
    NSXMLNode* node=[_element attributeForName:@"layer"];
    if (node)
    {
        [node setStringValue:[NSString stringWithFormat:@"%ld",layer]];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"layer" stringValue:[NSString stringWithFormat:@"%ld",layer]];
        [_element addAttribute:node];
    }
    
}

//===========================================================================
- (NSInteger)startMilli
{
    NSInteger rvalue=self.startTime  * 10000;
    return rvalue/10;
}
//===========================================================================
- (void)setStartMilli:(NSInteger)startMilli
{
    [self setStartTime:startMilli/1000.0];
}
//===========================================================================
- (NSInteger)endMilli
{
    NSInteger rvalue=self.endTime  * 10000;
    return rvalue/10;
}
//===========================================================================
- (void)setEndMilli:(NSInteger)endMilli
{
    [self setEndTime:endMilli/1000.0];
}
//===========================================================================
- (CGFloat)startTime
{
    CGFloat rvalue=0.f;
    NSXMLNode* node=[_element attributeForName:@"startTime"];
    if (node)
    {
        rvalue=[[node stringValue] doubleValue];
    }
    return rvalue;
}
//===========================================================================
- (void)setStartTime:(CGFloat)startTime
{
    NSXMLNode* node=[_element attributeForName:@"startTime"];
    if (node)
    {
        [node setStringValue:[NSString stringWithFormat:@"%.3f",startTime]];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"startTime" stringValue:[NSString stringWithFormat:@"%.3f",startTime]];
        [_element addAttribute:node];
    }
}

//===========================================================================
- (CGFloat)endTime
{
    CGFloat rvalue=0.f;
    NSXMLNode* node=[_element attributeForName:@"endTime"];
    if (node)
    {
        rvalue=[[node stringValue] doubleValue];
    }
    return rvalue;
}

//===========================================================================
- (void)setEndTime:(CGFloat)endTime
{
    NSXMLNode* node=[_element attributeForName:@"endTime"];
    if (node)
    {
        [node setStringValue:[NSString stringWithFormat:@"%.3f",endTime]];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"endTime" stringValue:[NSString stringWithFormat:@"%.3f",endTime]];
        [_element addAttribute:node];
    }
}

//===========================================================================
- (NSString*)pattern_light
{
    NSXMLNode* node;
    if ([self isPattern])
    {
        node=[_element attributeForName:@"pattern"];
    }
    else
    {
        node=[_element attributeForName:@"lightSource"];
    }
    return [[node stringValue] copy];
}
//============================================================================
- (void)setPattern_light:(NSString *)pattern_light
{
    NSXMLNode* node;
    if (pattern_light)
    {
        if ([self isPattern])
        {
            node=[_element attributeForName:@"pattern"];
            if (!node)
            {
                node=[NSXMLNode attributeWithName:@"pattern" stringValue:pattern_light];
                [_element addAttribute:node];
                node=nil;
            }
            
        }
        else
        {
            node=[_element attributeForName:@"lightSource"];
            if (!node)
            {
                node=[NSXMLNode attributeWithName:@"lightSource" stringValue:pattern_light];
                [_element addAttribute:node];
                node=nil;
            }
        }
        if (node)
        {
            [node setStringValue:pattern_light];
        }
    }
}
//===========================================================================
- (NSString*)grid
{
    NSXMLNode* node=nil;
    if ([self isPattern])
    {
        node=[_element attributeForName:@"grid"];
    }
    return [[node stringValue] copy];
}
//==================================================================================
- (void)setGrid:(NSString *)grid
{
    if (grid)
    {
        NSXMLNode* node=nil;
        if ([self isPattern])
        {
            node=[_element attributeForName:@"grid"];
            if (node)
            {
                [node setStringValue:grid];
            }
            else
            {
                node=[NSXMLNode attributeWithName:@"grid" stringValue:grid];
                [_element addAttribute:node];
            }
        }
        
    }
}
//==================================================================================
- (NSString*)effect
{
    NSXMLNode* node=[_element attributeForName:@"type"];
    if (node)
    {
        return [[node stringValue] copy];
    }
    return nil;
}

//==================================================================================
- (void)setEffect:(NSString *)effect
{
    if (effect)
    {
        NSXMLNode* node=[_element attributeForName:@"type"];
        if (node)
        {
            [node setStringValue:effect];
        }
        else
        {
            node=[NSXMLNode attributeWithName:@"type" stringValue:effect];
            [_element addAttribute:node];
        }
    }
}
//==================================================================================
- (NSComparisonResult)displayOrder:(DIYBEffectItem*)entry
{
    NSComparisonResult result=NSOrderedSame;
    
    if ([entry isSelected] && ![self isSelected])
    {
        result=NSOrderedAscending;
    }
    else if (![entry isSelected] && [self isSelected])
    {
        result=NSOrderedDescending;
    }
    else if (entry.layer> self.layer)
    {
        result=NSOrderedAscending;
    }
    else if (entry.layer<self.layer)
    {
        result=NSOrderedDescending;
    }
    else if (entry.startMilli > self.startMilli)
    {
        result=NSOrderedAscending;
    }
    else if (entry.startMilli<self.startMilli)
    {
        result=NSOrderedDescending;
    }
    else if (entry.endMilli>self.endMilli)
    {
        result=NSOrderedAscending;
    }
    else if (entry.endMilli <self.endMilli)
    {
        result=NSOrderedDescending;
    }
    return result;
    
}

//==================================================================================
- (NSComparisonResult)applyOrder:(DIYBEffectItem*)entry
{
    NSComparisonResult result=NSOrderedSame;
    
    if (entry.layer> self.layer)
    {
        result=NSOrderedAscending;
    }
    else if (entry.layer<self.layer)
    {
        result=NSOrderedDescending;
    }
    else if (entry.startMilli > self.startMilli)
    {
        result=NSOrderedAscending;
    }
    else if (entry.startMilli<self.startMilli)
    {
        result=NSOrderedDescending;
    }
    else if (entry.endMilli>self.endMilli)
    {
        result=NSOrderedAscending;
    }
    else if (entry.endMilli <self.endMilli)
    {
        result=NSOrderedDescending;
    }
    return result;
    
}

//===========================================================================================================
- (BOOL)isPattern
{
    return [self.effect isEqualToString:(NSString*)PatternEffect];
}
//===========================================================================================================
- (NSString*)description
{
    NSString * desc=[NSString stringWithFormat:@"%@: %@  Range: %.3f-%.3f Layer: %ld",self.effect,self.pattern_light,self.startTime,self.endTime,self.layer];
    if ([self isPattern])
    {
        desc=[NSString stringWithFormat:@"%@: %@  Grid: %@  Range: %.3f-%.3f Layer: %ld",self.effect,self.pattern_light,self.grid,self.startTime,self.endTime,self.layer];
    }
    return desc;
}

//===========================================================================================================
- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected=isSelected;
    _scratchEnd=self.endMilli;
    _scratchStart=self.startMilli;
}

//===========================================================================================================
- (void)resetScratch
{
    self.scratchEnd=[self endMilli];
    self.scratchStart=[self startMilli];
}
//===========================================================================================================
- (void)updateFromScratch
{
    self.startMilli=[self scratchStart];
    self.endMilli =[self scratchEnd];
}
//===========================================================================================================
- (NSRect)drawRect:(CGFloat )dotsPerSec height:(CGFloat )height
{
    NSRect draw;
    draw.size.height=height/2.0;
//    draw.size.height=height-4.0;
    draw.origin.y=height/4.0;
    if ([self isSelected])
    {
        draw.size.width=(([self scratchEnd]-[self scratchStart])/1000.0)*dotsPerSec;
        draw.origin.x=([self scratchStart]/1000.0)*dotsPerSec;
    }
    else
    {
        draw.size.width=(([self endMilli]-[self startMilli])/1000.0)*dotsPerSec;
        draw.origin.x=([self startMilli]/1000.0)*dotsPerSec;
        
    }
    return draw;
}

//===========================================================================================================
- (NSRect)drawRect:(CGFloat )dotsPerSec height:(CGFloat )height layer:(NSInteger)layer
{
    NSRect draw;
    draw.size.height=height/2.0;
    //    draw.size.height=height-4.0;
    draw.origin.y=height/4.0 + layer*height ;
    if ([self isSelected])
    {
        draw.size.width=(([self scratchEnd]-[self scratchStart])/1000.0)*dotsPerSec;
        draw.origin.x=([self scratchStart]/1000.0)*dotsPerSec;
    }
    else
    {
        draw.size.width=(([self endMilli]-[self startMilli])/1000.0)*dotsPerSec;
        draw.origin.x=([self startMilli]/1000.0)*dotsPerSec;
        
    }
    
    return draw;
}

//=======================================================================================================
- (NSArray*)transitionsWithCache:(DIYBURLCache*)cache baseURL:(NSURL*)url error:(NSError* __autoreleasing*)error
{
    NSArray* rvalue=nil;
    if (self.isPattern)
    {
        NSURL* loc=[url URLByAppendingPathComponent:self.pattern_light];
        rvalue= [cache transistionForPatternURL:loc error:error];
    }
    return rvalue;
}
@end
