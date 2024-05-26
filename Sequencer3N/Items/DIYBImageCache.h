//
//  DIYBImageCache.h
//  Sequencer3
//
//  Created by charles on 9/11/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface DIYBImageCache : NSObject
@property (strong) NSMutableDictionary* cache;

- (NSBitmapImageRep*)repForURL:(NSURL *)url error:(NSError* __autoreleasing*)error;
- (void)clearCache;

@end
