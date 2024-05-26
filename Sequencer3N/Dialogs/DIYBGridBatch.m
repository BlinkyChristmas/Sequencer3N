//
//  DIYBGridBatch.m
//  Sequencer3
//
//  Created by charles on 9/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBGridBatch.h"
#import "DIYBPrefData.h"
#import "DIYBWindowController.h"
#import "DIYBDocument.h"
#import "DIYBGrid.h"
#import "DIYBTimeEntry.h"

@interface DIYBGridBatch ()

@end

@implementation DIYBGridBatch

+ (NSSet*)keyPathsForValuesAffectingShouldContract
{
    return [NSSet setWithObject:@"shouldExpand"];
}
+ (NSSet*)keyPathsForValuesAffectingShouldExpand
{
    return [NSSet setWithObject:@"shouldContract"];
}
//==========================================================================================
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _shouldContract=YES;
        _shouldExpand=NO;
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
        [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseOK];
    }
    
}

//=====================================================================================
- (void)setShouldContract:(BOOL)shouldContract
{
    _shouldContract=shouldContract;
    _shouldExpand=!shouldContract;

}
- (void)setShouldExpand:(BOOL)shouldExpand
{
    _shouldExpand=shouldExpand;
    _shouldContract=!shouldExpand;
}

@end
