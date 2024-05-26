//
//  DIYBPrefData.h
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface DIYBPrefData : NSObject
@property (assign,nonatomic) CGFloat frameRate;
@property (assign,nonatomic) NSInteger maxLayer;
@property (assign) BOOL isValid;
@property (strong) NSArray* keys;
@property (strong,nonatomic) NSURL* lightGroupFile;
@property (strong,nonatomic) NSURL* patternDirectory;
@property (strong,nonatomic) NSURL* imageDirectory;
@property (strong,nonatomic) NSURL* mediaDirectory;
@property (strong,nonatomic) NSURL* outputDirectory;
@property (strong,nonatomic) NSURL* visualDirectory;

@property (strong,nonatomic) NSColor* backgroundColor;
@property (strong,nonatomic) NSColor* selectionColor;
@property (strong,nonatomic) NSColor* labelColor;
@property (strong,nonatomic) NSColor* patternNameColor;
@property (strong,nonatomic) NSColor* timeNowColor;
@property (strong,nonatomic) NSColor* separatorColor;
@property (strong,nonatomic) NSColor* lightEffectColor;
@property (strong,nonatomic) NSColor* scratchColor;

@property (assign,nonatomic) CGFloat effectHeight;
@property (assign,nonatomic) CGFloat patternFontSize;

+ (DIYBPrefData*)sharedInstance;
- (BOOL)loadURL:(NSString*)key url:(NSURL**)_url prompt:(NSString*)prompt;
- (BOOL)setURL:(NSString*)key url:(NSURL*)url prompt:(NSString*)prompt;
- (NSMutableArray*)keysWithoutPrompt:(NSString*)prompt;
- (NSError*)error;

- (void)setColor:(NSColor*)color forKeyword:(NSString*)string;
- (NSColor*)getColorForKeyword:(NSString*)string;
@end
