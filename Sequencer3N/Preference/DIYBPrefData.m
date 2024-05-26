//
//  DIYBPrefData.m
//  Sequencer2
//
//  Created by charles on 8/17/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBPrefData.h"
#import "NSColor+Serialization.h"
#import "PixelEffect.h"
@implementation DIYBPrefData
@synthesize frameRate=_frameRate;
@synthesize keys=_keys;
@synthesize isValid=_isValid;
@synthesize lightGroupFile=_lightGroupFile;
@synthesize patternDirectory=_patternDirectory;
@synthesize mediaDirectory=_mediaDirectory;
@synthesize outputDirectory=_outputDirectory;
@synthesize visualDirectory=_visualDirectory;
@synthesize maxLayer=_maxLayer;

@synthesize backgroundColor=_backgroundColor;
@synthesize labelColor=_labelColor;
@synthesize patternNameColor=_patternNameColor;
@synthesize separatorColor=_separatorColor;
@synthesize timeNowColor=_timeNowColor;
@synthesize selectionColor=_selectionColor;
@synthesize lightEffectColor=_lightEffectColor;

@synthesize scratchColor=_scratchColor;

@synthesize effectHeight=_effectHeight;
@synthesize patternFontSize=_patternFontSize;
//======================================
+ (DIYBPrefData*)sharedInstance
{
    __strong static id sharedInstance=nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedInstance = [[DIYBPrefData actualAlloc] initWithNil:nil];
    });
    return sharedInstance;

}
//======================================
+ (id)actualAlloc
{
    return [super allocWithZone:NULL]; //this is important, because otherwise the object wouldn't be allocated
}
//======================================
+ (id)allocWithZone:(NSZone *)zone {
    return [DIYBPrefData sharedInstance];
}

//======================================
+ (id)alloc
{
    return [DIYBPrefData sharedInstance];
}

//======================================
-(id)initWithNil: (id) theNil
{
    self = [super init];
    if (self) {
        // singleton setup...
        [self loadPreferences];
        if (self.error)
        {
            NSAlert* alert=[NSAlert alertWithError:self.error];
            [alert runModal];
        }
    }
    return self;
}

//======================================
- (id)init {
    return self;
}

