//
//  DIYBVisualController.m
//  Sequencer3
//
//  Created by charles on 9/12/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBVisualController.h"
#import "DIYBVisualView.h"
#import "DIYBWindowController.h"
#import "DIYBDocument.h"
#import "DIYBVisualGroup.h"
#import "DIYBVisualPath.h"
#import "DIYBVisualView.h"
#import "DIYBPrefData.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
@interface DIYBVisualController ()

@end

@implementation DIYBVisualController



//================================================================================================
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _scale=1.0;
        _frameRate= 0.037;
        _currentTime=0.0;
    }
    return self;
}

//================================================================================================
- (void)setCurrentTime:(CGFloat )currentTime
{
    _currentTime=currentTime;
    [self.visualView setNeedsDisplay:YES];
}
//================================================================================================
- (void)setFrameOffset:(NSInteger)frameOffset
{
    _frameOffset=frameOffset;
    [self.visualView setNeedsDisplay:YES];
}
//================================================================================================
- (void)setScale:(CGFloat)scale
{
    _scale=scale;
    [self.visualView setNeedsDisplay:YES];
}
//=================================================================
- (void)setMainController:(DIYBWindowController *)mainController
{
    _mainController=mainController;
    _sequenceDocument=mainController.seqFile;
    [self bind:@"title" toObject:_mainController.mediaPlayer withKeyPath:@"mediaFile" options:nil];
    [self bind:@"currentTime" toObject:_mainController.mediaPlayer withKeyPath:@"currentTime" options:nil];
    [self bind:@"frameLength" toObject:_mainController withKeyPath:@"frameLength" options:nil ];
    [self bind:@"frameRate" toObject:_mainController.seqFile withKeyPath:@"frameRate" options:nil];
    [self bind:@"maxFrame" toObject:_mainController withKeyPath:@"maxFrame" options:nil ];
    [self bind:@"sequenceData" toObject:_mainController withKeyPath:@"renderedData" options:nil];
    [self bind:@"sequenceOffsets" toObject:_mainController withKeyPath:@"sequenceOffsets" options:nil];
    
    
}

//================================================================================================
- (void)setTitle:(NSString *)title
{
    if(title)
    {
        _title=[NSString stringWithFormat:@"Visualizer: %@",title];
        [self.window setTitle:_title];
    }
    else
    {
        _title=title;
        [self.window setTitle:@"Visualizer"];
    }
}
//================================================================================================
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_visualView setController:self];
    if (!_title)
    {
        _title=@"Visualizer";
    }
    [self.window setTitle:_title];
}

//==============================================================================================

- (BOOL)loadURL:(NSURL*)url
{
    NSXMLDocument* xmldoc=[[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:NULL];
    BOOL rvalue=NO;
    if (xmldoc)
    {
        NSMutableArray* array=[NSMutableArray arrayWithCapacity:20];
        NSArray* children=[[xmldoc rootElement] elementsForName:@"visualGroup"];
        for (NSXMLElement* child in children)
        {
            DIYBVisualGroup* group=[[DIYBVisualGroup alloc] initWithElement:child];
            [array addObject:group];
        }
        self.groups=array;
        if ([self.window isVisible])
        {
            [self.window.contentView setNeedsDisplay:YES];
        }
        rvalue=YES;
        //Just check to see if there is a scale we should default to
        NSXMLNode* node=[[xmldoc rootElement] attributeForName:@"scale"];
        if (node)
        {
            self.scale=[[node stringValue] doubleValue];
        }
    }
    return rvalue;
}

//==============================================================================
- (void)setSequenceOffsets:(NSDictionary *)sequenceOffsets
{
    _sequenceOffsets=sequenceOffsets;
    [self updateSequence];
}
//==============================================================================
- (void)updateSequence
{
    for (DIYBVisualGroup* group in _groups)
    {
        [group updateOffsets:_sequenceOffsets document:_sequenceDocument];
    }
    [self.visualView setNeedsDisplay:YES];
}
//==============================================================================
- (IBAction)selectURL:(id)sender
{
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setTitle:@"Visualization Definition Selection"];
    [panel setCanChooseDirectories:NO];
    //[panel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"xml"]]];
    //[panel setAllowedContentTypes:[UTType typeWithFilenameExtension:@"xml"] ] ;
    [panel setAllowsMultipleSelection:NO];
    NSURL* url=[[DIYBPrefData sharedInstance] visualDirectory];
    if (url)
    {
        [panel setDirectoryURL:url];
    }
    if ([panel runModal]==NSModalResponseOK)
    {
        NSURL* newurl=[panel URL];
        NSString* file=[newurl path];
        if (url)
        {
            file=[file stringByReplacingOccurrencesOfString:[url path] withString:@""];
            if ([file hasPrefix:@"/"])
            {
                file=[file stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
        }
        if ([self loadURL:newurl])
        {
        
            self.visualFile=file;
            _mainController.seqFile.visualization=self.visualFile;
            [_mainController.seqFile updateChangeCount:NSChangeDone];
            [self updateSequence];
        }
    }
}

@end
