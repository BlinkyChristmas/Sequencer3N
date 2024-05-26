//
//  DIYBExportLight.h
//  Sequencer3
//
//  Created by charles on 9/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIYBExportLight : NSObject
@property (assign) NSInteger offset;
@property (copy) NSString* name;
- (id)initWithElement:(NSXMLElement*)element;
@end
