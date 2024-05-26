//
//  DIYBVisualGroup.h
//  Sequencer3
//
//  Created by charles on 9/13/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DIYBDocument;
@interface DIYBVisualGroup : NSObject
@property (assign) CGFloat scale;
@property (assign) NSPoint origin;
@property (strong) NSMutableArray* lights;

- (id)initWithElement:(NSXMLElement*)element;
- (void)drawData:(NSData*)data offset:(NSInteger)frameOffset;
- (void)updateOffsets:(NSDictionary*)sequenceOffsets document:(DIYBDocument*)document;
@end
