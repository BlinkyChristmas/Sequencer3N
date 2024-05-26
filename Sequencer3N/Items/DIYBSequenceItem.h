//
//  DIYBSequenceItem.h
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DIYBEffectItem;
@class DIYBLightGroup;
@class DIYBColor;
@class DIYBLightSource;
@class DIYBImageCache;
@class DIYBURLCache;

@interface DIYBSequenceItem : NSObject<NSMutableCopying,NSSecureCoding>
@property (strong) NSXMLElement* element;
@property (strong) NSMutableSet* effects;

@property (weak,nonatomic) NSString* name;
@property (weak,nonatomic) NSString* source;
@property (assign) NSInteger displayOrder;
@property (assign) NSInteger applyOrder;
@property (assign,readonly,nonatomic) NSInteger startMilli;
@property (assign,readonly,nonatomic) NSInteger endMilli;
@property (assign) NSInteger channelOffset;

- (id)initWithElement:(NSXMLElement*)element;
- (id)initWithItem:(DIYBSequenceItem*)item;
- (void)addEffect:(DIYBEffectItem*)effect;
- (void)removeEffect:(DIYBEffectItem*)effect;

- (DIYBLightGroup*)lightGroup;
- (NSInteger)length;
- (NSInteger)frameCountForStartMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli rate:(NSInteger)rate;

//- (NSArray*)colorsForStartColor:(DIYBColor*)startColor endColor:(DIYBColor*)endColor startMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli rate:(NSInteger)rate;
- (NSArray*)colorsForData:(NSData*)data startMilli:(NSInteger)startMilli endMilli:(NSInteger)endMilli rate:(NSInteger)rate light:(DIYBLightSource*)light frameLength:(NSInteger)frameLength;

- (NSURL*)imageURL;
- (NSURL*)patternURL;

- (BOOL)applyPattern:(DIYBEffectItem*)pattern patternCache:(DIYBURLCache*)patternCache imageCache:(DIYBImageCache*)imageCache patternURL:(NSURL*)patternURL imageURL:(NSURL*)imageURL grids:(NSDictionary*)grids data:(NSMutableData*)data frameLength:(NSInteger)frameLength rate:(NSInteger)rate offset:(NSInteger)offset error:(NSError* __autoreleasing*)error;

- (BOOL)renderData:(NSMutableData*)data frameLength:(NSInteger)frameLength rate:(NSInteger)rate imageCache:(DIYBImageCache*)imageCache patternCache:(DIYBURLCache*)patternCache grids:(NSDictionary*)grids offset:(NSInteger)offset error:(NSError* __autoreleasing*)error;
@end
