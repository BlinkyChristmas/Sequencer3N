//
//  DIYBLightStorage.h
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DIYBLightGroup;
@interface DIYBLightStorage : NSObject
@property (strong,nonatomic) NSURL*lightFile;
@property (strong) NSMutableDictionary* storage;
@property (strong) NSArray* groupNames;

- (void)loadURL:(NSURL*)url;
+ (id)sharedInstance;
- (DIYBLightGroup*)groupForName:(NSString*)name;
@end
