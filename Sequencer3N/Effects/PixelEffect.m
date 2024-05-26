//
//  PixelEffect.m
//  Sequencer2
//
//  Created by charles on 8/16/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "PixelEffect.h"
#import "DIYBColor.h"

const NSString* AddEffect=@"add";
const NSString* BlendEffect=@"blend";
const NSString* ColorEffect=@"color";
const NSString* DiminishEffect=@"diminish";
const NSString* PatternEffect=@"pattern";
const NSString* RandomEffect=@"random";
const NSString* ShimmerEffect=@"shimmer";
const NSString* SparkleEffect=@"sparkle";
const NSString* TwinkleEffect=@"twinkle";

@implementation PixelEffect

+ (NSArray*)allEffects
{
    return [NSArray arrayWithObjects:AddEffect,BlendEffect,ColorEffect,DiminishEffect,PatternEffect,RandomEffect,ShimmerEffect,SparkleEffect,TwinkleEffect, nil];
}
//====================================================================================================
+ (BOOL)validEffect:(NSString *)effect
{
    BOOL rvalue=NO;
    if ([effect isEqualToString:(NSString*)AddEffect] ||[effect isEqualToString:(NSString*)BlendEffect] || [effect isEqualToString:(NSString*)ColorEffect] || [effect isEqualToString:(NSString*)RandomEffect] ||[effect isEqualToString:(NSString*)ShimmerEffect] ||[effect isEqualToString:(NSString*)SparkleEffect] ||[effect isEqualToString:(NSString*)TwinkleEffect] ||[effect isEqualToString:(NSString*)DiminishEffect]  )
    {
        rvalue=YES;
    }
    return rvalue;
}

