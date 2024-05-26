//
//  DIYBExportItem.m
//  Sequencer3
//
//  Created by charles on 10/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBExportItem.h"
#import "DIYBDocument.h"
#import "DIYBLightGroup.h"
#import "DIYBLightStorage.h"
#import "DIYBLightSource.h"
#import "DIYBSequenceItem.h"

@implementation DIYBExportItem

- (id)initWithSequenceItem:(NSString *)sequenceItem lightSource:(NSString *)lightSource channel:(NSInteger)channel
{
    self=[super init];
    if (self)
    {
        _sequenceItem=[sequenceItem copy];
        _light  =[lightSource copy];
        _channel=channel;
        _offset=-1;
    }
    return self;
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
            if (group && _light)
            {
                _lightSource=[group lightForName:_light];
                
            }
        }
    }
    
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"SequenceItem: %@ LightSource: %@ channel:%ld",_sequenceItem,_light,_channel];
}
@end
