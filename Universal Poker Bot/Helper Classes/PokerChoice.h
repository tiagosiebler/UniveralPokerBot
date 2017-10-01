//
//  PokerChoices.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PokerTable.h"
#import "Enums.h"

@interface PokerChoice : NSObject
@property (strong) PokerTable *pokerTable;

@property (nonatomic, assign) GameState gameState;
@property (nonatomic, assign) float winningOdds;
@property (nonatomic, assign) HandStrength handStrength;
#warning add indicator whether table has a pair on it, so we know to tone done aggression

@property (nonatomic, assign) BOOL readError;
@property (nonatomic, assign) BOOL canCheck;
@property (nonatomic, assign) BOOL canRaise;
@property (nonatomic, assign) BOOL didRaise;
@property (nonatomic, assign) BOOL isCallRequired;
@property (nonatomic, assign) long long callAmount;//amount we need to call if call is required to continue
@property (nonatomic, assign) long long raiseAmount;//minimum raise amount / current value

@property (nonatomic, assign) int playerCount;
@property (nonatomic, assign) int bigBlindSize;
@property (nonatomic, assign) long long totalPot;//totalPot size (incl sub pots)
@property (nonatomic, assign) long long totalBets;//totalPot size (incl sub pots)


@property (nonatomic, assign) NextAction nextAction;

//@property (nonatomic, assign) int raiseAmount;//amount we need to raise if next action should be a raise. Multiple of BB?

- (void)makeDecision;
- (NSString*)getStringFromNextAction:(NextAction)action;
@end
