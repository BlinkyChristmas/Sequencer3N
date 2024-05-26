//
//  DIYBItemController.m
//  Sequencer3
//
//  Created by charles on 9/6/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBItemController.h"
#import "DIYBSequenceItem.h"
#import "DIYBItemEffectView.h"

@interface DIYBItemController ()

@end

@implementation DIYBItemController

//===================================================================================
- (id)initWithItem:(DIYBSequenceItem *)item displayOrder:(NSInteger)orderDisplay;
{
    self=[self initWithNibName:@"DIYBItemController" bundle:nil];
    if (self)
    {
        _item=item;
        _effectView=[[DIYBItemEffectView alloc] initWithFrame:self.view.frame];
        [_effectView setController:self];
        _orderDisplay=orderDisplay;
        _isExpanded=NO;
        _isVisible=YES;
    }
    return self;
}

//===================================================================================
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//===================================================================================
- (NSComparisonResult)displayOrder:(DIYBItemController*)controller
{
    NSComparisonResult result=NSOrderedSame;
    if (_orderDisplay>controller.orderDisplay)
    {
        result=NSOrderedDescending;
    }
    else if (_orderDisplay<controller.orderDisplay)
    {
        result=NSOrderedAscending;
    }
    return result;
}
//===================================================================================
- (void)awakeFromNib
{
    [_effectView setController:self];
}
- (void)setIsVisible:(BOOL)isVisible
{
    _isVisible=isVisible;
    [_effectView setHidden:!isVisible];
    [_itemView setHidden:!isVisible];
}
@end
