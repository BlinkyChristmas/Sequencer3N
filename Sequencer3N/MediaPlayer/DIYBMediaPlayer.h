//
//  DIYBMediaPlayer.h
//  Sequencer3
//
//  Created by charles on 9/1/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVPlayer;
@class AVURLAsset;
@class AVPlayerLayer;

@interface DIYBMediaPlayer : NSObject
//=================== AV items
@property (strong) AVPlayer *player;
@property (strong) AVPlayerLayer *playerLayer;
@property (strong) AVURLAsset *asset;
@property (strong) id timeObserverToken;

//=================== Media Player Items
@property (assign) BOOL isPlaying;
@property (assign) BOOL isLoading;
@property (assign) BOOL isLoaded;
@property (assign) BOOL loadError;
@property (strong,readonly) NSError* error;
@property (assign,readonly) CGFloat duration;
@property (assign,nonatomic) CGFloat currentTime;
@property (assign,nonatomic) CGFloat playBackRate;
@property (assign,nonatomic) CGFloat volume;
@property (assign,nonatomic) BOOL muted;
@property (assign,nonatomic) CGFloat updateRate;
@property (copy,nonatomic) NSString* mediaFile;
@property (copy) NSString*  buttonTitle;
//====================Methods

+ (NSArray*)utis;
- (void)play:(BOOL)state;
- (BOOL)loadURL:(NSURL*)url;
- (IBAction)playAction:(id)sender;
@end
