//
//  DIYBVisualController.h
//  Sequencer3
//
//  Created by charles on 9/12/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DIYBWindowController;
@class DIYBDocument;
@class DIYBVisualView;

@interface DIYBVisualController : NSWindowController
@property (assign,nonatomic) CGFloat currentTime;
@property (assign,nonatomic) NSInteger frameOffset;
@property (assign) CGFloat frameRate;
@property (weak,nonatomic) DIYBWindowController* mainController;
@property (weak) DIYBDocument* sequenceDocument;
@property (copy,nonatomic) NSString* title;
@property (strong) NSArray* groups;
@property (copy) NSString* visualFile;
@property (assign,nonatomic) CGFloat scale;
@property (assign) NSInteger maxFrame;
@property (assign)NSInteger frameLength;
@property (strong) NSData* sequenceData;
@property (weak,nonatomic) NSDictionary*  sequenceOffsets;

@property (weak) IBOutlet DIYBVisualView* visualView;
- (BOOL)loadURL:(NSURL*)url;
- (void)updateSequence;

- (IBAction)selectURL:(id)sender;
@end
