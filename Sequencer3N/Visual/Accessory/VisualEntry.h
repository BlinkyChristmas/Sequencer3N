// Copyright © 2024 Charles Kerr. All rights reserved.

#ifndef VisualEntry_h
#define VisualEntry_h
#import <Cocoa/Cocoa.h>

@class AccessoryVisualController ;

@interface VisualEntry : NSObject

@property (strong) NSURL* visualFile ;
@property (strong) NSURL* renderLocation;
@property (strong) AccessoryVisualController* visualController ;

@end

#endif /* VisualEntry_h */
