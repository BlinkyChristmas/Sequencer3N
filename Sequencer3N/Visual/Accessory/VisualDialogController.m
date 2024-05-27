// Copyright © 2024 Charles Kerr. All rights reserved.

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "VisualDialogController.h"

@implementation VisualDialogController

//============================================================
- (NSString*)windowNibName
{
    return @"VisualDialog";
}

- (IBAction)endDialog:(id)sender {
    NSInteger tag = [sender tag] ;
    if (tag == 0) {
        if ([[self window] sheetParent]){
            [[[self window] sheetParent] endSheet:[self window] returnCode:NSModalResponseCancel] ;
        }
        else {
            [self close] ;
        }
    }
    else {
        if ([[self window] sheetParent]){
            [[[self window] sheetParent] endSheet:[self window] returnCode:NSModalResponseOK] ;
        }
        else {
            [self close] ;
        }
    }
}
- (IBAction)selectURL:(id)sender {
    NSOpenPanel* panel = [[NSOpenPanel alloc] init] ;
    
    NSInteger tag = [sender tag] ;
    if (tag == 0) {
        [panel setPrompt:@"Select Visualization File"];
        [panel setCanChooseFiles:YES] ;
        [panel setCanChooseDirectories:NO];
    }
    else {
        [panel setPrompt:@"Select Render Data Location"];
        [panel setCanChooseFiles:NO] ;
        [panel setCanChooseDirectories:YES];
    }
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK){
            if (tag == 0) {
                [self setVisualFile:[panel URL]]   ;
            }
            else {
                [self setRenderLocation:[panel URL]] ;
            }
        }
    }];
}


@end
