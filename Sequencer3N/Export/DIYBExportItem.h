//
//  DIYBExportItem.h
//  Sequencer3
//
//  Created by charles on 10/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DIYBDocument;
@class DIYBLightSource;
@interface DIYBExportItem : NSObject
@property (assign) NSInteger channel;
@property (copy) NSString* sequenceItem;
@property (copy) NSString* light;
@property (assign) NSInteger offset;
@property (weak) DIYBLightSource* lightSource;

- (id)initWithSequenceItem:(NSString*)sequenceItem lightSource:(NSString*)lightSource channel:(NSInteger)channel;
- (void)configureLightForDocument:(DIYBDocument*)document;
@end
