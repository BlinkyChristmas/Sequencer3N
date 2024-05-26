//
//  DIYBDocument.m
//  Sequencer3
//
//  Created by charles on 9/1/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBDocument.h"
#import "DIYBWindowController.h"
#import "NSXMLDocument+Beautify.h"
#import "DIYBPrefData.h"
#import "DIYBGrid.h"
#import "DIYBSequenceItem.h"
#import "DIYBLightGroup.h"
#import "DIYBLightStorage.h"

@interface DIYBDocument ()

@end

@implementation DIYBDocument
@synthesize seqDocument=_seqDocument;
//=======================================================================================
- (id)init
{
    self = [super init];
    if (self) {
        _rootElement=[NSXMLElement elementWithName:@"sequence"];
        _seqDocument=[[NSXMLDocument alloc] initWithRootElement:_rootElement];
        [_seqDocument setCharacterEncoding:@"UTF-8"];
        [_seqDocument setVersion:@"1.0"];
        
        _gridContainer=[NSXMLElement elementWithName:@"timingGrids"];
        [_rootElement addChild:_gridContainer];
        _grids=[NSMutableDictionary dictionaryWithCapacity:10];
        _sequenceItems=[NSMutableSet setWithCapacity:200];
    }
    return self;
}
//=======================================================================================
- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}
//=======================================================================================
- (void)makeWindowControllers
{
    [self addWindowController:[[DIYBWindowController alloc] init]];
}

//=======================================================================================
+ (BOOL)autosavesInPlace
{
    return YES;
}

//=======================================================================================
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData* data=nil;
    if ([typeName isEqualToString:@"com.diybllc.sequence"] || [typeName isEqualToString:@"diybseq"])
    {
        data=[_seqDocument prettyXMLWithError:outError];
    }
    else if (outError)
    {
        *outError=[NSError errorWithDomain:@"Sequencer" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid type: %@",typeName] forKey:NSLocalizedDescriptionKey]];
    }
    
    return data;
}

