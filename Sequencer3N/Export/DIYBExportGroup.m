//
//  DIYBExportGroup.m
//  Sequencer3
//
//  Created by charles on 10/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBExportGroup.h"
#import "DIYBExportItem.h"
#import "DIYBLightGroup.h"
#import "DIYBLightSource.h"
#import "DIYBLightStorage.h"
#import "DIYBSequenceItem.h"
#import "DIYBDocument.h"
#import "MediaInfo.h"

@interface DIYBExportGroup ()
- (DIYBExportItem*)parseString:(NSString*)line;
@end

@implementation DIYBExportGroup

//===============================================================
- (BOOL)loadExportURL:(NSURL *)url
{
    BOOL rvalue=NO;
    NSMutableSet* set=[NSMutableSet setWithCapacity:100];
    NSString* string=[NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:NULL];
    if (string)
    {
        _highestChannel=0;
        NSArray* array=[string componentsSeparatedByString:@"\n"];
        //NSLog(@"Array count is %ld",array.count);
        for (NSString* line in array)
        {
            DIYBExportItem* item=[self parseString:line];
            if (item)
            {
                [set addObject:item];
                if (_highestChannel<item.channel)
                {
                    _highestChannel=item.channel;
                }
                
            }
        }
        if (set.count>0)
        {
            _exportedItems=set;
            rvalue=YES;
        }
        
    }
    
    return rvalue;
}
//===============================================================
- (DIYBExportItem*)parseString:(NSString*)line
{
    NSCharacterSet* whitespace=[NSCharacterSet whitespaceCharacterSet];
    NSScanner* scanner=[NSScanner scannerWithString:line];
    DIYBExportItem* item=nil;
    [scanner scanCharactersFromSet:whitespace intoString:NULL];
    NSString* sequenceItem;
    NSString* lightSource;
    NSInteger channel;
    [scanner scanUpToCharactersFromSet:whitespace intoString:&sequenceItem];
    [scanner scanCharactersFromSet:whitespace intoString:NULL];
    [scanner scanUpToCharactersFromSet:whitespace intoString:&lightSource];
    [scanner scanCharactersFromSet:whitespace intoString:NULL];
    [scanner scanInteger:&channel];
    if (sequenceItem && lightSource && (channel>0))
    {
        item=[[DIYBExportItem alloc] initWithSequenceItem:sequenceItem lightSource:lightSource channel:channel];
    }
    return item;
}
//=======================================================================
- (NSInteger)frameLength
{
    NSSortDescriptor* descrip=[NSSortDescriptor sortDescriptorWithKey:@"channel" ascending:NO];
    NSArray * array=[_exportedItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:descrip]];
    DIYBExportItem* item=[array firstObject];
    NSInteger length=0;
    if (item)
    {
        length=item.channel+5;
        length=length/4;
        length=length*4;
    }
    return length;
}

#if 1
//==========================================================================
- (NSData*)formatData:(NSData*)data frameRate:(CGFloat)rate frameLength:(NSInteger)frameLength sequenceOffsets:(NSDictionary*)sequenceOffset document:(DIYBDocument*)document
{
    NSInteger headerSize=sizeof(light_header_st);
    NSInteger framecount=data.length/frameLength;
    NSMutableData* newdata=[NSMutableData dataWithLength:data.length + headerSize];
    // update the header information
    light_header_st header ;
    header.signature = 0x5448474c ;
    header.version=0;
    header.dataOffset = 54 ;
    header.framePeriod = (uint32_t)(1000.0 * rate );
    header.framecount=(uint32_t)framecount;
    header.framelength=(uint32_t)frameLength;
    NSString* temp = [[document media] stringByReplacingOccurrencesOfString:@".mov" withString:@""] ;
    temp= [temp stringByReplacingOccurrencesOfString:@".wav" withString:@""] ;
    char buffer[31] ;
    memset(buffer, 0, 31);
    if ([temp getCString:buffer maxLength:30 encoding:NSASCIIStringEncoding]) {
        memcpy(header.name, buffer, 30);
    }
    char * newptr = [newdata mutableBytes] ;
    memcpy(newptr,&header.signature,4) ;
    
    memcpy(newptr+4,&header.version,4) ;
    memcpy(newptr+8,&header.dataOffset,4) ;
    memcpy(newptr+12,&header.framePeriod,4) ;
    memcpy(newptr+16,&header.framecount,4) ;
    memcpy(newptr+20,&header.framelength,4) ;
    memcpy(newptr+24,&header.name,30) ;
    memcpy(newptr+54, [data bytes], data.length);
    return newdata ;


}
#else
//==========================================================================
- (NSData*)formatData:(NSData*)data frameRate:(CGFloat)rate frameLength:(NSInteger)frameLength sequenceOffsets:(NSDictionary*)sequenceOffset document:(DIYBDocument*)document
{
    [self updateOffsets:sequenceOffset document:document];
    
    NSMutableData* newdata=nil;
    NSInteger newlength=[self highestChannel];
    if (data && (frameLength>0))
    {
        if (newlength>0)
        {
            NSInteger framecount=data.length/frameLength;
            // get the size of the header
#if 1
            NSInteger headerSize=sizeof(light_header_st);
            newdata=[NSMutableData dataWithLength:(framecount*newlength) + headerSize];
            
            // update the header information
            light_header_st* header=[newdata mutableBytes];
            header->signature = 0x5448474c ;
            header->version=0;
            header->dataOffset = 54 ;
            header->framePeriod = (uint32_t)(1000.0 * rate );
            header->framecount=(uint32_t)framecount;
            header->framelength=(uint32_t)newlength;
            NSString* temp = [[document media] stringByReplacingOccurrencesOfString:@".mov" withString:@""] ;
            temp= [temp stringByReplacingOccurrencesOfString:@".wav" withString:@""] ;
            char buffer[31] ;
            memset(buffer, 0, 31);
            if ([temp getCString:buffer maxLength:30 encoding:NSASCIIStringEncoding]) {
                memcpy(header->name, buffer, 30);
            }

#else
            NSInteger headerSize=sizeof(media_header_st);
            newdata=[NSMutableData dataWithLength:(framecount*newlength) + headerSize];
            
            // update the header information
            media_header_st* header=[newdata mutableBytes];
            header->version=0;
            header->framecount=(uint32_t)framecount;
            header->framelength=(uint32_t)newlength;
            header->samplerate=(float)rate;
#endif
            // populate the data
            NSInteger frameindex;
            for (frameindex=0; frameindex<framecount; frameindex++)
            {
                for (DIYBExportItem* item in _exportedItems)
                {
                    if (item.offset>=0)
                    {
                        NSInteger bytesToCopy=item.lightSource.channelCount;
                        const char* olddata=data.bytes+(frameindex*frameLength) + item.offset;
                        char * newptr=[newdata mutableBytes] + (frameindex*newlength) +headerSize + item.channel-1;
                        memcpy(newptr, olddata, bytesToCopy);
                        
                    }
                }
                
            }
            
        }
    }
    return newdata;
}
#endif
//=====================================================================================
- (void)updateOffsets:(NSDictionary*)sequenceOffsets document:(DIYBDocument *)document
{
    for (DIYBExportItem* item in _exportedItems)
    {
        if (item.sequenceItem)
        {
            NSNumber* number=[sequenceOffsets objectForKey:item.sequenceItem];
            if (number)
            {
                [item configureLightForDocument:document];
                item.offset=number.integerValue + item.lightSource.channelOffset;
                

                
            }
            else
            {
                item.offset=-1;
            }
        }
        else
        {
            item.offset=-1;
            
        }
    }
}

@end
