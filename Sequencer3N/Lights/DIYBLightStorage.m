//
//  DIYBLightStorage.m
//  Sequencer3
//
//  Created by charles on 9/5/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import "DIYBLightStorage.h"
#import "DIYBPrefData.h"
#import "DIYBLightGroup.h"

@implementation DIYBLightStorage


//======================================
+ (id)sharedInstance
{
    __strong static id sharedInstance=nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self actualAlloc] initWithNil:nil];
    });
    return sharedInstance;
    
}
//==================================================================
+ (id)actualAlloc
{
    return [super allocWithZone:NULL];
}
//==================================================================
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}
//==================================================================
+ (id)alloc
{
    return [self sharedInstance];
}


//==================================================================
-(id)initWithNil: (id) theNil
{
    self = [super init];
    if (self) {
        // singleton setup...
        _storage=[NSMutableDictionary dictionaryWithCapacity:100];
    }
    return self;
}

//==================================================================
- (id)init {
    return self;
}

//==================================================================
- (id)initWithCoder:(NSCoder *)decoder {
    return self;
}
//==============================================================
- (void)awakeFromNib
{
    [self bind:@"lightFile" toObject:[DIYBPrefData sharedInstance] withKeyPath:@"lightGroupFile" options:nil];
    if (self.lightFile)
    {
        [self loadURL:self.lightFile];
    }
}
//==============================================================
- (void)setLightFile:(NSURL *)lightFile
{
    _lightFile=lightFile;
    [self loadURL:lightFile];
}
//==================================================================
- (void)loadURL:(NSURL*)url
{
    NSError* error=nil;
    NSXMLDocument* xmldoc=[[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&error];
    if (xmldoc)
    {
        NSXMLElement* root=[xmldoc rootElement];
        if ([root.name isEqualToString:@"lightGroups"])
        {
            [_storage removeAllObjects];
            NSArray* array=[root elementsForName:@"lightGroup"];
            for (NSXMLElement* child in array)
            {
                DIYBLightGroup* deco=[[DIYBLightGroup alloc] initWithElement:child];
                [_storage setObject:deco forKey:deco.name];
                
            }
            self.groupNames=[[_storage allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        }
        else
        {
            error=[NSError errorWithDomain:@"Sequencer" code:5 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid light group file, root element is %@ versus lightGroups",root.name] forKey:NSLocalizedDescriptionKey]];
            [[NSAlert alertWithError:error] runModal];
        }
    }
}

//==================================================================
- (void)dealloc
{
    [self unbind:@"lightFile"];
}

//==================================================================
- (DIYBLightGroup*)groupForName:(NSString*)name
{
    return [_storage objectForKey:name];
}
@end
