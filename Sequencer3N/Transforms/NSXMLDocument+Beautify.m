//
//  NSXMLDocument+Beautify.m
//  Sequencer3
//
//  Created by charles on 9/2/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "NSXMLDocument+Beautify.h"

@implementation NSXMLDocument (Beautify)

//===============================================================================================================
- (NSData*)prettyXMLWithError:(NSError* __autoreleasing*)error
{
    NSBundle* mainBundle=[NSBundle mainBundle];
    NSData * transformed=nil;
    NSURL*  myFile = [mainBundle URLForResource:@"prettyxml" withExtension:@"xml" ];
    if (myFile)
    {
        NSData * data = [NSData dataWithContentsOfURL:myFile options:NSDataReadingMappedIfSafe error:error] ;
        if (data)
        {
            transformed = [self objectByApplyingXSLT:data arguments:nil error:error] ;
        }

    }
    return transformed;
    
}
@end
