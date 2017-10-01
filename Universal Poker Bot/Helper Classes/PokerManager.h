//
//  PokerManager.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/05/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BotStateDelegate.h"

#import "CoordinatesManager.h"
#import "ExternalWindow.h"
#import "PokerTable.h"

/*
 
 The GOD class, manages the full bot start to finish
 
 - does all reading from coordinates
 - manages coordinates
 - does all writing to sub classes
 - external methods should monitor needed vars via KVO
 
 */
@interface PokerManager : NSObject// <BotStateDelegate>

@property (strong) CoordinatesManager *coordManager;
@property (strong) ExternalWindow *zyngaPokerWindow;
@property (strong) PokerTable *pokerTable;

@property (nonatomic, assign) bool isPaused;
@property (nonatomic, assign) bool isInMainLoop;//prevent overlapping main cycles
@property (nonatomic, assign) bool actionsEnabled;
@property (nonatomic, assign) bool didRaise;
@property (nonatomic, assign) GameState lastRaiseState;//if currentGameState == lastRaiseState, don't raise agains

- (void)findWindow;
- (void)findReferencePoint;
- (void)handleReferencePointMoved;

- (void)recalibrate;

- (void)readPotLoop;
- (void)readBetsLoop;
- (void)readTotalChipsLoop;

- (unsigned long long)readCurrentBets;// should use this on demand, should be done by loop in background
- (void)readPlayersPlaying;
- (void)readTableCards;
- (void)readPlayerCards;
- (unsigned long long)readMyTableChips;
- (void)readBlinds;

- (void)didStartNewRound:(NSString*)source;

- (void)triggerCheck;
- (void)triggerFold;
- (void)triggerCall;
- (void)triggerRaise:(long long)amount;
- (void)triggerAllIn;
- (void)triggerTurnWithDecision:(PokerChoice*)decision;

- (void)mainReadLoop;
@end
