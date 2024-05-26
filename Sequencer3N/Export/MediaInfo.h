//
//  MediaInfo.h
//  Sequencer3
//
//  Created by charles on 10/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#ifndef Sequencer3_MediaInfo_h
#define Sequencer3_MediaInfo_h

#include <stdint.h>
#define MEDIA_VERSION 0
typedef struct __attribute__((packed))
{
    uint8_t version;
    float   samplerate;
    uint32_t framecount;
    uint32_t framelength;
} media_header_st;

typedef struct __attribute__((packed))
{
    uint32_t signature ;
    uint32_t version;
    uint32_t dataOffset ;
    
    uint32_t framePeriod ;
    uint32_t framecount;
    uint32_t framelength;
    char name[30] ;
} light_header_st;



#define LIGHT_HEADER_SIZE sizeof(light_header_st)


#endif