//=================================================
- (BOOL)loadURL:(NSString*)key url:(NSURL**)_url prompt:(NSString*)prompt
{
    
    BOOL rvalue=NO;
    BOOL stale;
    NSError *error;
    
    NSUserDefaults* user=[NSUserDefaults standardUserDefaults];
    NSData * data=[user objectForKey:key];
    if (data)
    {
        *_url= [NSURL URLByResolvingBookmarkData:data
                                         options:NSURLBookmarkResolutionWithSecurityScope
                                         relativeToURL:nil
                                         bookmarkDataIsStale:&stale
                                         error:&error  ];
        
        if (*_url!=nil)
        {
            if (!stale)
            {
                rvalue = [*_url startAccessingSecurityScopedResource];
                
            }
            else
            {
                data=[*_url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope  includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
            }
        }
    }
    NSMutableArray* temp=[self keysWithoutPrompt:prompt];
    if (!rvalue)
    {
        [temp addObject:prompt];
    }
    self.keys=temp;
    if (temp.count>0)
    {
        self.isValid=NO;
    }
    else
        self.isValid=YES;
    return rvalue;
}
//=================================================
- (BOOL)setURL:(NSString*)key url:(NSURL*)url prompt:(NSString*)prompt
{
    
    BOOL rvalue=YES;
    NSError *error=nil;
    
    NSData* data=nil;
    if (url)
    {
        data=[url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope  includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
        if (!data)
        {
            rvalue=NO;
            url=nil;
        }
        else
        {
            [url startAccessingSecurityScopedResource];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    NSMutableArray* temp=[self keysWithoutPrompt:prompt];
    if (!rvalue)
    {
        [temp addObject:prompt];
    }
    self.keys=temp;
    if (temp.count>0)
    {
        self.isValid=NO;
    }
    else
        self.isValid=YES;
    
    return rvalue;
}


///======================================
- (BOOL)loadPreferences
{
    BOOL rvalue=YES;
    NSUserDefaults* user=[NSUserDefaults standardUserDefaults];
    NSURL* url;

    if ([self loadURL:@"LIGHTGROUPFILE" url:&url prompt:@"Light Group File"])
    {
        _lightGroupFile=url;
    }
    else
    {
        _lightGroupFile=url;
        rvalue=NO;
    }
    
    if ([self loadURL:@"VISUALDIRECTORY" url:&url prompt:@"Visual Directory"])
    {
        _visualDirectory=url;
    }
    else
    {
        _visualDirectory=url;
        rvalue=NO;
    }
    
    if ([self loadURL:@"PATTERNDIRECTORY" url:&url prompt:@"Pattern Directory"])
    {
        _patternDirectory=url;
    }
    else
    {
        _patternDirectory=url;
        rvalue=NO;
    }
    if ([self loadURL:@"IMAGEDIRECTORY" url:&url prompt:@"Image Directory"])
    {
        _imageDirectory=url;
    }
    else
    {
        _imageDirectory=url;
        rvalue=NO;
    }
    if ([self loadURL:@"MEDIADIRECTORY" url:&url prompt:@"Music/Media Directory"])
    {
        _mediaDirectory=url;
    }
    else
    {
        _mediaDirectory=url;
        rvalue=NO;
    }
    /*
    if ([self loadURL:@"OUTPUTDIRECTORY" url:&url prompt:@"Output Directory"])
    {
        _outputDirectory=url;
    }
    else
    {
        _outputDirectory=url;
        rvalue=NO;
    }
*/
    _lightEffectColor=[self getColorForKeyword:@"LIGHTEFFECTCOLOR"];
    _backgroundColor=[self getColorForKeyword:@"BACKGROUNDCOLOR"];
    _labelColor=[self getColorForKeyword:@"LABELCOLOR"];
    _patternNameColor=[self getColorForKeyword:@"PATTERNNAMECOLOR"];
    _separatorColor=[self getColorForKeyword:@"SEPARATORCOLOR"];
    _timeNowColor=[self getColorForKeyword:@"TIMENOWCOLOR"];
    _selectionColor=[self getColorForKeyword:@"SELECTIONCOLOR"];
    _scratchColor=[self getColorForKeyword:@"SCRATCHCOLOR"];
    
    _frameRate=[user doubleForKey:@"FRAMERATE"];
    if (_frameRate<.025)
    {
        _frameRate=.025;
    }
    _maxLayer=[user integerForKey:@"MAXLAYER"];
    if (_maxLayer<5)
    {
        _maxLayer=5;
    }
    _effectHeight   =[user doubleForKey:@"EFFECTHEIGHT"];
    if (_effectHeight==0)
    {
        _effectHeight=28.0;
    }
    _patternFontSize   =[user doubleForKey:@"PATTERNFONTSIZE"];
    if (_patternFontSize==0)
    {
        _patternFontSize=12.0;
    }

    return rvalue;
}
//======================================
- (void)setFrameRate:(CGFloat)frameRate
{
    NSUserDefaults* user=[NSUserDefaults standardUserDefaults];
    [user setDouble:frameRate forKey:@"FRAMERATE"];
    _frameRate=frameRate;
}
//======================================
- (void)setMaxLayer:(NSInteger)maxLayer
{
    NSUserDefaults* user=[NSUserDefaults standardUserDefaults];
    [user setInteger:maxLayer forKey:@"MAXLAYER"];
    _maxLayer=maxLayer;
}
//===========================================================
- (void)setEffectHeight:(CGFloat)effectHeight
{
    NSUserDefaults* user=[NSUserDefaults standardUserDefaults];
    [user setInteger:effectHeight forKey:@"EFFECTHEIGHT"];
    _effectHeight=effectHeight;
    
}
//===========================================================
- (void)setPatternFontSize:(CGFloat)patternFontSize
{
    _patternFontSize=patternFontSize;
    NSUserDefaults* user=[NSUserDefaults standardUserDefaults];
    [user setDouble:patternFontSize forKey:@"PATTERNFONTSIZE"];
    
}
//============================================================
- (void)setLightGroupFile:(NSURL *)lightGroupFile
{
    
    if (_lightGroupFile)
    {
        [_lightGroupFile stopAccessingSecurityScopedResource];
    }
    
    _lightGroupFile=lightGroupFile;
    if (![self setURL:@"LIGHTGROUPFILE" url:_lightGroupFile prompt:@"Light Group File"])
    {
        _lightGroupFile=nil;
    }
}
//===========================================================
- (void)setPatternDirectory:(NSURL *)patternDirectory
{
    if (_patternDirectory)
    {
        [_patternDirectory stopAccessingSecurityScopedResource];
    }
    
    _patternDirectory=patternDirectory;
    if (![self setURL:@"PATTERNDIRECTORY" url:patternDirectory prompt:@"Pattern Directory"])
    {
        _patternDirectory=nil;
    }
    
}
//===========================================================
- (void)setVisualDirectory:(NSURL *)patternDirectory
{
    if (_visualDirectory)
    {
        [_visualDirectory stopAccessingSecurityScopedResource];
    }
    
    _visualDirectory=patternDirectory;
    if (![self setURL:@"VISUALDIRECTORY" url:patternDirectory prompt:@"Visual Directory"])
    {
        _visualDirectory=nil;
    }
    
}

//===========================================================
- (void)setImageDirectory:(NSURL *)imageDirectory
{
    if (_imageDirectory)
    {
        [_imageDirectory stopAccessingSecurityScopedResource];
    }
    
    _imageDirectory=imageDirectory;
    if (![self setURL:@"IMAGEDIRECTORY" url:imageDirectory prompt:@"Image Directory"])
    {
        _imageDirectory=nil;
    }
    
}
//===========================================================
- (void)setMediaDirectory:(NSURL *)mediaDirectory
{
    if (_mediaDirectory)
    {
        [_mediaDirectory stopAccessingSecurityScopedResource];
    }
    
    _mediaDirectory=mediaDirectory;
    if (![self setURL:@"MEDIADIRECTORY" url:mediaDirectory prompt:@"Music/Media Directory"])
    {
        _mediaDirectory=nil;
    }
    
}
//===========================================================
- (void)setOutputDirectory:(NSURL *)outputDirectory
{
    if (_outputDirectory)
    {
        [_outputDirectory stopAccessingSecurityScopedResource];
    }
    
    _outputDirectory=outputDirectory;
    if (![self setURL:@"OUTPUTDIRECTORY" url:outputDirectory prompt:@"Output Directory"])
    {
        _outputDirectory=nil;
    }
    
}

//===========================================================
- (NSMutableArray*)keysWithoutPrompt:(NSString*)prompt
{
    NSMutableArray* temp=[NSMutableArray arrayWithCapacity:5];
    for (NSString* value in _keys)
    {
        if (![value isEqualToString:prompt])
        {
            [temp addObject:value];
        }
    }
    return temp;
  
}
//===========================================================
- (NSError*)error
{
    NSError* error=nil;
    if (self.keys.count>0)
    {
        NSString* errMsg=@"Invalid preference locations: ";
        NSInteger count=0;
        for (NSString* value in self.keys)
        {
            errMsg=[errMsg stringByAppendingString:value];
            count++;
            if (count<self.keys.count)
            {
                errMsg=[errMsg stringByAppendingString:@", "];
            }
        }
        error=[NSError errorWithDomain:@"Sequencer2" code:3 userInfo:[NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey]];
    }
    return error;
}
//=============================================================
- (void)setColor:(NSColor*)color forKeyword:(NSString*)string
{
    [[NSUserDefaults standardUserDefaults] setObject:[color stringValue] forKey:string];
}
//=============================================================
- (NSColor*)getColorForKeyword:(NSString*)string
{
    NSColor* color=[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    NSString* object=[[NSUserDefaults standardUserDefaults] objectForKey:string];
    if (object)
    {
        color=[NSColor colorForString:object];
    }
    return color;
}
//==============================================================
- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor=backgroundColor;
    [self setColor:backgroundColor forKeyword:@"BACKGROUNDCOLOR"];
}
//==============================================================
- (void)setLabelColor:(NSColor *)labelColor
{
    _labelColor=labelColor;
    [self setColor:labelColor forKeyword:@"LABELCOLOR"];
}
//==============================================================
- (void)setSeparatorColor:(NSColor *)separatorColor
{
    _separatorColor=separatorColor;
    [self setColor:separatorColor forKeyword:@"SEPARATORCOLOR"];
}
//==============================================================
- (void)setTimeNowColor:(NSColor *)timeNowColor
{
    _timeNowColor=timeNowColor;
    [self setColor:timeNowColor forKeyword:@"TIMENOWCOLOR"];
}
//==============================================================
- (void)setSelectionColor:(NSColor *)selectionColor
{
    _selectionColor=selectionColor;
    [self setColor:selectionColor forKeyword:@"SELECTIONCOLOR"];
}
//==============================================================
- (void)setLightEffectColor:(NSColor *)lightEffectColor
{
    _lightEffectColor=lightEffectColor;
    [self setColor:lightEffectColor forKeyword:@"LIGHTEFFECTCOLOR"];
}
//==============================================================
- (void)setPatternNameColor:(NSColor *)patternNameColor
{
    _patternNameColor=patternNameColor;
    [self setColor:patternNameColor forKeyword:@"PATTERNNAMECOLOR"];
}

//==============================================================
- (void)setScratchColor:(NSColor *)scratchColor
{
    _scratchColor=scratchColor;
    [self setColor:scratchColor forKeyword:@"SCRATCHCOLOR"];
}

@end
