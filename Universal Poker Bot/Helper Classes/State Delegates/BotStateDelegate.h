//
//  BotStateDelegate.h
//  PokerAPI
//
//  Created by Siebler, Tiago on 08/05/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BotState;
@class ExternalWindow;
@protocol BotStateDelegate <NSObject>

// when first launching, initialise everything, including subClasses
- (void) willStartInitialising;
- (void) didFinishInitialising;

// pausable features
- (void) didPauseReading;
- (void) didResumeReading;

- (void) didPauseActions;
- (void) didResumeActions;

// loading
- (void) willFindWindow;
- (void) didFindWindow: (ExternalWindow *) windowRef;
- (void) couldNotFindWindowWithError:(NSError*)error;

// calibration. Ref point is typically an object that's always in the window of interest, e.g the poker chip on top left of poker window
- (void) referencePointDidMove;
- (void) willFindReferencePoint;
- (void) didFindReferencePoin;
- (void) couldNotFindReferencePointWithError:(NSError*)error;

- (void) willStartRecalibrating;
- (void) didFinishRecalibrating;

@end

@interface BotState : NSObject
@property (nonatomic, weak) id <BotStateDelegate> delegate;

@end
