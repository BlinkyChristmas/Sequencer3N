//
//  DIYBFilterItem.h
//  Sequencer3
//
//  Created by charles on 9/15/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DIYBItemController;
@interface DIYBFilterItem : NSObject
@property (weak) DIYBItemController* itemController;
@property (assign) BOOL isVisible;
@property (assign) NSInteger order;
@property (copy) NSString* itemName;
@end
