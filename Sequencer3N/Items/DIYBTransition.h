//
//  DIYBTransition.h
//  Sequencer3
//
//  Created by charles on 9/8/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIYBTransition : NSObject
@property (copy) NSString* effect;
@property (copy) NSString* startImage;
@property (copy) NSString* endImage;
@property (copy) NSString* maskImage;
@property (assign)NSPoint startOrigin;
@property (assign) NSPoint endOrigin;
@property (assign) NSPoint maskOrigin;

- (id)initWithElement:(NSXMLElement*)element;
- (NSPoint)pointForString:(NSString *)string;

@end
