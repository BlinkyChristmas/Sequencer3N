//
//  DIYBItemEffectView.h
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBItemView.h"
@class DIYBItemController;
@class DIYBEffectItem;
@interface DIYBItemEffectView : DIYBItemView
@property (weak) IBOutlet DIYBItemController* controller;
@property (strong) NSFont* font;
@property (strong) NSDictionary* dictionary;
@property (strong,nonatomic) NSColor* fontColor;
@property (assign,nonatomic) CGFloat effectHeight;
@property (assign,nonatomic) CGFloat fontSize;
@property (assign,nonatomic) NSColor* selectionColor;
@property (assign,nonatomic) NSColor* effectColor;
@property (strong) NSMutableParagraphStyle* style;
@property (assign) CGFloat clickTime;
@property (assign) BOOL dragging;
@property (assign) NSInteger dragType;
@property (assign) NSInteger timeOffset;
@property (strong,nonatomic) NSCursor* cursor;

- (void)drawEffect:(DIYBEffectItem*)effect layer:(NSInteger)layer;
- (void)drawEffects:(NSArray*)array useLabel:(BOOL)useLabel;
- (void)drawLabel:(DIYBEffectItem*)effect layer:(NSInteger)layer;
- (NSArray*)effectsInDrawOrder;
- (NSArray*)effectsInApplyOrder;
- (void)resetToolTips;
- (NSArray*)effectsForPoint:(NSPoint)point effects:(NSArray*)effects;

- (IBAction)selectEffect:(id)sender;
- (IBAction)editEffect:(id)sender;
- (IBAction)createEffect:(id)sender;

- (DIYBEffectItem*)selectedItem:(NSArray*)effects;
- (void)setCursor:(NSCursor *)cursor;
@end
