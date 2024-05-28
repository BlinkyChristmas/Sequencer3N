// Copyright © 2024 Charles Kerr. All rights reserved.

#import <Foundation/Foundation.h>
#import "AccessoryVisualController.h"
#import "../../Export/MediaInfo.h"
#import "../DIYBVisualGroup.h"
#import "AccessoryView.h"
@implementation AccessoryVisualController

- (NSString*)windowNibName
{
    return @"AccessoryVisual";
}

//================================================================================================
- (void)setVisualFile:(NSURL *)visualFile {
    _visualFile = visualFile;
    if (_visualFile) {
        [self loadVisual:_visualFile] ;
        NSString* temp = [[_visualFile URLByDeletingPathExtension] lastPathComponent] ;
        [[self window] setTitle:temp] ;
    }
}

//================================================================================================
-(void) setCurrentTime:(CGFloat)currentTime {
    _currentTime = currentTime ;
    NSInteger frame = (NSInteger) (currentTime/0.037) ;
    [self setCurrentFrame:frame] ;
}

//================================================================================================
- (void)setScale:(CGFloat)myscale
{
    _myscale = myscale;
    
}
- (void) setCurrentFrame:(NSInteger)currentFrame {
    _currentFrame = currentFrame ;
    [_accessoryView setNeedsDisplay:YES] ;
}
//================================================================================================
- (CGFloat)myscale {
    return _myscale ;
}
//================================================================================================
- (void)windowDidLoad{
    if (_visualFile) {
        NSString* temp = [[_visualFile URLByDeletingPathExtension] lastPathComponent] ;
        [[self window] setTitle:temp] ;
    }
}

// =============================================================================================
- (void)dealloc {
    [self unbind:@"currentTime"];
}
//================================================================================================
- (void)loadSong:(NSString *)songName {
    
    NSURL* url = [_renderLocation URLByAppendingPathComponent:songName] ;
    url = [url URLByAppendingPathExtension:@"light"] ;
    _frameCount = 0 ;
    _frameLength = 0 ;
    _lightData = [[NSData alloc] init] ;
    NSData* data = [NSData dataWithContentsOfURL:url] ;
    if (data) {
        const char* bytes = [data bytes] ;
        // Get the data offset
        NSUInteger utemp  = 0 ;
        memcpy(&utemp, bytes + 8 , 4) ;
        NSUInteger offset = utemp ;
        // Get frame count and length
        NSInteger temp = 0 ;
        memcpy(&temp, bytes + 32 , 4) ;
        _frameCount = temp ;
        memcpy(&temp, bytes + 36 , 4) ;
        _frameLength = temp ;
        // Get the light data
        _lightData = [NSData dataWithBytes:bytes+offset length:[data length] - offset] ;
    }
}

//================================================================================================
-(BOOL)loadVisual:(NSURL*) url {
    NSXMLDocument* xmldoc=[[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:NULL];
    BOOL rvalue=NO;
    if (xmldoc)
    {
        rvalue = YES ;
        NSMutableArray* array=[NSMutableArray arrayWithCapacity:20];
        NSArray* children=[[xmldoc rootElement] elementsForName:@"visualGroup"];
        for (NSXMLElement* child in children)
        {
            DIYBVisualGroup* group=[[DIYBVisualGroup alloc] initWithElement:child];
            [array addObject:group];
        }
        [self setGroups:array ] ;
        //Just check to see if there is a scale we should default to
        NSXMLNode* node=[[xmldoc rootElement] attributeForName:@"scale"];
        if (node)
        {
            self.myscale=[[node stringValue] doubleValue];
        }

        if ([[self window] isVisible])
        {
            [_accessoryView setNeedsDisplay:YES] ;
        }
        rvalue=YES;

    }
    return rvalue;
}
- (void)setSequenceOffsets:(NSDictionary *)sequenceOffsets {
    _sequenceOffsets = sequenceOffsets ;
    
}
/*
//==============================================================================
- (void)updateSequence
{
    for (DIYBVisualGroup* group in groups)
    {
        [group updateOffsets:_sequenceOffsets document:_sequenceDocument];
    }
    [self.visualView setNeedsDisplay:YES];
    
}
//=========================================================================================
- (void)configureLightForDocument:(DIYBDocument*)document
{
    if (_sequenceItem)
    {
        DIYBSequenceItem* item=[document itemForName:_sequenceItem];
        if (item)
        {
            DIYBLightGroup* group=[[DIYBLightStorage sharedInstance] groupForName:item.source];
            if (group && _lightSource)
            {
                _light=[group lightForName:_lightSource];
            }
        }
    }

}
*/
//================================================================================================
- (void)displayFrame:(NSInteger)frameNumber {
    if (frameNumber < _frameCount) {
        
    }
}

@end
