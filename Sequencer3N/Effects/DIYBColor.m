//
//  DIYBColor.m
//  Sequencer2
//
//  Created by charles on 8/16/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBColor.h"

@interface DIYBColor()
- (CGFloat)currentIntensity;
@end

@implementation DIYBColor
@synthesize eightBlue=_eightBlue;
@synthesize eightGreen=_eightGreen;
@synthesize eightRed=_eightRed;
@synthesize isIntensity=_isIntensity;

//=================================================================================
//                              Class Methods
//=================================================================================
+ (DIYBColor*)blackColor
{
    return [[DIYBColor alloc] initWithRed:0.0 green:0.0 blue:0.0];
}
//=================================================================================
+ (DIYBColor*)blackIntensity
{
    return [[DIYBColor alloc] initWithIntensity:0.0];
}

//===================================================
+ (DIYBColor*)colorForPoint:(NSPoint)origin image:(NSBitmapImageRep*)rep
{
//    NSSize size=[rep size];
    DIYBColor* rvalue=[DIYBColor blackColor];
    NSInteger x=origin.x;
    NSInteger y=origin.y;
    NSInteger width=[rep pixelsWide];
    NSInteger height=[rep pixelsHigh];
    if ((width>x) && (height>y))
    {
        NSColor* color=[rep colorAtX:x y:y];
        if (color)
        {
            rvalue=[[DIYBColor alloc] initWithNSColor:color];
        }
    }
    return rvalue;
}
//====================================================
+ (NSArray*)colorsForStartMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli frameRate:(CGFloat)frameRate startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor
{
    NSInteger rate=frameRate*10000;
    rate=rate/10;
    NSInteger delta=(endMilli+rate-1)-startMilli;
    NSInteger count=delta/rate + 1;
    
    return [DIYBColor colorsFor:startColor endColor:endColor count:count];
}
//====================================================
+ (NSArray*)colorsFor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor count:(NSInteger)count
{
    NSMutableArray* array=[NSMutableArray arrayWithCapacity:count];
    if (count>1)
    {
        CGFloat redDelta=(endColor.redComponent-startColor.redComponent)/(count-1);
        CGFloat greenDelta=(endColor.greenComponent-startColor.greenComponent)/(count-1);
        CGFloat blueDelta=(endColor.blueComponent-startColor.blueComponent)/(count-1);
        NSUInteger i;
        for (i=0;i<count;i++)
        {
            DIYBColor * color=[startColor mutableCopy];
            color.redComponent=color.redComponent+i*redDelta;
            color.greenComponent=color.greenComponent+i*greenDelta;
            color.blueComponent=color.blueComponent+i*blueDelta;
            [array addObject:color];
        }
    }
    else
    {
        [array addObject:[startColor mutableCopy]];
    }
    return array;
}

