//
//  DIYBExportLight.m
//  Sequencer3
//
//  Created by charles on 9/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBExportLight.h"

@implementation DIYBExportLight

- (id)initWithElement:(NSXMLElement *)element
{
    self=[super init];
    if (self)
    {
        _offset=0;
        _name=nil;
        NSXMLNode*node=[element attributeForName:@"name"];
        if (node)
        {
            _name=[[node stringValue] copy];
            node=[element attributeForName:@"offset"];
            if (node)
            {
                _offset=[[node stringValue] integerValue];
            }
        }
    }
    return self;
}
@end
