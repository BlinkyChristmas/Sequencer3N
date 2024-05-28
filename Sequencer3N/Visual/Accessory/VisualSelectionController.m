// Copyright © 2024 Charles Kerr. All rights reserved.

#import <Foundation/Foundation.h>
#import "VisualSelectionController.h"
#import "VisualDialogController.h"
#import "VisualEntry.h"
#import "AccessoryVisualController.h"
#import "../../Document/DIYBWindowController.h"
#import "../../MediaPlayer/DIYBMediaPlayer.h"
@implementation VisualSelectionController

//============================================================
- (NSString*)windowNibName
{
    return @"VisualSelection";
}
- (id)init {
    _entries = [[NSMutableArray alloc] initWithCapacity:10] ;
    return [super init];
}
// =====================================================================
- (IBAction)endDialog:(id) sender {
    NSInteger tag = [sender tag] ;
    if ([[self window] sheetParent]){
        if (tag == 0) {
            [[[self window] sheetParent] endSheet:[self window] returnCode:NSModalResponseCancel];
        }
        else {
            [[[self window] sheetParent] endSheet:[self window] returnCode:NSModalResponseCancel];
        }
    }
    else {
        [self close];
    }
    
}

// =====================================================================
- (IBAction)changeSelection:(id) sender {
    NSInteger tag = [sender tag] ;
    if (tag == 1) {
        [[self window] beginSheet:[_dialogController window] completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseOK) {
                VisualEntry* entry = [[VisualEntry alloc] init] ;
                [entry setVisualFile:[self->_dialogController visualFile]];
                [entry setRenderLocation:[self->_dialogController renderLocation]] ;
                AccessoryVisualController* controller = [[AccessoryVisualController alloc] init] ;
                [controller setVisualFile:[entry visualFile]];
                [controller setRenderLocation:[entry renderLocation]] ;
                if (self->_masterController) {
                    [controller setSequenceOffsets:[self->_masterController sequenceOffsets]] ;
                    
                    NSString* media = [self->_masterController mediaFile] ;
                    if (media) {
                        NSURL * temp = [NSURL fileURLWithPath:media];
                        NSString* filename = [[temp URLByDeletingPathExtension] lastPathComponent] ;
                        if (filename) {
                            [controller loadSong:filename] ;
                        }
                    }
                    [controller bind:@"currentTime" toObject:self->_masterController.mediaPlayer withKeyPath:@"currentTime" options:nil];
                }
                [entry setVisualController:controller] ;
                [self->_arrayController addObject:entry] ;
                
            }
            [self->_dialogController setVisualFile:nil] ;
            [self->_dialogController setRenderLocation:nil];
        }];
    }
    else {
        
        [_arrayController removeObjects:[_arrayController selectedObjects]] ;
    }
    
}

// =====================================================================
- (void)updateSong:(NSString*)songName {
    
}


@end
