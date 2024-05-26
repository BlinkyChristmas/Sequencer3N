//
//  NSColor+Serialization.h
//  Sequencer2
//
//  Created by charles on 8/18/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Serialization)
+ (NSColor*)colorForString:(NSString*)string;
- (NSString*)stringValue;
@end
