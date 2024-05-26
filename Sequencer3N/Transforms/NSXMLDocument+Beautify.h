//
//  NSXMLDocument+Beautify.h
//  Sequencer3
//
//  Created by charles on 9/2/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSXMLDocument (Beautify)

- (NSData*)prettyXMLWithError:(NSError* __autoreleasing*)error;
@end