//====================================================================================================
+ (NSArray*)applyEffect:(NSString*)effect colors:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{

    NSArray* rvalue=nil;
    if ([effect isEqualToString:(NSString*)AddEffect])
    {
        rvalue=[PixelEffect applyAdd:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else if ([effect isEqualToString:(NSString*)BlendEffect])
    {
        rvalue=[PixelEffect applyBlend:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else if ([effect isEqualToString:(NSString*)ColorEffect])
    {
        rvalue=[PixelEffect applyColor:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else if ([effect isEqualToString:(NSString*)RandomEffect])
    {
        rvalue=[PixelEffect applyRandom:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else if ([effect isEqualToString:(NSString*)ShimmerEffect])
    {
        rvalue=[PixelEffect applyShimmer:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else if ([effect isEqualToString:(NSString*)SparkleEffect])
    {
        rvalue=[PixelEffect applySparkle:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else if ([effect isEqualToString:(NSString*)TwinkleEffect])
    {
        rvalue=[PixelEffect applyTwinkle:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else if ([effect isEqualToString:(NSString*)DiminishEffect])
    {
        rvalue=[PixelEffect applyDiminish:colors startColor:startColor endColor:endColor maskColor:maskColor];
    }
    else
    {
        NSException* exception=[NSException exceptionWithName:@"InvalidEffect" reason:[NSString stringWithFormat:@"Invalid Effect type: %@",effect] userInfo:nil];
        @throw exception;
    }
    return rvalue;
}
//====================================================================================================
+ (NSArray*)applyShimmer:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSInteger count=0;
    DIYBColor* black=[[DIYBColor alloc] initWithEightRed:0 eightGreen:0 eightBlue:0];
    BOOL blank=NO;
    NSMutableArray* newcolors=[NSMutableArray arrayWithCapacity:colors.count];
    for (count=0;count < colors.count;count++)
    {
        DIYBColor* oldcolor=[colors objectAtIndex:count];
        if (blank)
        {
            [newcolors addObject:[black mutableCopy]];
            blank=NO;
        }
        else
        {
            [newcolors addObject:oldcolor];
            blank=YES;
        }
        
    }
    return newcolors;
    
}
//====================================================================================================
+ (NSArray*)applyDiminish:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSInteger count=0;
    NSMutableArray* newcolors=[NSMutableArray arrayWithCapacity:colors.count];
    CGFloat startIntensity=[startColor redComponent];
    CGFloat endIntensity=[endColor redComponent];
    
    CGFloat step=(endIntensity-startIntensity)/[colors count];
    CGFloat intensity=startIntensity;
    for (count=0;count < colors.count;count++)
    {
        DIYBColor* oldcolor=[colors objectAtIndex:count];
        [newcolors addObject:[oldcolor setIntensity:intensity]];
        intensity+=step;
    }
    return newcolors;
    
}

//====================================================================================================
+ (NSArray*)applySparkle:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSInteger count=0;
    NSMutableArray* newcolors=[NSMutableArray arrayWithCapacity:colors.count];
    NSInteger normalTime= [startColor eightRed]/25;
    NSInteger holdTime=[endColor eightRed]/25;
    NSInteger shouldHoldCount=arc4random_uniform(5)+holdTime;;
    NSInteger shouldKeepCount=arc4random_uniform(5)+normalTime;
    BOOL shouldSparkle=arc4random_uniform(2);
    for (count=0;count < colors.count;count++)
    {
        DIYBColor* oldcolor=[colors objectAtIndex:count];
        if(shouldSparkle)
        {
            [newcolors addObject:[oldcolor maxIntensity]];
            shouldHoldCount--;
            if (shouldHoldCount<0)
            {
                shouldSparkle=NO;
                shouldKeepCount=arc4random_uniform(5)+normalTime;
            }
            
        }
        else
        {
            [newcolors addObject:oldcolor];
            shouldKeepCount--;
            if (shouldKeepCount<0)
            {
                shouldSparkle=YES;
                shouldHoldCount=arc4random_uniform(5)+holdTime;
            }
        }
    }
    return newcolors;
    
}
//====================================================================================================
+ (NSArray*)applyTwinkle:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSInteger count=0;
    NSMutableArray* newcolors=[NSMutableArray arrayWithCapacity:colors.count];
    NSInteger normalTime= [startColor eightRed]/25;
    NSInteger holdTime=[endColor eightRed]/25;
    NSInteger shouldHoldCount=arc4random_uniform(5)+holdTime;;
    NSInteger shouldKeepCount=arc4random_uniform(5)+normalTime;
    BOOL shouldSparkle=arc4random_uniform(2);
    for (count=0;count < colors.count;count++)
    {

        DIYBColor* oldcolor=[colors objectAtIndex:count];
        if(shouldSparkle)
        {
            [newcolors addObject:[oldcolor setIntensity:0.0]];
            shouldHoldCount--;
            if (shouldHoldCount<0)
            {
                shouldSparkle=NO;
                shouldKeepCount=arc4random_uniform(5)+normalTime;
            }
            
        }
        else
        {
            [newcolors addObject:oldcolor];
            shouldKeepCount--;
            if (shouldKeepCount<0)
            {
                shouldSparkle=YES;
                shouldHoldCount=arc4random_uniform(5)+holdTime;
            }
        }
    }
    return newcolors;
    
}
//====================================================================================================
+ (NSArray*)applyRandom:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSInteger count=0;
    NSMutableArray* newcolors=[NSMutableArray arrayWithCapacity:colors.count];
    NSInteger holdTime=[endColor eightRed]/25;
    NSInteger shouldHoldCount=arc4random_uniform(5)+holdTime;;
    DIYBColor* randomColor=nil;
    for (count=0;count < colors.count;count++)
    {

        DIYBColor* oldcolor=[colors objectAtIndex:count];
            if (!randomColor)
            {
                randomColor=[oldcolor randomColor];
            }
            [newcolors addObject:randomColor];
            shouldHoldCount--;
            if (shouldHoldCount<0)
            {
                shouldHoldCount=arc4random_uniform(5)+holdTime;
                randomColor=nil;
            }
    }
    return newcolors;
    
}

//====================================================================================================
+ (NSArray*)applyBlend:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSMutableArray* newData=[NSMutableArray arrayWithCapacity:colors.count];
    NSArray * newColors=[DIYBColor colorsFor:startColor endColor:endColor count:colors.count];
    NSInteger count=0;
    for (count=0;count < colors.count;count++)
    {

        DIYBColor* oldcolor=[colors objectAtIndex:count];
        DIYBColor* newcolor=oldcolor;
        if (count < [newColors count])
        {
 
            newcolor=[newColors objectAtIndex:count];
        }
        [newData addObject:[oldcolor addColor:newcolor fraction:maskColor.redComponent]];

    }
    return newData;
    
    
}
//====================================================================================================
+ (NSArray*)applyAdd:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSMutableArray* newData=[NSMutableArray arrayWithCapacity:colors.count];
    NSArray * newColors=[DIYBColor colorsFor:startColor endColor:endColor count:colors.count];
    NSInteger count=0;
    for (count=0;count < colors.count;count++)
    {
        
        DIYBColor* oldcolor=[colors objectAtIndex:count];
        DIYBColor* newcolor=oldcolor;
        if (count < [newColors count])
        {
            
            newcolor=[newColors objectAtIndex:count];
        }
        [newData addObject:[oldcolor addColor:newcolor]];
        
    }
    return newData;
    
    
}

//====================================================================================================
+ (NSArray*)applyColor:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor
{
    NSMutableArray* newData=[NSMutableArray arrayWithCapacity:colors.count];
    NSArray * newColors=[DIYBColor colorsFor:startColor endColor:endColor count:colors.count];
    NSInteger count=0;
    for (count=0;count < colors.count;count++)
    {

        DIYBColor* oldcolor=[colors objectAtIndex:count];
        DIYBColor* newcolor=oldcolor;
        if (count < [newColors count])
        {
            
            newcolor=[newColors objectAtIndex:count];
        }
        [newData addObject:newcolor];
        
    }
    return newData;
    
    
}



@end
