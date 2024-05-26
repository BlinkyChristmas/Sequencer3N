//
//  DIYBCreateGridDialog.m
//  Sequencer3
//
//  Created by charles on 9/8/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBCreateGridDialog.h"

@interface DIYBCreateGridDialog ()

@end

@implementation DIYBCreateGridDialog

//==========================================================================================
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//==========================================================================================
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
        if ([self validateName:_grid])
        {
            [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseOK];
        }
        else
            [self.window.sheetParent.windowController presentError:[self buildErrror:_grid] modalForWindow:self.window delegate:nil didPresentSelector:nil contextInfo:NULL];
    }
    
}

//==========================================================================================
- (BOOL)validateName:(NSString*)name
{
    if ([_gridNames containsObject:name])
    {
        return NO;
    }
    else
        return YES;
}

- (NSError*)buildErrror:(NSString*)name
{
    return[NSError errorWithDomain:@"Sequencer" code:41 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Grid %@ all ready exists",name] forKey:NSLocalizedDescriptionKey]];
}
@end
