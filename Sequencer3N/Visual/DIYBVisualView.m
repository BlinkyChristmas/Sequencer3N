//
//  DIYBVisualView.m
//  Sequencer3
//
//  Created by charles on 9/13/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBVisualView.h"
#import "DIYBVisualGroup.h"
#import "DIYBVisualController.h"

@implementation DIYBVisualView

//============================================================================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setWantsLayer:YES];
        
    }
    return self;
}

//============================================================================================
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
    if (_controller.frameRate>0.0)
    {
        NSInteger frame=_controller.currentTime/_controller.frameRate;
        if (frame>=_controller.maxFrame)
        {
            frame=_controller.maxFrame-1;
        }
        NSInteger frameOffset=frame*_controller.frameLength;
        
        if (_controller.sequenceData)
        {
            if (_controller.scale!=1.0)
            {
                NSAffineTransform* transform=[NSAffineTransform transform];
                [transform scaleBy:_controller.scale];
                [transform concat];
            }
            for (DIYBVisualGroup* group in _controller.groups)
            {
                [group drawData:_controller.sequenceData offset:frameOffset];
            }
        }
    }
    
}
//============================================================================================
- (BOOL)isOpaque
{
    return YES;
}

@end
