//
//  PokerLogger.h
//  CSVLogger
//
//  Created by Siebler, Tiago on 18/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"

@interface PokerLogger : NSObject

@property (strong) NSMutableArray *round;
@property (strong) NSString *sessionDt;

@property (nonatomic) long long bigBlind;
@property (nonatomic) long long chipsTotal;
@property (nonatomic) long long chipsTotalTable;
@property (nonatomic) long long chipsDifferenceTotal;//positive or negative, win or loss
@property (nonatomic) float winningOdds;
@property (nonatomic) float aggressionFactor;

// start of round, vs how many called (if I went all in). Check player cound when total money changes, since that's the end of a win/loss
@property (nonatomic) int playerCountStart;
@property (nonatomic) int playerCountEnd;

@property (strong) NSString *pocketCards;
@property (nonatomic) int pocketCardsSuited;//1 or 0

@property (strong) NSString *playerAction;
@property (nonatomic) long long playerActionAmount;

@property (strong) NSString *gameState;
@property (strong) NSString *finalHand;//high card, pair, etc

@property (strong) NSString *communityCard1;
@property (strong) NSString *communityCard2;
@property (strong) NSString *communityCard3;
@property (strong) NSString *communityCard4;
@property (strong) NSString *communityCard5;
@property (nonatomic) int didWin;//1, 0, -1. -1 = loss




- (id)initWithPath:(NSString*)path;

- (void)clearForGameState:(GameState)state;
- (void)write;//call newRound automatically from write?
- (void)write:(NSString*)location;
- (void)newRound;


@end
