//
//  DIYBColor.h
//  Sequencer2
//
//  Created by charles on 8/16/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DIYBColor : NSObject<NSMutableCopying>
@property (assign) unsigned char eightRed;
@property (assign) unsigned char eightGreen;
@property (assign) unsigned char eightBlue;
@property (assign) BOOL isIntensity;


+ (DIYBColor*)blackColor;
+ (DIYBColor*)blackIntensity;
+ (DIYBColor*)colorForPoint:(NSPoint)origin image:(NSBitmapImageRep*)rep;
+ (NSArray*)colorsForStartMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli frameRate:(CGFloat)frameRate startColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor;
+ (NSArray*)colorsFor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor count:(NSInteger)count;

- (id)initWithNSColor:(NSColor*)color;
- (id)initWithColor:(DIYBColor*)color;
- (id)initWithString:(NSString*)colorstring;
- (id)initWithEightRed:(unsigned char)red eightGreen:(unsigned char)green eightBlue:(unsigned char)blue;
- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (id)initWithIntensity:(CGFloat)intensity;
- (id)initWithEightIntensity:(unsigned char)intensity;

- (NSColor*)colorForComponent:(NSInteger)component;
- (NSColor*)color;
- (void)setRedComponent:(CGFloat)red;
- (CGFloat)redComponent;
- (void)setGreenComponent:(CGFloat)green;
- (CGFloat)greenComponent;
- (void)setBlueComponent:(CGFloat)blue;
- (CGFloat)blueComponent;
- (NSString*)colorString;
- (BOOL)isBlack;

- (DIYBColor*)maxIntensity;
- (DIYBColor*)setIntensity:(CGFloat)intensity;

- (DIYBColor*)addColor:(DIYBColor*)newcolor fraction:(CGFloat)fraction;
- (DIYBColor*)randomColor;
- (DIYBColor*)addColor:(DIYBColor*)newcolor;

@end
