//
//  DIYBLightSource.m
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBLightSource.h"
#import "DIYBColor.h"
@implementation DIYBLightSource

//================================================================================
+ (BOOL)isValidLightSource:(NSXMLElement*)element
{
    BOOL rvalue=NO;
    if (element && ([element.name isEqualToString:@"lightSource"] || [element.name isEqualToString:@"pixelBase"]))
    {
        NSXMLNode* node=[element attributeForName:@"type"];
        if (node)
        {
            if ([[node stringValue] isEqualToString:@"intensity"] || [[node stringValue] isEqualToString:@"strobe"] || [[node stringValue] isEqualToString:@"rgb"] || [[node stringValue] isEqualToString:@"rbg"] || [[node stringValue] isEqualToString:@"bgr"] || [[node stringValue] isEqualToString:@"brg"] || [[node stringValue] isEqualToString:@"gbr"] || [[node stringValue] isEqualToString:@"grb"])
            {
                rvalue=YES;
            }
        }
        else
            rvalue=YES;
    }
    return rvalue;
}

//================================================================================
- (id)initWithElement:(NSXMLElement *)element order:(NSInteger)order offset:(NSInteger)offset
{
    self=[super init];
    if (self)
    {
        _channelOffset=offset;
        NSXMLNode* node=[element attributeForName:@"name"];
        if (node)
        {
            _name=[[node stringValue] copy];
        }
        node=[element attributeForName:@"origin"];
        _origin=NSMakePoint(0.0, 0.0);
        if (node)
        {
            NSArray* array=[[node stringValue] componentsSeparatedByString:@","];
            if (array.count==2)
            {
                _origin=NSMakePoint([[array objectAtIndex:0] doubleValue], [[array objectAtIndex:1] doubleValue]);
            }
        }
        _order=order;

        _type=@"rgb";
        node=[element attributeForName:@"type"];
        if (node)
        {
            _type=[[node stringValue] copy];
        }
    }
    return self;
}
//==================================================================
- (NSComparisonResult)applyOrder:(DIYBLightSource*)light
{
    NSComparisonResult result=NSOrderedSame;
    if (_order>light.order)
    {
        result=NSOrderedDescending;
    }
    else if (_order<light.order)
    {
        result=NSOrderedAscending;
    }
    return result;
}
//===================================================================
- (NSInteger)channelCount
{
    NSString * type=[self type];
    if ([type isEqualToString:@"strobe"] || [type isEqualToString:@"intensity"])
    {
        return 1;
    }
    else
    {
        return 3;
    }
}

//===================================================================
- (void)applyColor:(DIYBColor*)color location:(unsigned char*)data
{
    if (color )
    {
        if ([self.type isEqualToString:@"intensity"])
        {
            *data=color.eightRed;
        }
        else if ([self.type isEqualToString:@"strobe"])
        {
            *data=0;
            if (color.eightRed >0)
            {
                *data=255;
            }
        }
        else if ([self.type isEqualToString:@"rgb"])
        {
            data[0]=color.eightRed;
            data[1]=color.eightGreen;
            data[2]=color.eightBlue;
        }
        else if ([self.type isEqualToString:@"rbg"])
        {
            data[0]=color.eightRed;
            data[2]=color.eightGreen;
            data[1]=color.eightBlue;
        }
        else if ([self.type isEqualToString:@"bgr"])
        {
            data[2]=color.eightRed;
            data[1]=color.eightGreen;
            data[0]=color.eightBlue;
        }
        else if ([self.type isEqualToString:@"brg"])
        {
            data[1]=color.eightRed;
            data[2]=color.eightGreen;
            data[0]=color.eightBlue;
        }
        else if ([self.type isEqualToString:@"gbr"])
        {
            data[2]=color.eightRed;
            data[0]=color.eightGreen;
            data[1]=color.eightBlue;
        }
        else if ([self.type isEqualToString:@"grb"])
        {
            data[1]=color.eightRed;
            data[0]=color.eightGreen;
            data[2]=color.eightBlue;
        }
        else
        {
            NSException* exception=[NSException exceptionWithName:@"InvalidLightType" reason:[NSString stringWithFormat:@"LightSource was of type %@",self.type] userInfo:nil];
            @throw exception;
        }
        
    }
    
}

//====================================================================
- (DIYBColor*)colorForData:(const char*)data
{
    DIYBColor* rvalue=nil;
    if ([self.type isEqualToString:@"intensity"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*data eightGreen:*data eightBlue:*data];
    }
    else if ([self.type isEqualToString:@"strobe"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*data eightGreen:*data eightBlue:*data];
        if (rvalue.eightRed>0)
        {
            rvalue.eightRed=255;
        }
    }
    else if ([self.type isEqualToString:@"rgb"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*data eightGreen:*(data+1) eightBlue:*(data+2)];
    }
    else if ([self.type isEqualToString:@"rbg"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*data eightGreen:*(data+2) eightBlue:*(data+1)];
    }
    else if ([self.type isEqualToString:@"bgr"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*(data+2) eightGreen:*(data+1) eightBlue:*(data)];
    }
    else if ([self.type isEqualToString:@"brg"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*(data+1) eightGreen:*(data+2) eightBlue:*(data)];
    }
    else if ([self.type isEqualToString:@"gbr"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*(data+2) eightGreen:*(data) eightBlue:*(data+1)];
    }
    else if ([self.type isEqualToString:@"grb"])
    {
        rvalue=[[DIYBColor alloc] initWithEightRed:*(data+1) eightGreen:*(data) eightBlue:*(data+2)];
    }
    
    return rvalue;
}


@end
