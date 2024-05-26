//
//  DIYBLightGroup.m
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBLightGroup.h"
#import "DIYBLightSource.h"

@implementation DIYBLightGroup

//================================================================================
- (id)initWithElement:(NSXMLElement *)element
{
    self=[super init];
    if (self)
    {
        _lights=[NSMutableSet setWithCapacity:100];
        NSXMLNode* node=[element attributeForName:@"name"];
        if (node)
        {
            _name=[[node stringValue] copy];
        }
        node=[element attributeForName:@"patternDirectory"];
        if (node)
        {
            _patternDirectory=[[node stringValue] copy];
        }
        else
        {
            _patternDirectory=_name;
        }
        node=[element attributeForName:@"imageDirectory"];
        if (node)
        {
            _imageDirectory=[[node stringValue] copy];
        }
        else
            _imageDirectory=_name;
        NSArray* array=[element elementsForName:@"lightSource"];
        NSInteger index=0;
        _channelCount=0;
        for (NSXMLElement* child in array)
        {
            DIYBLightSource* source=[[DIYBLightSource alloc] initWithElement:child order:index offset:_channelCount];
            index++;
            _channelCount+=source.channelCount;
            [_lights addObject:source];
        }
    }
    return self;
}
//================================================================================
- (DIYBLightSource*)lightForName:(NSString *)name
{
    NSSet* set=[_lights filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name=%@",name]];
    return set.anyObject;
}
//================================================================================
- (NSArray*)orderedLights
{
    return [_lights sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]]];
}
//================================================================================
- (NSComparisonResult)caseInsensitiveCompare:(DIYBLightGroup*)group
{
    return [self.name caseInsensitiveCompare:group.name];
}
@end
