// Copyright © 2024 Charles Kerr. All rights reserved.

#ifndef VisualSelectionController_h
#define VisualSelectionController_h
#import <Cocoa/Cocoa.h>
@class VisualEntry ;
@class VisualDialogController ;
@class DIYBWindowController ;
@interface VisualSelectionController : NSWindowController

@property (weak) IBOutlet NSArrayController* arrayController ;
@property (weak) IBOutlet VisualDialogController* dialogController ;
@property (weak) DIYBWindowController* masterController ;

@property (strong) NSMutableArray* entries ;

- (IBAction)endDialog:(id) sender ;
- (IBAction)changeSelection:(id) sender ;

- (void)updateSong:(NSString*)songName ;

@end

#endif /* VisualSelectionController_h */
