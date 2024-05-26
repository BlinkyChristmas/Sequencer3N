//
//  DIYBTimeEntryController.m
//  Sequencer3
//
//  Created by charles on 9/15/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBTimeEntryController.h"

@interface DIYBTimeEntryController ()

@end

@implementation DIYBTimeEntryController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
//==========================================================================================
- (IBAction)cancelButton:(id)sender
{
    [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseCancel];
}
//==========================================================================================
- (IBAction)createButton:(id)sender
{
    if ( [[self window] makeFirstResponder:sender])
    {
        [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseOK];
    }
    
}
//==========================================================================================
- (NSInteger)milli
{
    NSInteger milli=self.time*10000;
    return milli/10;
}
@end
