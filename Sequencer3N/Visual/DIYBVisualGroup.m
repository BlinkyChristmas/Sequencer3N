//
//  DIYBVisualGroup.m
//  Sequencer3
//
//  Created by charles on 9/13/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBVisualGroup.h"
#import "DIYBVisualPath.h"
#import "DIYBLightStorage.h"
#import "DIYBLightGroup.h"
#import "DIYBLightSource.h"

@implementation DIYBVisualGroup

//======================================================================================
- (id)initWithElement:(NSXMLElement*)element
{
    self=[super init];
    if (self)
    {
        NSXMLNode* node=[element attributeForName:@"origin"];
        if (node)
        {
            _origin=[self pointForString:[node stringValue]];
        }
        else
            _origin=NSMakePoint(0.0, 0.0);
        node=[element attributeForName:@"scale"];
        if (node)
        {
            _scale=[[node stringValue] floatValue];
        }
        else
            _scale=1.0;
        _lights=[NSMutableArray arrayWithCapacity:100];
        NSArray* children=[element children];
        for (NSXMLNode* child in children)
        {
            if ([child kind]==NSXMLElementKind)
            {
                if ([child.name isEqualToString:@"oval"] || [child.name isEqualToString:@"line"])
                {
                    DIYBVisualPath* path=[[DIYBVisualPath alloc] initWithElement:(NSXMLElement*)child];
                    [_lights addObject:path];
                }
            }
        }
    }
    return self;
}
//====================================================================================
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

//=====================================================================================
- (void)drawData:(NSData*)data offset:(NSInteger)frameOffset
{
    
    if (data)
    {
        if ((_origin.x!=0.0) || (_origin.y!=0.0))
        {
            NSAffineTransform* transform=[NSAffineTransform transform];
            [transform translateXBy:_origin.x yBy:_origin.y];
            [transform concat];
        }
        if (_scale!=1.0)
        {
            NSAffineTransform* transform=[NSAffineTransform transform];
            [transform scaleBy:_scale];
            [transform concat];
        }
        for (DIYBVisualPath* path in _lights)
        {
            [path drawData:data offset:frameOffset];
        }
        if (_scale!=1.0)
        {
            NSAffineTransform* transform=[NSAffineTransform transform];
            [transform scaleBy:1.0/_scale];
            [transform concat];
        }
        if ((_origin.x!=0.0) || (_origin.y!=0.0))
        {
            NSAffineTransform* transform=[NSAffineTransform transform];
            [transform translateXBy:_origin.x yBy:_origin.y];
            [transform invert];
            [transform concat];
        }
        
    }
    
}

//=====================================================================================
- (void)updateOffsets:(NSDictionary*)sequenceOffsets document:(DIYBDocument *)document
{
    for (DIYBVisualPath* path in _lights)
    {
        if (path.sequenceItem)
        {
            NSNumber* number=[sequenceOffsets objectForKey:path.sequenceItem];
            if (number)
            {
                path.offset=number.integerValue;
                [path configureLightForDocument:document];
                
            }
            else
                path.offset=-1;
        }
        else
            path.offset=-1;
    }
}
@end