//=======================================================================================
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL rvalue=NO;
    if ([typeName isEqualToString:@"com.diybllc.sequence"] || [typeName isEqualToString:@"diybseq"])
    {
        NSXMLDocument* xmldoc=[[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyXML error:outError];
        if (xmldoc)
        {
            if ([[[xmldoc rootElement] name] isEqualToString:@"sequence"])
            {
                _rootElement=[xmldoc rootElement];
                rvalue=YES;
                _seqDocument=xmldoc;
                NSArray* array=[_rootElement elementsForName:@"timingGrids"];
                if (array.count==0)
                {
                    _gridContainer=[NSXMLElement elementWithName:@"timingGrids"];
                    [_rootElement addChild:_gridContainer];
                }
                else
                {
                    _gridContainer=[array firstObject];
                    
                    // Get any timing grids we have
                    NSArray* array=[_gridContainer elementsForName:@"timingGrid"];
                    for (NSXMLElement* child in array)
                    {
                        DIYBGrid* grid=[[DIYBGrid alloc] initWithElement:child];
                        [_grids setObject:grid forKey:grid.name];
                    }
                    self.gridNames=[[_grids allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
                    
                }
                array=[_rootElement elementsForName:@"sequenceItem"];
                DIYBLightStorage* storage=[DIYBLightStorage sharedInstance];
                NSInteger channelOffset=0;
                // We should process the sequence items here;
                NSInteger order=0;
                for (NSXMLElement* child in array)
                {
                    DIYBSequenceItem* item=[[DIYBSequenceItem alloc] initWithElement:child];
                    [_sequenceItems addObject:item];
                    item.displayOrder=order;
                    item.applyOrder=order;
                    order++;
                    item.channelOffset=channelOffset;
                    DIYBLightGroup* group=[storage groupForName:item.source];
                    if (!group)
                    {
                        if (outError)
                        {
                            *outError=[NSError errorWithDomain:@"Sequencer" code:44 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Sequence item %@ and invalid source %@",item.name,item.source] forKey:NSLocalizedDescriptionKey]];
                        }
                        rvalue=NO;
                        break;
                    }
                    else
                    {
                        channelOffset+=group.channelCount;
                    }
                }
                // Check our media file and frame rate
                [self willChangeValueForKey:@"frameRate"];
                [self didChangeValueForKey:@"frameRate"];
                [self willChangeValueForKey:@"media"];
                [self didChangeValueForKey:@"media"];

                
            }
            else if (outError)
            {
                *outError=[NSError errorWithDomain:@"Sequencer" code:2 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid root element in sequence file: %@",[xmldoc rootElement].name] forKey:NSLocalizedDescriptionKey]];
            }
        }
        
    }
    else if(outError)
    {
        *outError=[NSError errorWithDomain:@"Sequencer" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid type: %@",typeName] forKey:NSLocalizedDescriptionKey]];
    }
    return rvalue;
}

//=========================================================================================================
- (CGFloat)frameRate
{
    NSXMLNode* node=[_rootElement attributeForName:@"frameRate"];
    CGFloat rvalue=0;
    if (node)
    {
        rvalue=[[node stringValue] doubleValue];
    }
    return rvalue;
}
//=========================================================================================================
- (void)setFrameRate:(CGFloat)frameRate
{
    NSXMLNode* node=[_rootElement attributeForName:@"frameRate"];
    if (node)
    {
        [node setStringValue:[NSString stringWithFormat:@"%.3f",frameRate]];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"frameRate" stringValue:[NSString stringWithFormat:@"%.3f",frameRate]];
        [_rootElement addAttribute:node];
    }
    
}
//============================================================================================================
- (NSString*)media
{
    NSXMLNode* node=[_rootElement attributeForName:@"media"];
    NSString* rvalue=nil;
    if (node)
    {
        rvalue = [[[node stringValue] stringByReplacingOccurrencesOfString:@".mov" withString:@".wav"] stringByReplacingOccurrencesOfString:@" "  withString:@"_"] ;
        //rvalue = [rvalue stringByReplacingOccurrencesOfString:@".mov" withString:@".wav"];
    }
    return [rvalue copy];
}
//============================================================================================================
- (void)setMedia:(NSString*)media
{
    NSXMLNode* node=[_rootElement attributeForName:@"media"];
    if (node)
    {
        [node setStringValue:media];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"media" stringValue:media];
        [_rootElement addAttribute:node];
        
    }
}

//=============================================================================================================
- (void)addGrid:(DIYBGrid*)grid
{
    [_grids setObject:grid forKey:grid.name];
    [_gridContainer addChild:grid.element];
    self.gridNames=[[_grids allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
//=============================================================================================================
- (void)removeGrid:(DIYBGrid*)grid
{
    [grid.element detach];
    [_grids removeObjectForKey:grid.name];
    self.gridNames=[[_grids allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

}
//==============================================================================================================
- (DIYBSequenceItem*)itemForName:(NSString*)name
{
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"name==%@",name];
    return [[_sequenceItems filteredSetUsingPredicate:predicate] anyObject ];
}
//==============================================================================================================
- (void)addSequenceItem:(DIYBSequenceItem*)item
{
    [_rootElement addChild:item.element];
    [_sequenceItems addObject:item] ;
}
//====================================================================================================
- (void)removeSequenceItem:(DIYBSequenceItem *)item
{
    [_sequenceItems removeObject:item];
    [item.element detach];
}
//====================================================================================================
- (NSMutableData*)blankDataForSequence:(NSInteger*)frameLength count:(NSInteger*)frameCount
{
    NSMutableData* data=nil;
    NSInteger channelOffset=0;
    NSInteger length=0;
    NSInteger maxMilli=0;
    NSMutableDictionary* dict=[NSMutableDictionary dictionaryWithCapacity:100];
    *frameCount=0;
    *frameLength=0;
    NSSortDescriptor* desc=[NSSortDescriptor sortDescriptorWithKey:@"applyOrder" ascending:YES];
    NSArray* array=[_sequenceItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];

    for (DIYBSequenceItem* item in array)
    {
        item.channelOffset=channelOffset;
        [dict setObject:[NSNumber numberWithInteger:channelOffset] forKey:item.name];
        length+=item.length;
        channelOffset+=item.length;
        NSInteger milli=item.endMilli;
        if (milli>maxMilli)
        {
            maxMilli=milli;
        }
        
    }
    length+=3;
    length=length/4;
    length=length*4;
    NSInteger rate=self.frameRate*10000;
    rate=rate/10;
    NSInteger count=(maxMilli+rate-1)/rate;
    if (length>0 && count>0)
    {
        *frameLength=length;
        data=[NSMutableData dataWithLength:length*count];
        *frameCount=count;
    }
    self.sequenceOffsets=dict;
    return data;
}


//======================================================================
- (NSMutableData*)renderDataWithImage:(DIYBImageCache*)imageCache pattern:(DIYBURLCache*)patternCache frameLength:(NSInteger*)frameLength frameCount:(NSInteger *)frameCount error:(NSError* __autoreleasing*)error
{
    
    NSInteger rate=self.frameRate*10000;
    rate=rate/10;
    NSMutableData* data=[self blankDataForSequence:frameLength count:frameCount];
    NSSortDescriptor* desc=[NSSortDescriptor sortDescriptorWithKey:@"applyOrder" ascending:YES];
    NSArray* array=[_sequenceItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    for (DIYBSequenceItem* item in array)
    {
        [item renderData:data frameLength:*frameLength rate:rate imageCache:imageCache patternCache:patternCache grids:_grids offset:item.channelOffset error:error];
        if (error)
        {
            if(*error)
            {
                break;
            }
        }
    }
    return data;
}
//======================================================================
- (NSString*)visualization
{
    NSString* rvalue=nil;
    NSXMLNode* node=[_rootElement attributeForName:@"visualization"];
    if (node)
    {
        rvalue=[[node stringValue] copy];
    }
    return rvalue;
}
//======================================================================
- (void)setVisualization:(NSString *)visualization
{
    NSXMLNode* node=[_rootElement attributeForName:@"visualization"];
    if (node)
    {
        [node setStringValue:[visualization copy]];
    }
    else
    {
        node=[NSXMLNode attributeWithName:@"visualization" stringValue:[visualization copy]];
        [_rootElement addAttribute:node];
    }
}
@end
