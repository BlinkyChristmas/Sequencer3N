// Copyright © 2024 Charles Kerr. All rights reserved.

#import <Foundation/Foundation.h>
#import "AccessoryView.h"
#import "AccessoryVisualController.h"
#import "../DIYBVisualGroup.h"
@implementation AccessoryView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        [self setWantsLayer:YES];
        
    }
    return self;
}

//============================================================================================
- (void)drawRect:(NSRect)dirtyRect
{

    AccessoryVisualController* controller = [[self window] windowController];

    [super drawRect:dirtyRect];
    
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
    if (controller) {
        NSData *data = [controller lightData] ;
        NSInteger currentFrame = [controller currentFrame] ;
        NSInteger frameLength = [controller frameLength] ;
        NSInteger frameCount = [controller frameCount];
        NSArray *groups = [controller groups] ;
        if (data)
        {
            if (currentFrame < frameCount) {
                NSInteger frameOffset = currentFrame * frameLength ;
                CGFloat scale = [ controller myscale] ;
                if (scale!=1.0)
                {
                    NSAffineTransform* transform=[NSAffineTransform transform];
                    [transform scaleBy:scale];
                    [transform concat];
                }
                    
                for (DIYBVisualGroup* group in groups)
                {
                    [group drawData:data offset:frameOffset];
                }
                    
            }
        }
    }
    
}
@end
