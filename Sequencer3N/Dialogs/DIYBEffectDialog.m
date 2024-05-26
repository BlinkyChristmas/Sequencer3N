//
//  DIYBEffectDialog.m
//  Sequencer3
//
//  Created by charles on 9/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBEffectDialog.h"
#import "DIYBEffectItem.h"
#import "DIYBPrefData.h"
#import "DIYBLightGroup.h"
#import "DIYBLightStorage.h"
#import "DIYBSequenceItem.h"
#import "DIYBWindowController.h"
#import "DIYBDocument.h"
#import "DIYBGrid.h"
#import "DIYBTimeEntry.h"
#import "PixelEffect.h"

@interface DIYBEffectDialog ()

@end

@implementation DIYBEffectDialog

//============================================================
- (NSString*)windowNibName
{
    return @"DIYBEffectDialog";
}
//============================================================
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _prefData=[DIYBPrefData sharedInstance];
        _lightStorage=[DIYBLightStorage sharedInstance];
        _effects=[PixelEffect allEffects];
    }
    return self;
}

//============================================================
- (void)windowDidLoad
{
    [super windowDidLoad];
    self.gridName=_controller.seqFile.gridNames;
    self.grids=_controller.seqFile.grids;
}
//============================================================
- (IBAction)createButton:(id)sender
{
    if ( [[self window] makeFirstResponder:sender])
    {
        if (_effect.isPattern)
        {
            if(_effect.pattern_light)
            {
                DIYBGrid* grid=[_grids objectForKey:_effect.grid];
                if (grid)
                {
                    NSInteger startMilli=_effect.startMilli;
                    NSInteger endMilli=_effect.endMilli;
                    DIYBTimeEntry* closestStart=[grid closestMilli:startMilli];
                    DIYBTimeEntry* closestEnd=[grid closestMilli:endMilli];
                    if (closestEnd && closestStart && (closestEnd.milli>closestStart.milli))
                    {
                        startMilli=closestStart.milli;
                        endMilli=closestEnd.milli;
                    }
                    if ((startMilli<endMilli )  )
                        //                if ((startMilli<endMilli )  && ((startMilli!=_effect.startMilli) || (_effect.endMilli!=endMilli)))
                    {
                        _effect.startMilli=startMilli;
                        _effect.endMilli=_effect.endMilli;
                        [_effect resetScratch];
                        
                        [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseOK];
                        
                    }
                    else
                    {
                        NSError* error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid times"] forKey:NSLocalizedDescriptionKey]];
                        NSAlert* alert=[NSAlert alertWithError:error] ;
                        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                            
                        }];
                    }
                    
                }
                
            }
            else
            {
                NSError* error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid Pattern"] forKey:NSLocalizedDescriptionKey]];
                NSAlert* alert=[NSAlert alertWithError:error] ;
                [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
                
            }
        }
        else
        {
            if (_effect.endMilli>_effect.startMilli)
            {
                [_effect resetScratch];
                [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseOK];

            }
            else
            {
                NSError* error=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid times"] forKey:NSLocalizedDescriptionKey]];
                NSAlert* alert=[NSAlert alertWithError:error] ;
                [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
            }

        }
        
        
        
    }
    
}
//============================================================
- (IBAction)cancelButton:(id)sender
{
    [[self.window sheetParent] endSheet:self.window returnCode:NSModalResponseCancel];
}
//============================================================
- (void)setSequenceItem:(DIYBSequenceItem *)sequenceItem
{
    _sequenceItem=sequenceItem;
    self.lightGroup=[_lightStorage groupForName:sequenceItem.source];
}
//=============================================================
- (void)setEffect:(DIYBEffectItem *)effect
{
    _effect=effect;
    self.selectedEffect=effect.effect;
}
//=============================================================
- (void)setSelectedEffect:(NSString *)selectedEffect
{
    _selectedEffect=[selectedEffect copy];
    if ([selectedEffect isEqualToString:(NSString*)PatternEffect])
    {
        self.isPattern=YES;
    }
    else
        self.isPattern=NO;
}

//=============================================================
- (IBAction)selectPattern:(id)sender
{
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [panel setTitle:@"Pattern Selection"];
    [panel setPrompt:@"Select"];
    //[panel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:[UTType typeWithFilenameExtension:@"xml"]]];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    NSString* file=[_effect.pattern_light copy];
    NSString* path=[_lightGroup.patternDirectory copy];
    if (file)
    {
        path=[path stringByAppendingPathComponent:file];
        path=[path stringByDeletingLastPathComponent];
    }
    NSURL* url=[[_prefData patternDirectory] URLByAppendingPathComponent:path];
    [panel setDirectoryURL:url];
    if ([panel runModal]==NSModalResponseOK)
    {
        url=[panel URL];
        path=[_lightGroup.patternDirectory copy];
        NSURL* base=[[_prefData patternDirectory] URLByAppendingPathComponent:path];
        
        path=[[url path] stringByReplacingOccurrencesOfString:base.path withString:@""];
        if ([path hasPrefix:@"/"])
        {
            path=[path stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }

        self.effect.pattern_light=path;
    }
    
}
@end
