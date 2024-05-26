//
//  DIYBPrefController.m
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBPrefController.h"
#import "DIYBPrefData.h"

@interface DIYBPrefController ()

@end

@implementation DIYBPrefController

//=======================================================================
- (NSString*)windowNibName
{
    return @"DIYBPrefController";
}
//=======================================================================
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//=======================================================================
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
//=======================================================================
- (IBAction)selectURL:(id)sender
{
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setPrompt:@"Select"];
//    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"xml"]]];

    if ([sender tag]>=5)
    {
        [panel setCanCreateDirectories:YES];
        [panel setCanChooseDirectories:YES];
        [panel setCanChooseFiles:NO];
    }
    else
    {
        [panel setCanCreateDirectories:NO];
        [panel setCanChooseDirectories:NO];
        [panel setCanChooseFiles:YES];
        
    }
    switch ([sender tag])
    {
        case 0:
            [panel setTitle:@"Light Group File Selection"];
            break;
            
        case 5:
            [panel setTitle:@"Pattern Directory Selection"];
            break;
        case 6:
            [panel setTitle:@"Image Directory Selection"];
            break;
        case 7:
            [panel setTitle:@"Music/Media Directory Selection"];
            break;
        case 8:
            [panel setTitle:@"Visualization Directory Selection"];
            break;
        default:
            break;
    }
    if ([panel runModal]==NSModalResponseOK)
    {
        switch ([sender tag])
        {
            case 0:
                self.prefData.lightGroupFile=[panel URL];
                break;
                
            case 5:
                self.prefData.patternDirectory=[panel URL];
                break;
            case 6:
                self.prefData.imageDirectory=[panel URL];
                break;
            case 7:
                self.prefData.mediaDirectory=[panel URL];
                break;
            case 8:
                self.prefData.visualDirectory=[panel URL];
                break;
            default:
                break;
        }
        
    }
}
@end
