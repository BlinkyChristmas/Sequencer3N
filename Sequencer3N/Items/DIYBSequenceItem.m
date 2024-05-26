//
//  DIYBSequenceItem.m
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBSequenceItem.h"
#import "DIYBEffectItem.h"
#import "DIYBLightStorage.h"
#import "DIYBLightGroup.h"
#import "DIYBColor.h"
#import "DIYBLightSource.h"
#import "DIYBPrefData.h"
#import "DIYBTransition.h"
#import "DIYBImageCache.h"
#import "PixelEffect.h"
#import "DIYBTimeEntry.h"
#import "DIYBGrid.h"

@implementation DIYBSequenceItem

//================================================================================
+ (BOOL)supportsSecureCoding
{
    return YES;
}
//================================================================================
- (id)init
{
    self=[super init];
    if (self)
    {
        _element=[NSXMLElement elementWithName:@"sequenceItem"];
        _effects=[NSMutableSet setWithCapacity:100];
    }
    return self;
}
//================================================================================
- (id)initWithElement:(NSXMLElement*)element
{
    self=[self init];
    if (self)
    {
        _element=element;
        NSArray* array=[element elementsForName:@"effect"];
        for (NSXMLElement* child in array)
        {
            DIYBEffectItem* item=[[DIYBEffectItem alloc] initWithElement:child];
            [_effects addObject:item];
        }
    }
    return self;
}
//================================================================================
- (id)initWithItem:(DIYBSequenceItem *)item
{
    self=[self init];
    if (self)
    {
        self.name=item.name;
        self.source=item.source;
        NSEnumerator *enumerator = [item.effects objectEnumerator];
        DIYBEffectItem* item=nil;
        while ((item=[enumerator nextObject]))
        {
            DIYBEffectItem* duplicate=[item mutableCopy];
            [_element addChild:duplicate.element];
            [_effects addObject:duplicate];
        }
        
    }
    return self;
}
//================================================================================
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self =[self init];
    if (self)
    {
        self.name=[aDecoder decodeObjectOfClass:[NSString class] forKey:@"NAME"];
        self.source=[aDecoder decodeObjectOfClass:[NSString class] forKey:@"SOURCE"];
        
    }
    return self;
}
//================================================================================
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"NAME"];
    [aCoder encodeObject:self.source forKey:@"SOURCE"];
    NSEnumerator *enumerator = [self.effects objectEnumerator];
    DIYBEffectItem* item=nil;
    while ((item=[enumerator nextObject]))
    {
        [item encodeWithCoder:aCoder];
    }
    
}
//================================================================================
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[DIYBSequenceItem alloc] initWithItem:self];
}
//================================================================================
- (NSString*)name
{
    NSXMLNode* node=nil;
    NSString* rvalue=nil;
    node=[_element attributeForName:@"name"];
    if (node)
    {
        rvalue=[[node stringValue] copy];
    }
    return rvalue;
}
//================================================================================
- (void)setName:(NSString *)name
{
    NSXMLNode* node=[_element attributeForName:@"name"];
    if (node)
    {
        [node setStringValue:name];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"name" stringValue:name];
        [_element addAttribute:node];
    }
}
//================================================================================
- (NSString*)source
{
    NSXMLNode* node=nil;
    NSString* rvalue=nil;
    node=[_element attributeForName:@"source"];
    if (node)
    {
        rvalue=[[node stringValue] copy];
    }
    return rvalue;
    
}
//================================================================================
- (void)setSource:(NSString *)source
{
    NSXMLNode* node=[_element attributeForName:@"source"];
    if (node)
    {
        [node setStringValue:source];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"source" stringValue:source];
        [_element addAttribute:node];
    }
   
}
//================================================================================
- (NSInteger)endMilli
{
    NSSortDescriptor* sort=[NSSortDescriptor sortDescriptorWithKey:@"endMilli" ascending:YES];
    NSArray* array=[_effects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    return [array.lastObject endMilli];
}
//================================================================================
- (NSInteger)startMilli
{
    NSSortDescriptor* sort=[NSSortDescriptor sortDescriptorWithKey:@"startMilli" ascending:YES];
    NSArray* array=[_effects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    return [array.firstObject startMilli];
}
//===================================================================================
- (void)addEffect:(DIYBEffectItem*)effect
{
    [[effect element] detach];
    [_element addChild:effect.element];
    [self willChangeValueForKey:@"startMilli"];
    [self willChangeValueForKey:@"endMilli"];
    [_effects addObject:effect];
    [self didChangeValueForKey:@"startMilli"];
    [self didChangeValueForKey:@"endMilli"];
}

//===================================================================================
- (void)removeEffect:(DIYBEffectItem *)effect
{
    [self willChangeValueForKey:@"startMilli"];
    [self willChangeValueForKey:@"endMilli"];

    [_effects removeObject:effect];
    [effect.element detach];
    
    [self didChangeValueForKey:@"startMilli"];
    [self didChangeValueForKey:@"endMilli"];
}

//===================================================================================
- (NSInteger)length
{
    return [[self lightGroup] channelCount];
}
//===================================================================================
- (DIYBLightGroup*)lightGroup
{
    return [[DIYBLightStorage sharedInstance] groupForName:self.source];
}
//====================================================================================
- (NSInteger)frameCountForStartMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli rate:(NSInteger)rate
{
    NSInteger startindex=[self frameIndexForMilli:startMilli rate:rate];
    NSInteger endindex=[self frameIndexForMilli:endMilli rate:rate];
    return (endindex-startindex);
//    return ((endMilli-startMilli)+(rate-1))/rate;
}
//====================================================================================
- (NSInteger)frameIndexForMilli:(NSInteger)milli rate:(NSInteger)rate
{
    return (milli)/rate;
}
//====================================================================================
/*
- (NSArray*)colorsForStartColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor startMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli rate:(NSInteger)rate
{
    NSLog(@"startMilli %ld end %ld",startMilli,endMilli);
    NSInteger frameCount=[self frameCountForStartMilli:startMilli endMilli:endMilli rate:rate];
    if ((endMilli==9470) || startMilli==9470) {
        NSLog(@"start %ld end %ld index %ld count %ld",startMilli,endMilli,[self frameIndexForMilli:startMilli rate:rate],frameCount);
    }
    CGFloat redSlope=(endColor.redComponent-startColor.redComponent)/frameCount;
    CGFloat greenSlope=(endColor.greenComponent-startColor.greenComponent)/frameCount;
    CGFloat blueSlope=(endColor.blueComponent-startColor.blueComponent)/frameCount;
    NSInteger i=0;
    NSMutableArray* array=nil;
    if (frameCount>0)
    {
        array=[NSMutableArray arrayWithCapacity:frameCount];
        for(i=0;i<frameCount;i++)
        {
            [ array addObject:[[DIYBColor alloc] initWithRed:startColor.redComponent+i*redSlope green:startColor.greenComponent+i*greenSlope blue:startColor.blueComponent+i*blueSlope]];
        }
        
    }
    return array;
}
 */
//======================================================================================================
- (void)applyColors:(NSArray*)colors data:(NSMutableData*)data frameLength:(NSInteger)frameLength rate:(NSInteger)rate source:(DIYBLightSource*)source startMilli:(NSInteger)startMilli offset:(NSInteger)offset
{
    unsigned char* bytes=[data mutableBytes];
    NSInteger frameIndex=[self frameIndexForMilli:startMilli rate:rate];
    for (DIYBColor* color in colors)
    {
        [source applyColor:color location:bytes+offset+(frameLength*frameIndex)+source.channelOffset];
        frameIndex++;
        
    }
}
//=======================================================================================================
- (NSArray*)colorsForData:(NSData*)data startMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli rate:(NSInteger)rate light:(DIYBLightSource*)light frameLength:(NSInteger)frameLength
{
    NSInteger index=[self frameIndexForMilli:startMilli rate:rate];
    NSInteger frameCount=[self frameCountForStartMilli:startMilli endMilli:endMilli rate:rate]  ;
    NSInteger i;
    NSMutableArray* array=[NSMutableArray arrayWithCapacity:frameCount];
    for (i=0; i<frameCount; i++)
    {
        DIYBColor* color=[light colorForData:data.bytes+[self channelOffset]+[light channelOffset]+index*frameLength + i*frameLength];
        if (!color)
        {
        }
        else
        [array addObject:color];
    }
    return array;
}
//=======================================================================================================
- (NSURL*)imageURL
{
    NSURL* url=[[DIYBPrefData sharedInstance] imageDirectory];
    DIYBLightGroup* source=[self lightGroup];
    url=[url URLByAppendingPathComponent:[source imageDirectory]];
    return url;
    
}
//=======================================================================================================
- (NSURL*)patternURL
{
    NSURL* url=[[DIYBPrefData sharedInstance] patternDirectory];
    DIYBLightGroup* source=[self lightGroup];
    url=[url URLByAppendingPathComponent:[source patternDirectory]];
    return url;
    
}
//=======================================================================================================
- (BOOL)applyPattern:(DIYBEffectItem*)pattern patternCache:(DIYBURLCache*)patternCache imageCache:(DIYBImageCache*)imageCache patternURL:(NSURL*)patternURL imageURL:(NSURL*)imageURL grids:(NSDictionary*)grids data:(NSMutableData*)data frameLength:(NSInteger)frameLength rate:(NSInteger)rate offset:(NSInteger)offset error:(NSError* __autoreleasing*)error
{
    BOOL rvalue=YES;
    NSArray* trans=[pattern transitionsWithCache:patternCache baseURL:patternURL error:error];
    if (trans.count>0)
    {
        DIYBGrid* grid=[grids objectForKey:pattern.grid];
        NSArray* entries=[grid entriesBetweenMilli:pattern.startMilli endMilli:pattern.endMilli];
        NSInteger i;
        NSInteger effectIndex=0;
        DIYBLightGroup* group=[self lightGroup];
        if (entries && (entries.count>0))
        {
            for (i=0; i<entries.count-1 ;i++)
            {
                
                NSInteger startMilli=[[entries objectAtIndex:i] milli];
                NSInteger endMilli=[[entries objectAtIndex:i+1] milli];
                NSArray* effects=[trans objectAtIndex:effectIndex];
                effectIndex++;
                if (effectIndex>=trans.count)
                {
                    effectIndex=0;
                }
                for (DIYBTransition* transition in effects)
                {
                    [self applyTransition:transition data:data imageCache:imageCache imageURL:imageURL lightGroup:group startMilli:startMilli endMilli:endMilli rate:rate frameLength:frameLength offset:offset error:error];
                    if (error)
                    {
                        
                        if (*error)
                        {
                            rvalue=NO;
                            break;
                        }
                    }
                }
                if (error)
                {
                    if (*error)
                    {
                        rvalue=NO;
                        break;
                    }
                }
                
            }
        }
    }
    else if (error)
    {
        rvalue=NO;
        *error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Pattern: %@ : %@",pattern.pattern_light,(*error).localizedDescription] forKey:NSLocalizedDescriptionKey]];
    }
    return rvalue;
}
//=======================================================================================================
- (BOOL)applyTransition:(DIYBTransition*)transition data:(NSMutableData*)data imageCache:(DIYBImageCache*)cache imageURL:(NSURL*)url lightGroup:(DIYBLightGroup*)group startMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli rate:(NSInteger)rate frameLength:(NSInteger)frameLength offset:(NSInteger)offset error:(NSError* __autoreleasing*)error
{
    
    BOOL rvalue=YES;
    NSBitmapImageRep* startImage=nil;
    NSBitmapImageRep* endImage=nil;
    NSBitmapImageRep* maskImage=nil;
    NSURL *imageUrl=[url URLByAppendingPathComponent:transition.startImage];
    startImage=[cache repForURL:imageUrl error:NULL ];
    imageUrl=[url URLByAppendingPathComponent:transition.endImage];
    endImage=[cache repForURL:imageUrl error:NULL ];
    imageUrl=[url URLByAppendingPathComponent:transition.maskImage];
    maskImage=[cache repForURL:imageUrl error:NULL ];
    if (startImage && endImage && maskImage)
    {
        NSPoint startOrigin=transition.startOrigin;
        NSPoint endOrigin=transition.endOrigin;
        NSPoint maskOrigin=transition.maskOrigin;
        NSArray* lights=[[group.lights allObjects] sortedArrayUsingSelector:@selector(applyOrder:)];
        for (DIYBLightSource* source in lights)
        {
            DIYBColor* startColor=[self colorFromRep:startImage point:NSMakePoint(startOrigin.x+source.origin.x, startOrigin.y+source.origin.y)];
            DIYBColor* endColor=[self colorFromRep:endImage point:NSMakePoint(endOrigin.x+source.origin.x, endOrigin.y+source.origin.y)];
            DIYBColor* maskColor=[self colorFromRep:maskImage point:NSMakePoint(maskOrigin.x+source.origin.x, maskOrigin.y+source.origin.y)];
            if (maskColor.eightRed>0)
            {
                NSArray* colors=[self colorsForData:data startMilli:startMilli endMilli:endMilli rate:rate light:source frameLength:frameLength];
                colors=[PixelEffect applyEffect:transition.effect colors:colors startColor:startColor endColor:endColor maskColor:maskColor];
                [self applyColors:colors data:data frameLength:frameLength rate:rate source:source startMilli:startMilli offset:offset];
            }
            
        }
    }
    else if (error)
    {
        rvalue=NO;
        if (!startImage)
        {
            *error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unable to open %@",transition.startImage] forKey:NSLocalizedDescriptionKey]];
        }
        else if (!endImage)
        {
            *error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unable to open %@",transition.endImage] forKey:NSLocalizedDescriptionKey]];
        }
        else if (!maskImage)
        {
            *error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unable to open %@",transition.maskImage] forKey:NSLocalizedDescriptionKey]];
        }

    }
    else
    {
//        NSLog(@"NON Error Apply transistion" );

        rvalue=NO;
    }
    return rvalue;
}

//=======================================================================================================
- (DIYBColor*)colorFromRep:(NSBitmapImageRep*)rep point:(NSPoint)point
{
    NSInteger x=point.x;
    NSInteger y=point.y;
    DIYBColor* color=[DIYBColor blackColor];
    if ((rep.pixelsHigh>=y) && (rep.pixelsWide>=x) )
    {
        color=[[DIYBColor alloc] initWithNSColor:[rep colorAtX:x y:y]];
    }
    return color;
}

//=======================================================================================================
- (BOOL)renderData:(NSMutableData*)data frameLength:(NSInteger)frameLength rate:(NSInteger)rate imageCache:(DIYBImageCache*)imageCache patternCache:(DIYBURLCache*)patternCache grids:(NSDictionary*)grids offset:(NSInteger)offset error:(NSError* __autoreleasing*)error
{
    BOOL rvalue=YES;
    NSError* inerror=nil;
    NSArray* effects=[[[self effects] allObjects] sortedArrayUsingSelector:@selector(applyOrder:)];
    NSURL* patternURL=[self patternURL];
    NSURL* imageURL=[self imageURL];
    for (DIYBEffectItem* effect in effects)
    {
//        NSLog(@"Processing effect %@ in sequenceitem %@",effect,self.name);
        if  ([effect isPattern])
        {
            [self applyPattern:effect patternCache:patternCache imageCache:imageCache patternURL:patternURL imageURL:imageURL grids:grids data:data frameLength:frameLength  rate:rate offset:offset error:&inerror];
            if (inerror)
            {
                rvalue=NO;
                if (error)
                {
                    *error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ : %@",effect.pattern_light,inerror.localizedDescription] forKey:NSLocalizedDescriptionKey]];
                }
                break;
            }
        }
        
    }
    return rvalue;
}
@end
