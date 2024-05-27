// Copyright © 2024 Charles Kerr. All rights reserved.

#ifndef AccessoryVisualController_h
#define AccessoryVisualController_h
#import <Cocoa/Cocoa.h>
@class AccessoryView;
@interface AccessoryVisualController : NSWindowController

@property (strong,nonatomic) NSURL* visualFile ;
@property (strong) NSURL* renderLocation;
@property (assign,nonatomic) CGFloat myscale;
@property (copy,nonatomic) NSString* title;
@property (strong) NSData* lightData ;
@property (assign) NSInteger frameCount;
@property (assign) NSInteger frameLength ;
@property (strong) NSMutableArray* groups ;
@property (assign,nonatomic) NSInteger currentFrame ;
@property (assign,nonatomic) CGFloat currentTime ;

@property (weak) IBOutlet AccessoryView* accessoryView ;
-(void)loadSong:(NSString*) songName ;
-(BOOL)loadVisual:(NSURL*) url ;
-(void)displayFrame:(NSInteger) frameNumber;

@end

#endif /* AccessoryVisual_h */
