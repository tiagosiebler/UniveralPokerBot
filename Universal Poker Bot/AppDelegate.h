//
//  AppDelegate.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 02/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StateMonitoringWindow.h"
#import "CoordinatesManager.h"
#import "ExternalWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSImageView *mainImageView;
@property (weak) IBOutlet NSImageView *processingImageView;
@property (weak) IBOutlet NSTextField *unknownImageText;
@property (weak) IBOutlet NSImageView *unknownImageView;
@property (nonatomic, strong) StateMonitoringWindow *stateWindowCtrl;

//@property (nonatomic, strong, retain) CoordinatesManager *coordManager;

- (void)startCount;
- (void)checkTimeTaken;
- (void)checkTimeTaken:(NSString*)event;

@end
