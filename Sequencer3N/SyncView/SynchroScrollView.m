//
//  SynchroScrollView.m
//  Timeline
//
//  Created by charles on 3/3/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "SynchroScrollView.h"
#import "DIYBPrefData.h"
@implementation SynchroScrollView


//============================================
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//============================================
- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}
//============================================
- (void)setHSynchronizedScrollView:(NSScrollView*)scrollview
{
    NSView *synchronizedContentView;
    
    // stop an existing scroll view synchronizing
    [self stopHSynchronizing];
    
    // don't retain the watched view, because we assume that it will
    // be retained by the view hierarchy for as long as we're around.
    synchronizedHScrollView = scrollview;
    
    // get the content view of the
    synchronizedContentView=[synchronizedHScrollView contentView];
    
    // Make sure the watched view is sending bounds changed
    // notifications (which is probably does anyway, but calling
    // this again won't hurt).
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
    
    // a register for those notifications on the synchronized content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:synchronizedContentView];
}
//============================================
- (void)setVSynchronizedScrollView:(NSScrollView*)scrollview
{
    NSView *synchronizedContentView;
    
    // stop an existing scroll view synchronizing
    [self stopVSynchronizing];
    
    // don't retain the watched view, because we assume that it will
    // be retained by the view hierarchy for as long as we're around.
    synchronizedVScrollView = scrollview;
    
    // get the content view of the
    synchronizedContentView=[synchronizedVScrollView contentView];
    
    // Make sure the watched view is sending bounds changed
    // notifications (which is probably does anyway, but calling
    // this again won't hurt).
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
    
    // a register for those notifications on the synchronized content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:synchronizedContentView];
}


//============================================
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification
{
    // get the changed content view from the notification
    NSClipView *changedContentView=[notification object];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;;
    
    // get our current origin
    NSPoint curOffset = [[self contentView] bounds].origin;
    NSPoint newOffset = curOffset;
    
    // scrolling is synchronized in the Horizontal plane
    // so only modify the x component of the offset
    if (changedContentView == [synchronizedHScrollView contentView])
    {
        newOffset.x = changedBoundsOrigin.x;
    }
    else {
        if (![self hasHorizontalRuler]) {
            newOffset.y=changedBoundsOrigin.y + 32.0 ;
        }
        else {
            newOffset.y = changedBoundsOrigin.y - 32.0 ;
        }
        
    }
    
    // if our synced position is different from our current
    // position, reposition our content view
    if (!NSEqualPoints(curOffset, changedBoundsOrigin))
    {
        // note that a scroll view watching this one will
        // get notified here
        [[self contentView] scrollToPoint:newOffset];
        // we have to tell the NSScrollView to update its
        // scrollers
        [self reflectScrolledClipView:[self contentView]];
    }
}
//============================================
- (void)stopHSynchronizing
{
    if (synchronizedHScrollView != nil) {
        NSView* synchronizedContentView = [synchronizedHScrollView contentView];
        
        // remove any existing notification registration
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSViewBoundsDidChangeNotification
                                                      object:synchronizedContentView];
        
        // set synchronizedScrollView to nil
        synchronizedHScrollView=nil;
    }
}
//============================================
- (void)stopVSynchronizing
{
    if (synchronizedVScrollView != nil) {
        NSView* synchronizedContentView = [synchronizedVScrollView contentView];
        
        // remove any existing notification registration
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSViewBoundsDidChangeNotification
                                                      object:synchronizedContentView];
        
        // set synchronizedScrollView to nil
        synchronizedVScrollView=nil;
    }
}

//================================================================
- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [super viewWillMoveToWindow:newWindow];
    if (newWindow)
    {
        [self bind:@"backgroundColor" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"backgroundColor" options:nil];
    }
    else
        [self unbind:@"backgroundColor"];
}
@end
