//
//  DIYBLightGroup.h
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DIYBLightSource;

@interface DIYBLightGroup : NSObject
@property(strong) NSMutableSet* lights;
@property(copy) NSString* name;
@property(copy) NSString* patternDirectory;
@property(copy) NSString* imageDirectory;
@property(assign)NSInteger channelCount;

- (id)initWithElement:(NSXMLElement*)element;
- (DIYBLightSource*)lightForName:(NSString*)name;
- (NSComparisonResult)caseInsensitiveCompare:(DIYBLightGroup*)group;
@end
