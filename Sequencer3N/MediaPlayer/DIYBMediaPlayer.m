//
//  DIYBMediaPlayer.m
//  Sequencer3
//
//  Created by charles on 9/1/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBMediaPlayer.h"
#import <AVFoundation/AVFoundation.h>

static void *AVSPPlayerItemStatusContext = &AVSPPlayerItemStatusContext;
static void *AVSPPlayerRateContext = &AVSPPlayerRateContext;
static void *AVSPPlayerLayerReadyForDisplay = &AVSPPlayerLayerReadyForDisplay;
static void *AVSPPlayerDurationContext = &AVSPPlayerDurationContext;

@interface DIYBMediaPlayer ()

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys;

@end

@implementation DIYBMediaPlayer
@synthesize isPlaying=_isPlaying;
@synthesize isLoading=_isLoading;
@synthesize isLoaded=_isLoaded;
@synthesize error=_error;
@synthesize playBackRate=_playBackRate;
@synthesize updateRate=_updateRate;


//====================================================================
+ (NSArray*)utis
{
    return [AVURLAsset audiovisualTypes];
}

//=======================================================================================
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"player.rate"];
    [self removeObserver:self forKeyPath:@"player.currentItem.status"];
    [self removeObserver:self forKeyPath:@"player.currentItem.duration"];
}

//=======================================================================================
- (id)init
{
    self=[super init];
    if (self)
    {

        //Create the player
        _player=[[AVPlayer alloc] init];
        _player.volume=.25;
        _updateRate=.050;
        _playBackRate=1.0;
        _loadError=NO;
        // We want to be aware when the rate changes and if the status of the player item changes
        [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:AVSPPlayerRateContext];
        [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVSPPlayerItemStatusContext];
        [self addObserver:self forKeyPath:@"player.currentItem.duration" options:NSKeyValueObservingOptionNew context:AVSPPlayerDurationContext];

        // Create the layers
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [_playerLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
        
        self.buttonTitle=@"Play";

    }
    return self;
}

//================================================
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
 	if (context == AVSPPlayerItemStatusContext)
	{
		AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
		BOOL enable = NO;
		switch (status)
		{
			case AVPlayerItemStatusUnknown:
				break;
			case AVPlayerItemStatusReadyToPlay:
				enable = YES;
				break;
			case AVPlayerItemStatusFailed:
                NSLog(@"player item status failed");
				break;
		}
        
		if (enable)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isLoading=NO;
                self.isLoaded=YES;
                self.buttonTitle=@"Play";
                [self willChangeValueForKey:@"currentTime"];
                [self->_player seekToTime:CMTimeMake(0, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                [self didChangeValueForKey:@"currentTime"];

            });
        }
        
	}

    else if (context == AVSPPlayerDurationContext)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self willChangeValueForKey:@"duration"];
            [self didChangeValueForKey:@"duration"];
            
        });
        
    }

    else if (context == AVSPPlayerRateContext)
	{
        __block DIYBMediaPlayer* temp=self;
		float rate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (rate == 0.f)
            {
                if (temp.timeObserverToken)
                {
                    [temp.player removeTimeObserver:self.timeObserverToken];
                    temp.timeObserverToken=nil;
                }
                if (self->_isPlaying)
                {
                    self.buttonTitle=@"Play";
                    self.isPlaying=NO;
                }
            }
            else
            {
                if (!self->_isPlaying)
                {
                    self.buttonTitle=@"Stop";
                    self.isPlaying=YES;
                }
            }
            
        });
        
	}
    
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
}



