//
//  DIYBVisualPath.m
//  Sequencer2
//
//  Created by charles on 8/30/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBVisualPath.h"
#import "DIYBColor.h"
#import "DIYBLightSource.h"
#import "DIYBLightStorage.h"
#import "DIYBLightGroup.h"
#import "DIYBDocument.h"
#import "DIYBSequenceItem.h"

@implementation DIYBVisualPath


//=====================================================================================================================
+ (BOOL)validElement:(NSString*)name
{
    if ([name isEqualToString:@"oval"]|| [name isEqualToString:@"line"]) {
        return YES;
    }
    return NO;
}
//=====================================================================================================================
- (id)initWithElement:(NSXMLElement*)element
{
    self=[super init];
    if (self)
    {
        _isOval=NO;
        _light=nil;
        _lightSource=nil;
        _sequenceItem=nil;
        if (element)
        {
            if ([element.name isEqualToString:@"oval"])
            {
                _isOval=YES;
                [self setCommonItems:element];
                [self buildOval:element];
            }
            else if ([element.name isEqualToString:@"line"])
            {
                [self setCommonItems:element];
                [self buildLine:element];
            }
            else
            {
                NSException* exception=[NSException exceptionWithName:@"InvalidElement" reason:[NSString stringWithFormat:@"Invalid elment for visualization: %@",element.name] userInfo:nil];
                self=nil;
                @throw exception;
                
            }
        }
        else
        {
            NSException* exception=[NSException exceptionWithName:@"InvalidElement" reason:[NSString stringWithFormat:@"Visualization elment is nil"] userInfo:nil];
            self=nil;
            @throw exception;
            
        }
    }
    return self;
}

//=========================================================================================
- (void)configureLightForDocument:(DIYBDocument*)document
{
    if (_sequenceItem)
    {
        DIYBSequenceItem* item=[document itemForName:_sequenceItem];
        if (item)
        {
            DIYBLightGroup* group=[[DIYBLightStorage sharedInstance] groupForName:item.source];
            if (group && _lightSource)
            {
                _light=[group lightForName:_lightSource];
            }
        }
    }

}
//====================================================================================
- (void)setCommonItems:(NSXMLElement*)element
{
    NSXMLNode* node=[element attributeForName:@"origin"];
    if (node)
    {
        _origin=[self pointForString:[node stringValue]];
    }
    else
        _origin=NSMakePoint(0.0, 0.0);
    node=[element attributeForName:@"fill"];
    _isFill=NO;
    if (node)
    {
        if ([[node stringValue] isEqualToString:@"yes"])
        {
            _isFill=YES;
        }
    }
    
    node=[element attributeForName:@"lineWidth"];
    if (node)
    {
        _lineWidth=[[node stringValue] doubleValue];

    }
    else
        _lineWidth=2.0;
    
    node=[element attributeForName:@"color"];
    if (node)
    {
        _color=[[DIYBColor alloc] initWithString:[node stringValue]] ;
    }
    else
        _color=[[DIYBColor alloc] initWithEightRed:255 eightGreen:255 eightBlue:255];

    node=[element attributeForName:@"sequenceItem"];
    if (node)
    {
        _sequenceItem=[[node stringValue] copy];
        node=[element attributeForName:@"light"];
        if (node)
        {
            
            _lightSource=[[node stringValue] copy];
        }
    }

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

//==================================================================================
- (void)buildOval:(NSXMLElement *)element
{
    NSXMLNode* node;
    NSPoint point=NSMakePoint(5.0, 5.0);
    NSBezierPath * path=[NSBezierPath bezierPath];

    node=[element attributeForName:@"size"];
    if (node)
    {
       point=[self pointForString:[node stringValue]];
    }
    path=[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(_origin.x, _origin.y, point.x, point.y)];
    [path setLineWidth:_lineWidth];
    _path=path;
    [self setLineDash:element];

}
//==================================================================================
- (void)buildLine:(NSXMLElement*)element
{
    NSBezierPath * path=[NSBezierPath bezierPath];
    [path moveToPoint:_origin];
    NSArray* array=[element elementsForName:@"loc"];
    for (NSXMLElement* child in array)
    {
        NSPoint point=[self pointforLocation:child];
        [path lineToPoint:point] ;
        
    }
    
    [path setLineWidth:_lineWidth];
    _path=path;
    [self setLineDash:element];
    
}

//==================================================================================
- (NSPoint)pointforLocation:(NSXMLElement*)element
{
    NSXMLNode* node=[element attributeForName:@"origin"];
    NSPoint point=NSMakePoint(0.0, 0.0);
    if (node)
    {
        point=[self pointForString:[node stringValue]];
    }
    return point;
}
//==================================================================================
- (void)setLineDash:(NSXMLElement*)element
{
    NSXMLNode* node=[element attributeForName:@"pattern"];
    if (node)
    {
        NSString* patstring=[node stringValue];
        node=[element attributeForName:@"phase"];
        CGFloat phase=0.0;
        if (node)
        {
            phase=[[node stringValue] doubleValue];
        }
        [self setLineDash:patstring phase:phase];
    }
  
}
//==================================================================================
- (void)setLineDash:(NSString*)dash phase:(CGFloat)phase
{
    NSArray* array=[dash componentsSeparatedByString:@","];
    NSInteger i;
    if (array.count>0)
    {
        CGFloat* pointer=malloc(sizeof(CGFloat)*array.count);
        for(i=0;i<array.count;i++)
        {
            pointer[i]=[[array objectAtIndex:i] doubleValue];
        }
        [_path setLineDash:pointer count:array.count phase:phase];
        free(pointer);
        pointer=NULL;
    }
}
//==================================================================================
- (void)drawData:(NSData *)data offset:(NSInteger)frameOffset
{
    if ((_offset >=0) && _light)
    {
        DIYBColor* color=[_light colorForData:([data bytes]+frameOffset+_offset+_light.channelOffset)];
        if (_light.channelCount<3)
        {
            color=[_color setIntensity:color.redComponent];
        }
        if (![color isBlack] && color)
        {
            if ([self isFill])
            {
               [[color color] setFill];
                [_path fill];
            }
            else
            {
                [[color color] setStroke];
                [_path stroke];
            }
            
        }
    }
}
@end
