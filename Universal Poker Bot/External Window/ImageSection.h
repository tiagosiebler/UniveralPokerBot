//
//  ImageSection.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//
//  Generic class to store information about a specific part of an image, including expected position, size, last hash, if it's been found, etc

#import <Foundation/Foundation.h>
#import "Enums.h"

@interface ImageSection : NSObject

@property (nonatomic) NSRect rect;
@property (nonatomic) int imageHash;
@property (strong) NSImage* image;

@property (nonatomic, assign) BOOL isFound;
@property (nonatomic, assign) BOOL isSet;
@property (nonatomic, assign) ImageType type;
@property (nonatomic, assign) ButtonType buttonType;
@property (nonatomic, assign) NSString* buttonValueStr;

- (void)updateRect:(NSRect)rect;
- (void)updateHashFromImage:(NSImage*)image;
- (NSImage*)getImageFromScreenshot:(NSImage*)image;
- (NSImage*)getPlainImageFromScreenshot:(NSImage*)image;
- (NSImage*)getBWImageFromScreenshot:(NSImage*)image;
- (NSImage*)getBetImageFromScreenshot:(NSImage*)image;
- (NSImage*)getPotImageFromScreenshot:(NSImage*)image;
- (BOOL)doesImageMatch:(NSImage*)image;

- (ButtonType)getButton;
- (ButtonType)getPartialButton;

- (NSPoint)getClickablePoint;

- (void)dbgLog:(NSString*)context;

@end
