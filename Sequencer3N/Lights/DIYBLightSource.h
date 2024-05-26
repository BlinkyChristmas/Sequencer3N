//
//  DIYBLightSource.h
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DIYBColor;

@interface DIYBLightSource : NSObject
@property (copy)NSString* type;
@property (assign)NSPoint origin;
@property (copy) NSString* name;
@property (assign) NSInteger order;
@property (assign,readonly) NSInteger channelOffset;

+ (BOOL)isValidLightSource:(NSXMLElement*)element;

- (id)initWithElement:(NSXMLElement*)element order:(NSInteger)order offset:(NSInteger)offset;
- (NSComparisonResult)applyOrder:(DIYBLightSource*)light;

- (NSInteger)channelCount;

- (void)applyColor:(DIYBColor*)color location:(unsigned char*)data;
- (DIYBColor*)colorForData:(const char*)data;
@end
