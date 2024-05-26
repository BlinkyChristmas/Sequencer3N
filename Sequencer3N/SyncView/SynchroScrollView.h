//
//  SynchroScrollView.h
//  Timeline
//
//  Created by charles on 3/3/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SynchroScrollView : NSScrollView
{
    __weak NSScrollView* synchronizedVScrollView; // not retained
    __weak NSScrollView* synchronizedHScrollView; // not retained
    
}

- (void)setVSynchronizedScrollView:(NSScrollView*)scrollview;
- (void)setHSynchronizedScrollView:(NSScrollView*)scrollview;
- (void)stopHSynchronizing;
- (void)stopVSynchronizing;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification;

@end