//============================================================================================
- (BOOL)loadURL:(NSURL *)url
{
    BOOL rvalue=NO;
    _error=nil;
    if (_timeObserverToken)
    {
        [_player removeTimeObserver:_timeObserverToken];
        _timeObserverToken=nil;
    }
    if (_player.rate!= 0.f)
    {
        _player.rate=0;
    }
    
    _asset = [AVURLAsset URLAssetWithURL:url options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]];
    if (_asset)
    {
        rvalue=YES;
        self.isLoaded=NO;
        self.isLoading=YES;
        self.loadError=NO;
        _error=nil;
        NSArray *assetKeysToLoadAndTest = [NSArray arrayWithObjects:@"playable", @"hasProtectedContent", @"tracks", @"duration", nil];

        [_asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
            
            // The asset invokes its completion handler on an arbitrary queue when loading is complete.
            // Because we want to access our AVPlayer in our ensuing set-up, we must dispatch our handler to the main queue.
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [self setUpPlaybackOfAsset:self->_asset withKeys:assetKeysToLoadAndTest];
                
            });
            
        }];

    
    }
    else
    {
        _error=[NSError errorWithDomain:@"DIYBMediaPlayer" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Failed to load %@",[url path]] forKey:NSLocalizedDescriptionKey]];
        self.loadError=YES;
    }
    
    return rvalue;
}

//====================================================================
- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys
{
    
	// This method is called when the AVAsset for our URL has completing the loading of the values of the specified array of keys.
	// We set up playback of the asset here.
	
	// First test whether the values of each of the keys we need have been successfully loaded.
	for (NSString *key in keys)
	{
		NSError* error = nil;
        
		if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed)
		{
            //If we get an error, we failed to load
            _error=error;
            self.isLoading=NO;
            self.loadError=YES;
			return;
		}
	}
    if (![asset isPlayable] || [asset hasProtectedContent])
	{
		_error=[NSError errorWithDomain:@"DIYBMediaPlayer" code:2 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Media was not playable or protected"] forKey:NSLocalizedDescriptionKey]];
        self.isLoading=NO;
        self.loadError=YES;
		return;
	}

    // We loaded!
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.mediaFile=[[[_asset URL] lastPathComponent] copy];
    [_player replaceCurrentItemWithPlayerItem:playerItem];
}
//====================================================================
- (CGFloat)duration
{
    return CMTimeGetSeconds(_player.currentItem.duration);
}
//====================================================================
- (CGFloat)currentTime
{
    CGFloat current;
    current=CMTimeGetSeconds(self.player.currentTime);
    if (isnan(current)!=0)
    {
        current=0;
    }
    return current;
    
}
//====================================================================
- (void)setCurrentTime:(CGFloat)currentTime
{
    [self willChangeValueForKey:@"currentTime"];
    [self.player seekToTime:CMTimeMake(currentTime*1000.0,1000 ) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self didChangeValueForKey:@"currentTime"];
    }];

}
//====================================================================
- (void)setPlayBackRate:(CGFloat)playBackRate
{
    _playBackRate=playBackRate;
    if (_player.rate!=0.f)
    {
        _player.rate=_playBackRate;
    }
}
//====================================================================
- (CGFloat)volume
{
    return _player.volume;
}
//====================================================================
- (void)setVolume:(CGFloat)volume
{
    _player.volume=volume;
}
//====================================================================
- (BOOL)muted
{
    return _player.muted;
}
//====================================================================
- (void)setMuted:(BOOL)muted
{
    _player.muted=muted;
}
//====================================================================
-(void)setUpdateRate:(CGFloat)updateRate
{
    _updateRate=updateRate;
    if (_timeObserverToken)
    {
        [_player removeTimeObserver:_timeObserverToken];
        CMTime time=CMTimeMake(_updateRate*1000, 1000);
        __block DIYBMediaPlayer* temp=self;
        _timeObserverToken=[_player addPeriodicTimeObserverForInterval:time queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [temp willChangeValueForKey:@"currentTime"];
            [temp didChangeValueForKey:@"currentTime"];
        }];
    }
    
    
}

//====================================================================
- (void)play:(BOOL)state
{
    if (state && (_player.rate==0.f))
    {
        CMTime time=CMTimeMake(_updateRate*1000, 1000);
        __block DIYBMediaPlayer* temp=self;
        _timeObserverToken=[_player addPeriodicTimeObserverForInterval:time queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [temp willChangeValueForKey:@"currentTime"];
            [temp didChangeValueForKey:@"currentTime"];
        }];
        
        _player.rate=_playBackRate;
    }
    else if (!state && (_player.rate!=0.f))
    {
        _player.rate=0.f;
    }
        
}
//====================================================================
- (IBAction)playAction:(id)sender
{
    if (_isPlaying)
    {
        [self play:NO];
    }
    else
        [self play:YES];
}
@end
