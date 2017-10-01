//
//  WindowHelper.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExternalWindow : NSObject

@property (nonatomic, strong) NSNumber *windowID;
@property (nonatomic, strong) NSDictionary *windowDict;
@property (nonatomic, strong) NSImage *windowImage;
@property (nonatomic) NSRect windowBounds;
@property (nonatomic) BOOL haveWindow;

// instance methods
- (BOOL)getWindowWithID:(NSNumber*)windowID;
- (BOOL)getWindowWithName:(NSString*)windowName;
- (BOOL)getWindowWithOwnerName:(NSString*)windowName;
- (BOOL)getWindowWithTitleContaining:(NSString*)title;
- (BOOL)setCurrentWindow:(NSDictionary*)window;

- (NSRect)getRect;//get rect of currently assigned window ID
- (NSImage*)screenshot;//get screenshot of currently assigned window ID
- (NSImage*)screenshotFromRect:(NSRect)theRect;//takes screenshot of currently assigned window ID

- (void)triggerClick:(NSPoint)point;
- (void)triggerBackgroundClick:(NSPoint)point;
- (void)typeString:(NSString*)string atPoint:(NSPoint)point;
- (void)switchAndClick:(NSPoint)point;
- (void)moveMouse:(NSPoint)point;
// static class methods
+ (NSArray*)getWindowList;
+ (NSRect)getRectFromWindow:(NSDictionary*)window;
+ (NSImage*)screenshotFromRect:(NSRect)theRect;//takes screenshot of frontmost window
+ (NSImage*)screenshotFromRect:(NSRect)theRect forWindow:(NSNumber*)windowID;//takes screenshot of provided window ID

- (BOOL)getWindowZynga;
@end
