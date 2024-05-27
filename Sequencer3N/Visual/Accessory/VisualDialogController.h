// Copyright © 2024 Charles Kerr. All rights reserved.

#ifndef VisualDialogController_h
#define VisualDialogController_h
#import <Cocoa/Cocoa.h>
@interface VisualDialogController : NSWindowController

@property (strong) NSURL* visualFile ;
@property (strong) NSURL* renderLocation ;

- (IBAction)endDialog:(id)sender ;
- (IBAction)selectURL:(id)sender ;


@end

#endif /* VisualDialogController_h */
