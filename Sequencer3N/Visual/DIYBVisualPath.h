//
//  DIYBVisualPath.h
//  Sequencer2
//
//  Created by charles on 8/30/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@class DIYBColor;
@class DIYBLightSource;
@class DIYBDocument;
@interface DIYBVisualPath : NSObject
@property (strong) NSBezierPath* path;
@property (assign) BOOL isFill;
@property (assign) NSPoint origin;
@property (assign) CGFloat lineWidth;
@property (strong) DIYBColor* color;
@property (copy) NSString* sequenceItem;
@property (copy) NSString* lightSource;
@property (assign) NSInteger offset;
@property (weak) DIYBLightSource* light;
@property (assign) BOOL isOval;
+ (BOOL)validElement:(NSString*)name;

- (id)initWithElement:(NSXMLElement*)element;

- (NSPoint)pointForString:(NSString *)string;

- (void)buildOval:(NSXMLElement*)element;
- (void)configureLightForDocument:(DIYBDocument*)document;
- (void)drawData:(NSData*)data offset:(NSInteger)frameOffset;
@end
