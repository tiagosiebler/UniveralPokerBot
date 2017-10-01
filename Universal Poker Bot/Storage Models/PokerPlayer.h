//
//  PokerPlayer.h
//  TableTest
//
//  Created by Siebler, Tiago on 31/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayingCard.h"
#import "PokerOdds.h"
#import "ImageSection.h"

@interface PokerPlayer : NSObject
@property (nonatomic, assign) unsigned long long tableChips;
@property (nonatomic, assign) unsigned long long betAmount;
@property (nonatomic, assign) unsigned long long lastWinnings;

@property (nonatomic, assign) BOOL isSeated;
@property (nonatomic, assign) BOOL isDealer;
@property (nonatomic, assign) BOOL isPlayerTurn;
@property (nonatomic, assign) BOOL isCalculatingOdds;
@property (nonatomic, assign) BOOL hasHand;
@property (nonatomic, assign) BOOL hasPocketPair;

@property (nonatomic, strong) PlayingCard* card1;
@property (nonatomic, strong) PlayingCard* card2;

@property (nonatomic, assign) HandStrength handStrength;
@property (strong) NSString* handMatch;//high card, pair, two pair, etc
@property (strong) PokerOdds* odds;

@property (strong) NSString* lastHandMatch;
@property (strong) NSString* lastHand;
@property (strong) NSString* lastOddsQuery;
@property (nonatomic, assign) NextAction lastAction;

// history tracking for specific player
@property (nonatomic, assign) NSInteger wins;
@property (nonatomic, assign) NSInteger losses;
@property (nonatomic, assign) NSInteger roundsPlayed;

- (void)didFold;
- (void)didCall:(unsigned long long)amount;
- (void)didRaise:(unsigned long long)amount;
- (void)didJoinTable;
- (void)didLeaveTable;

- (bool)isHandSuited;

- (void)setCard1:(NSString*)card1str card2:(NSString*)card2str;

- (NSString*)getPocketCards;


//- (void)setPlayerCards:(NSArray*)cards;
//- (bool)hasCard:(NSString*)card1 card2:(NSString*)card2 suited:(bool)suited;
@end
