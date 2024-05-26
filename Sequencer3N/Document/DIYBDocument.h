//
//  DIYBDocument.h
//  Sequencer3
//
//  Created by charles on 9/1/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DIYBGrid;
@class DIYBSequenceItem;
@class DIYBImageCache;
@class DIYBURLCache;
@interface DIYBDocument : NSDocument
@property (strong) NSXMLDocument* seqDocument;
@property (strong) NSXMLElement* rootElement;
@property (strong) NSXMLElement* gridContainer;
@property (copy,nonatomic) NSString* media;
@property (assign,nonatomic) CGFloat frameRate;
@property (strong) NSMutableDictionary* grids;
@property (strong) NSArray* gridNames;
@property (strong) NSMutableSet* sequenceItems;
@property (strong) NSMutableDictionary* sequenceOffsets;
@property (copy,nonatomic) NSString* visualization;
- (void)addGrid:(DIYBGrid*)grid;
- (void)removeGrid:(DIYBGrid*)grid;
- (DIYBSequenceItem*)itemForName:(NSString*)name;
- (void)addSequenceItem:(DIYBSequenceItem*)item;
- (void)removeSequenceItem:(DIYBSequenceItem*)item;

- (NSMutableData*)blankDataForSequence:(NSInteger*)frameLength count:(NSInteger*)frameCount;
- (NSMutableData*)renderDataWithImage:(DIYBImageCache*)imageCache pattern:(DIYBURLCache*)patternCache frameLength:(NSInteger*)frameLength frameCount:(NSInteger*)frameCount error:(NSError*__autoreleasing*)error;
@end
