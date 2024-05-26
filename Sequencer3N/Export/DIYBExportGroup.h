//
//  DIYBExportGroup.h
//  Sequencer3
//
//  Created by charles on 10/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DIYBDocument;
@interface DIYBExportGroup : NSObject

@property (assign,readonly,nonatomic) NSInteger highestChannel;
@property (strong) NSMutableSet* exportedItems;

- (BOOL)loadExportURL:(NSURL*)url;
- (NSInteger)frameLength;
- (void)updateOffsets:(NSDictionary*)sequenceOffsets document:(DIYBDocument *)document;
- (NSData*)formatData:(NSData*)data frameRate:(CGFloat)rate frameLength:(NSInteger)frameLength sequenceOffsets:(NSDictionary*)sequenceOffset document:(DIYBDocument*)document;
@end
