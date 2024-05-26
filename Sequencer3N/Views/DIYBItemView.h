//
//  DIYBItemView.h
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBEffectView.h"
@class DIYBPrefData;
@interface DIYBItemView : DIYBEffectView
@property (strong,nonatomic) NSColor* separatorColor;
@property (weak) DIYBPrefData* prefData;

@end
