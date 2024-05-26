//
//  DIYBGrid.m
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBGrid.h"
#import "DIYBTimeEntry.h"
#import "NSColor+Serialization.h"

@implementation DIYBGrid
@synthesize element=_element;
@synthesize entries=_entries;
//===========================================================
+ (NSInteger)convertTime:(CGFloat)time
{
    NSInteger milli=time*10000;
    milli=milli/10;
    return milli;
}
//===========================================================
+ (NSInteger)milliTolerance
{
    return 10;
}

//===========================================================
- (id)initWithName:(NSString*)name
{
    self=[super init];
    if (self)
    {
        _element=[NSXMLElement elementWithName:@"timingGrid"];
        NSXMLNode* node=[NSXMLNode attributeWithName:@"name" stringValue:name];
        [_element addAttribute:node];
        node=[NSXMLNode attributeWithName:@"color" stringValue:@"0.0,0.0,0.0"];
        [_element addAttribute:node];
        _entries=[NSMutableSet setWithCapacity:100] ;
    }
    return self;
}
//===========================================================
- (id)initWithElement:(NSXMLElement*)element
{
    self=[super init];
    if (self)
    {
        if (element && [element.name isEqualToString:@"timingGrid"])
        {
            _element=element;
            _entries=[NSMutableSet setWithCapacity:100];
            NSArray* array=[element elementsForName:@"timing"];
            for (NSXMLElement* child in array)
            {
                [_entries addObject:[[DIYBTimeEntry alloc] initWithElement:child]];
            }
        }
        else
        {
            NSException* exception=[NSException exceptionWithName:@"InvalidElement" reason:[NSString stringWithFormat:@"Invalid elment for timingGrid: %@",element.name] userInfo:nil];
            self=nil;
            @throw exception;
        }
    }
    return self;
}
//===========================================================
- (id)initWithGrid:(DIYBGrid*)grid
{
    self=[super init];
    if (self)
    {
        _element=[NSXMLElement elementWithName:grid.element.name];
        _entries=[NSMutableSet setWithCapacity:100];
        NSXMLNode* node=[NSXMLNode attributeWithName:@"name" stringValue:grid.name];
        [_element addAttribute:node];
        node=[NSXMLNode attributeWithName:@"color" stringValue:grid.color];
        [_element addAttribute:node];
        NSArray * array=[grid sortedEntries];
        for (DIYBTimeEntry* entry in array)
        {
            DIYBTimeEntry* value=[entry mutableCopy];
            [_element addChild:value.element];
            [self.entries addObject:value];
        }
    }
    return self;
}
//===========================================================
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[DIYBGrid alloc] initWithGrid:self];
}
//===========================================================
- (NSString*)name
{
    NSString* rvalue=@"No Grid";
    NSXMLNode* node=[self.element attributeForName:@"name"];
    if (node)
    {
        rvalue=[[node stringValue] copy];
    }
    return rvalue;
}
//===========================================================
- (void)setName:(NSString *)name
{
    NSXMLNode* node=[self.element attributeForName:@"name"];
    if (node)
    {
        [node setStringValue:name];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"name" stringValue:name];
        [self.element addAttribute:node];
    }
   
}
//===========================================================
- (NSString*)color
{
    NSString* rvalue=@"0.0,0.0,0.0";
    NSXMLNode* node=[self.element attributeForName:@"color"];
    if (node)
    {
        rvalue=[[node stringValue] copy];
    }
    return rvalue;
}
//===========================================================
- (void)setColor:(NSString *)color
{
    NSXMLNode* node=[self.element attributeForName:@"color"];
    if (node)
    {
        [node setStringValue:color];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"color" stringValue:color];
        [self.element addAttribute:node];
    }
    
}
//===========================================================
- (NSArray*)sortedEntries
{
    return [[self.entries allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

//===========================================================
- (DIYBTimeEntry*)entryForMilli:(NSInteger)milli
{
    DIYBTimeEntry* rvalue=nil;
    NSArray* array=[self sortedEntries];
    for (DIYBTimeEntry* entry in array)
    {
        if (entry.milli==milli)
        {
            rvalue=entry;
            break;
        }
    }
    return rvalue;
}
//===========================================================
- (DIYBTimeEntry*)entryBeforeMilli:(NSInteger)milli
{
    DIYBTimeEntry* rvalue=nil;
    NSInteger count=0;
    NSArray* array=[self sortedEntries];
    if (array.count>0)
    {
        for (DIYBTimeEntry* entry in array)
        {
            if (entry.milli==milli)
            {
                rvalue=entry;
                break;
            }
            else if ((entry.milli>milli) && (count>0))
            {
                rvalue=[array objectAtIndex:count-1];
                break;
                
            }
            count++;
        }
        if (!rvalue)
        {
            rvalue=[array objectAtIndex:array.count-1];
        }
    }
    return rvalue;
}
//===========================================================
- (DIYBTimeEntry*)entryAfterMilli:(NSInteger)milli
{
    DIYBTimeEntry* rvalue=nil;
    NSArray* array=[self sortedEntries];
    if (array.count>0)
    {
        for (DIYBTimeEntry* entry in array)
        {
            if (entry.milli==milli)
            {
                rvalue=entry;
                break;
            }
            else if (entry.milli>milli)
            {
                rvalue=entry;
                break;
            }
        }
    }
    return rvalue;
}
//=============================================================
- (DIYBTimeEntry*)closestMilli:(NSInteger)milli
{
    DIYBTimeEntry* rvalue=nil;
    DIYBTimeEntry* beforeEntry=[self entryBeforeMilli:milli];
    DIYBTimeEntry* afterEntry=[self entryAfterMilli:milli];
    if (beforeEntry)
    {
        rvalue=beforeEntry;
        if (afterEntry && (beforeEntry!=afterEntry))
        {
            NSInteger beforeDelta=milli-beforeEntry.milli;
            NSInteger afterDelata=afterEntry.milli-milli;
            if (afterDelata<beforeDelta)
            {
                rvalue=afterEntry;
            }
        }
    }
    else
        rvalue=afterEntry;
    return rvalue;
}
//=============================================================
- (NSArray*)entriesBetweenMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli
{
    
    NSPredicate * predicate=[NSPredicate predicateWithFormat:@"(milli>=%ld) AND (milli<=%ld)",startMilli,endMilli];
    NSSet* values=[self.entries filteredSetUsingPredicate:predicate];
    return [[values allObjects] sortedArrayUsingSelector:@selector(compare:)];

    
}
//=============================================================
- (DIYBTimeEntry*)findMilli:(NSInteger)milli withTolerance:(NSInteger)toler
{
    NSPredicate * predicate=[NSPredicate predicateWithFormat:@"(milli>=%ld) AND (milli<=%ld)",milli-toler,milli+toler];
    NSSet* values=[self.entries filteredSetUsingPredicate:predicate];
    return values.anyObject;

}

//=============================================================
- (DIYBTimeEntry*)entryForStartMilli:(NSInteger)milli afterEntryCount:(NSInteger)entryCount
{
    NSArray* array=[self sortedEntries];
    DIYBTimeEntry* rvalue=nil;
    NSMutableArray* temp=[NSMutableArray arrayWithCapacity:100];
    for (DIYBTimeEntry* entry in array)
    {
        if (entry.milli>=milli)
        {
            [temp addObject:entry];
            entryCount--;
            if (entryCount <=0)
            {
                break;
            }
        }
    }
    if (temp.count>0)
    {
        rvalue=[temp objectAtIndex:temp.count-1];
    }
    return rvalue;
}

//=============================================================
- (DIYBTimeEntry*)addEntryForMilli:(NSInteger)milli
{
    DIYBTimeEntry* rvalue=[self findMilli:milli withTolerance:[DIYBGrid milliTolerance]];
    if (!rvalue)
    {
        rvalue=[[DIYBTimeEntry alloc] initWithMilli:milli];
        [self.element addChild:rvalue.element];
        [self.entries addObject:rvalue];
    }
    return rvalue;
}
//=============================================================
- (void)removeEntryForMilli:(NSInteger)milli
{
    DIYBTimeEntry* rvalue=[self findMilli:milli withTolerance:[DIYBGrid milliTolerance]];
    if (rvalue)
    {
        [self removeEntry:rvalue];
    }
}
//=============================================================
- (void)removeEntry:(DIYBTimeEntry*)entry
{
    [entry.element detach];
    NSSet* minus=[NSSet setWithObject:entry];
    [self.entries minusSet:minus];
}
//=============================================================
- (void)addEntry:(DIYBTimeEntry*)entry
{
    [self.element addChild:entry.element];
    [self.entries addObject:entry];
}
//=============================================================
- (NSComparisonResult) sortByName:(DIYBGrid*)grid
{
    return [self.name caseInsensitiveCompare:grid.name];
}
//==================================================================
- (NSColor*)drawColor
{
    return  [NSColor colorForString:self.color];
}
@end
