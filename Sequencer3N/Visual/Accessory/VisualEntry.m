// Copyright © 2024 Charles Kerr. All rights reserved.

#import <Foundation/Foundation.h>
#import "AccessoryVisualController.h"
#import "VisualEntry.h"
@implementation VisualEntry

- (id)init {
    _visualFile = nil ;
    _renderLocation = nil ;
    _visualController = nil ;
    return [super init] ;
}
- (void)dealloc {
    if (_visualController) {
        [_visualController close] ;
    }
}

@end
