//
//  PixelEffect.h
//  Sequencer2
//
//  Created by charles on 8/16/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DIYBColor;

extern const NSString* AddEffect;
extern const NSString* BlendEffect;
extern const NSString* ColorEffect;
extern const NSString* RandomEffect;
extern const NSString* ShimmerEffect;
extern const NSString* SparkleEffect;
extern const NSString* TwinkleEffect;
extern const NSString* DiminishEffect;
extern const NSString* PatternEffect;

@interface PixelEffect : NSObject
+ (BOOL)validEffect:(NSString*)effect;
+ (NSArray*)allEffects;
+ (NSArray*)applyEffect:(NSString*)effect colors:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applyBlend:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applyColor:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applyShimmer:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applyDiminish:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applySparkle:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applyTwinkle:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applyRandom:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
+ (NSArray*)applyAdd:(NSArray*)colors startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor maskColor:(DIYBColor*)maskColor;
@end
