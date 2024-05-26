//
//  DIYBEffectDialog.h
//  Sequencer3
//
//  Created by charles on 9/7/14.
//  Copyright (c) 2014 DIYB LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
@class DIYBEffectItem;
@class DIYBPrefData;
@class DIYBLightGroup;
@class DIYBLightStorage;
@class DIYBSequenceItem;
@class DIYBWindowController;
@interface DIYBEffectDialog : NSWindowController
@property (strong,nonatomic) DIYBEffectItem* effect;
@property (weak) DIYBPrefData* prefData;
@property (weak) DIYBLightGroup* lightGroup;
@property (weak) DIYBLightStorage* lightStorage;
@property (weak,nonatomic) DIYBSequenceItem* sequenceItem;
@property (strong) NSDictionary* grids;
@property (strong) NSArray* gridName;
@property (strong) NSArray* effects;
@property (copy,nonatomic) NSString* selectedEffect;
@property (assign) BOOL isPattern;
@property (weak) DIYBWindowController* controller;

- (IBAction)createButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
- (IBAction)selectPattern:(id)sender;
@end
