//
//  DIYBItemController.h
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class  DIYBItemView;
@class DIYBItemEffectView;
@class DIYBSequenceItem;
@interface DIYBItemController : NSViewController
@property (weak) IBOutlet DIYBItemView* itemView;
@property (strong) IBOutlet DIYBItemEffectView* effectView;
@property (strong) DIYBSequenceItem* item;
@property (assign) NSInteger orderDisplay;
@property (assign) NSInteger orderApply;
@property (assign,nonatomic) BOOL isExpanded;
@property (assign,nonatomic) BOOL isVisible;
- (id)initWithItem:(DIYBSequenceItem*)item displayOrder:(NSInteger)orderDisplay;

- (NSComparisonResult)displayOrder:(DIYBItemController*)controller;
@end
