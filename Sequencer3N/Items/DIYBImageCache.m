//
//  DIYBImageCache.m
//  Sequencer3
//
//  Created by charles on 9/11/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBImageCache.h"

@implementation DIYBImageCache
//==================================================================================================
- (id)init
{
    self=[super init];
    if (self)
    {
        _cache=[NSMutableDictionary dictionaryWithCapacity:100];
    }
    return self;
}

//==================================================================================================
- (void)clearCache
{
    [_cache removeAllObjects];
}
//==================================================================================================
- (NSBitmapImageRep*)repForURL:(NSURL *)url error:(NSError *__autoreleasing *)error
{
    NSString* path=[url path];
    NSBitmapImageRep* rep=[_cache objectForKey:path];
    if (!rep)
    {
        NSData* data = [[NSData alloc] initWithContentsOfURL:url];
        rep = [NSBitmapImageRep imageRepWithData:data] ;
        //rep = [NSBitmapImageRep imageRepWithContentsOfURL:url];
        if (rep)
        {
            [_cache setObject:rep forKey:path];
        }
    }
    return rep;
}
@end
