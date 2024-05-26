//
//  DIYBURLCache.m
//  Sequencer3
//
//  Created by charles on 9/8/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBURLCache.h"
#import "DIYBTransition.h"
@implementation DIYBURLCache

- (id)init
{
    self=[super init];
    if (self)
    {
        _cache=[NSMutableDictionary dictionaryWithCapacity:100];
    }
    return self;
}

- (void)clearCache
{
    [_cache removeAllObjects];
}

- (NSArray*)transistionForPatternURL:(NSURL *)url error:(NSError* __autoreleasing*)error
{
    NSString* path=[url path];
    NSMutableArray* rvalue=[_cache objectForKey:path];
    if (!rvalue)
    {
        rvalue=[NSMutableArray arrayWithCapacity:30];
        NSXMLDocument* xmldoc=[[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:error];
        if (xmldoc)
        {
            rvalue=[NSMutableArray arrayWithCapacity:30];
            NSXMLElement* root=[xmldoc rootElement];
            NSArray* array=[root elementsForName:@"transition"];
            for (NSXMLElement* entry in array)
            {
                NSArray* children=[entry children];
                NSMutableArray* tranarray=[NSMutableArray arrayWithCapacity:20];
                for (NSXMLNode* node in children)
                {
                    if (node.kind==NSXMLElementKind)
                    {
                        NSXMLElement* element=(NSXMLElement*)node;
                        DIYBTransition* trans=[[DIYBTransition alloc] initWithElement:element];
                        [tranarray addObject:trans];
                    }
                }
                [rvalue addObject:tranarray];
                
            }
            [_cache setObject:rvalue forKey:[url path]];
        }
    }
    return rvalue;
}


@end