//=================================================================================
//                              Instance Methods
//==================================================================================
//===================================================
- (id)initWithEightRed:(unsigned char)red eightGreen:(unsigned char)green eightBlue:(unsigned char)blue
{
    self=[super init];
    if (self)
    {
        _eightRed=red;
        _eightGreen=green;
        _eightBlue=blue;
        _isIntensity=NO;
    }
    return self;
}
//====================================================
- (id)init
{
    return [self initWithEightRed:0 eightGreen:0 eightBlue:0];
}
//====================================================
- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [self initWithEightRed:red*255.0 eightGreen:green*255.0 eightBlue:blue*255.0];
}
//======================================================
- (id)initWithIntensity:(CGFloat)intensity
{
    self=[self initWithEightRed:intensity*255.0 eightGreen:0 eightBlue:0];
    if (self)
    {
        _isIntensity=YES;
    }
    return self;
}
//========================================================
- (id)initWithEightIntensity:(unsigned char)intensity
{
    self=[self initWithEightRed:intensity eightGreen:0 eightBlue:0];
    if (self)
    {
        _isIntensity=YES;
    }
    return self;
}
//========================================================
- (id)initWithString:(NSString *)colorstring
{
    self=[self initWithEightRed:0 eightGreen:0 eightBlue:0];
    if (self)
    {
        NSArray* array=[colorstring componentsSeparatedByString:@","];
        if (array.count >0)
        {
            _eightRed=[[array objectAtIndex:0] doubleValue] * 255;
            _isIntensity=YES;
        }
        else
        {
            self =nil;
            NSException *exception = [NSException exceptionWithName:@"Invalid Color String" reason:[NSString stringWithFormat:@"String:'%@' is an invalid color format", colorstring] userInfo:nil];

            @throw exception;
        }
        if (array.count>1 )
        {
            _eightGreen=[[array objectAtIndex:1] doubleValue] * 255;
            _isIntensity=NO;
        }
        if (array.count>2)
        {
            _eightBlue=[[array objectAtIndex:2] doubleValue] * 255;
            _isIntensity=NO;
        }
    }
    return self;
}
//========================================================
- (id)initWithNSColor:(NSColor *)color
{
    self=[self initWithEightRed:0 eightGreen:0 eightBlue:0];
    if (self)
    {
        NSString* space = color.colorSpace.localizedName ;
        if (  [space isEqualToString:NSDeviceWhiteColorSpace] || [space isEqualToString: NSCalibratedWhiteColorSpace] )  {
            _isIntensity = YES ;
            _eightRed = [color whiteComponent] * 256 ;
        }
        else if ( [space isEqualToString:NSDeviceRGBColorSpace] || [space isEqualToString: NSCalibratedRGBColorSpace] ) {
            _isIntensity = NO ;
            _eightGreen=[color greenComponent]*255;
            _eightBlue=[color blueComponent]*255;
            _isIntensity=NO;

        }
        else {
            color=[color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
            _eightRed=[color redComponent]*255;
            _eightGreen=[color greenComponent]*255;
            _eightBlue=[color blueComponent]*255;
            _isIntensity=NO;
        }
        /*
        NSString* space=[color colorSpaceName];
        if ( ([space isEqualToString:NSDeviceWhiteColorSpace] || [space isEqualToString:NSCalibratedWhiteColorSpace]) )
        {
            _isIntensity=YES;
            _eightRed=[color whiteComponent]*255;
        }
        else if ([space isEqualToString:NSDeviceRGBColorSpace] || [space isEqualToString:NSCalibratedRGBColorSpace])
        {
            _eightRed=[color redComponent]*255;
            _eightGreen=[color greenComponent]*255;
            _eightBlue=[color blueComponent]*255;
            _isIntensity=NO;
        }
        else
        {
            color=[color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
            _eightRed=[color redComponent]*255;
            _eightGreen=[color greenComponent]*255;
            _eightBlue=[color blueComponent]*255;
            _isIntensity=NO;
        }
         */
        
    }
    return self;
}

//======================================================
- (id)initWithColor:(DIYBColor *)color
{
    self=[self initWithEightRed:0 eightGreen:0 eightBlue:0];
    if (self)
    {
        _eightBlue=color.eightBlue;
        _eightRed=color.eightRed;
        _eightGreen=color.eightGreen;
        _isIntensity=color.isIntensity;
    }
    return self;
}

//======================================================
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[DIYBColor alloc] initWithColor:self];
}
//======================================================
- (NSColor*)color
{
    NSColor* rvalue;
    if (_isIntensity)
    {
        rvalue=[NSColor colorWithDeviceWhite:_eightRed/255.0 alpha:1.0];
    }
    else
    {
        rvalue=[NSColor colorWithDeviceRed:_eightRed/255.0 green:_eightGreen/255.0 blue:_eightBlue/255.0 alpha:1.0];
    }
    return rvalue;
}
//======================================================
- (NSColor*)colorForComponent:(NSInteger)component
{
    NSColor* color;
    if (component==0)
    {
        color=[NSColor colorWithDeviceRed:_eightRed/255.0 green:0.0 blue:0.0 alpha:1.0];
    }
    else if (component==1)
    {
        color=[NSColor colorWithDeviceRed:0.0 green:_eightRed/255.0 blue:0.0 alpha:1.0];
        
    }
    else if (component==2)
    {
        color=[NSColor colorWithDeviceRed:0.0 green:0.0 blue:_eightRed/255.0 alpha:1.0];
        
    }
    else
    {
        color=[NSColor colorWithDeviceRed:_eightRed/255.0 green:_eightRed/255.0 blue:_eightRed/255.0 alpha:1.0];
        
    }
    return color;
}
//======================================================
- (void)setRedComponent:(CGFloat)red
{
    _eightRed=red*255.0;
}
//======================================================
- (CGFloat)redComponent
{
    return _eightRed/255.0;
}
//======================================================
- (void)setGreenComponent:(CGFloat)green
{
    _eightGreen=green*255.0;
}
//======================================================
- (CGFloat)greenComponent
{
    return _eightGreen/255.0;
}
//======================================================
- (void)setBlueComponent:(CGFloat)blue
{
    _eightBlue=blue*255.0;
}
//======================================================
- (CGFloat)blueComponent
{
    return _eightBlue/255.0;
}
//======================================================
- (NSString*)colorString
{
    return [NSString stringWithFormat:@"%.4f,%.4f,%.4f",self.redComponent,self.greenComponent,self.blueComponent];
}
//======================================================
- (NSString*)description
{
    return [self colorString];
}
//======================================================
- (BOOL)isBlack
{
    if (_isIntensity)
    {
        if (_eightRed==0)
        {
            return YES;
        }
        else
            return NO;
    }
    else
    {
        if ((_eightRed==0) && (_eightBlue==0) && (_eightGreen==0))
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
}

//======================================================
- (DIYBColor*)maxIntensity
{
    CGFloat percent=0;
    
    CGFloat maxIntensity=[self currentIntensity];
    if (maxIntensity!=0)
    {
        percent=1.0/maxIntensity;
        
    }
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    red=self.redComponent*percent;
    green=self.greenComponent*percent;
    blue=self.blueComponent*percent;
    DIYBColor* rvalue=[self mutableCopy];
    rvalue.redComponent=red;
    rvalue.greenComponent=green;
    rvalue.blueComponent=blue;
    return rvalue;
}

//======================================================
- (DIYBColor*)setIntensity:(CGFloat)intensity
{
    
    CGFloat current=[self currentIntensity];
    if (current!=0)
    {
        CGFloat maxIntensity=1.0/[self currentIntensity];
        if (intensity>maxIntensity)
        {
            intensity=maxIntensity;
        }
    }
    DIYBColor* rvalue=[self mutableCopy];
    rvalue.redComponent=self.redComponent*intensity;
    rvalue.greenComponent=self.greenComponent*intensity;
    rvalue.blueComponent=self.blueComponent*intensity;
    
    /*
    DIYBColor* rvalue=[self mutableCopy];

    rvalue.redComponent=rvalue.redComponent*intensity;
    rvalue.blueComponent=rvalue.blueComponent*intensity;
    rvalue.greenComponent=rvalue.greenComponent*intensity;
*/
    return rvalue;
}

//==============================================================
- (DIYBColor*)addColor:(DIYBColor*)newcolor fraction:(CGFloat)fraction
{
    NSColor* oldColor=[self color];
    NSColor* blendColor=[newcolor color];
    oldColor=[oldColor blendedColorWithFraction:fraction ofColor:blendColor];
    
    return [[DIYBColor alloc] initWithNSColor:oldColor];
}
//==============================================================
- (DIYBColor*)addColor:(DIYBColor*)newcolor
{
    DIYBColor* color=[self mutableCopy];
    NSInteger red=color.eightRed+newcolor.eightRed;
    if (red>0XFF)
    {
        red=0xFF;
    }
    NSInteger green=color.eightGreen+newcolor.eightGreen;
    if (green>0XFF)
    {
        green=0xFF;
    }
    NSInteger blue=color.eightBlue+newcolor.eightBlue;
    if (blue>0XFF)
    {
        blue=0xFF;
    }
    [color setEightRed:red];
    [color setEightGreen:green];
    [color setEightBlue:blue];
    
    return color;
}


//========================================================================
- (DIYBColor*)randomColor
{
    NSInteger components=arc4random_uniform(7);
    CGFloat red=0.0;
    CGFloat green=0.0;
    CGFloat blue=0.0;
    switch (components) {
        case 0:
            red=1.0;
            green=1.0;
            blue=1.0;
            break;
        case 1:
            red=0.0;
            green=1.0;
            blue=1.0;
            break;
        case 3:
            red=1.0;
            green=0.0;
            blue=1.0;
            break;
        case 5:
            red=1.0;
            green=1.0;
            blue=0.0;
            break;
        case 2:
            red=0.0;
            green=0.0;
            blue=1.0;
            break;
        case 4:
            red=1.0;
            green=0.0;
            blue=0.0;
            break;
        case 6:
            red=0.0;
            green=1.0;
            blue=0.0;
            break;
            
        default:
            red=0.0;
            green=0.0;
            blue=0.0;
            
            break;
    }
    return [[DIYBColor alloc] initWithRed:self.redComponent*red green:self.greenComponent*green blue:self.blueComponent*blue];
    
}


//==============================================================================
//                  Private Methods
//==============================================================================
//===========================================
- (CGFloat)currentIntensity
{
    CGFloat maxIntensity=self.redComponent;
    if (self.greenComponent>maxIntensity)
    {
        maxIntensity=self.greenComponent;
    }
    if (self.blueComponent>maxIntensity)
    {
        maxIntensity=self.blueComponent;
    }
    return maxIntensity;
}
@end
