//
//  DIYBURLCache.h
//  Sequencer3
//
//  Created by charles on 9/8/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIYBURLCache : NSObject
@property (strong) NSMutableDictionary* cache;

- (NSArray*)transistionForPatternURL:(NSURL *)url error:(NSError* __autoreleasing*)error;
- (void)clearCache;
@end
