//
//  PokerTable.h
//  TableTest
//
//  Created by Siebler, Tiago on 31/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PokerPlayer.h"
#import "PlayingCard.h"
#import "Enums.h"
#import "ImageIndex.h"
#import "Tesseract.h"
#import "PokerLogger.h"

//0 to 18,446,744,073,709,551,615
// half of above but also negative

@interface PokerTable : NSObject
@property (strong) NSString* tableName;
@property (nonatomic, assign) long long int blindBig;
@property (nonatomic, assign) NSInteger numberPlayersWithCards;// including you? probably yes

/*
    2   3
 1         4
 
 9         5
    8   6
      7
 */
@property (nonatomic, assign) int dealerPosition;// which player currently holds the dealer chip
@property (nonatomic, assign) int numberRoundsTotal;
@property (nonatomic, assign) int numberRoundsTable;

@property (nonatomic, assign) unsigned long long tableStartingChips;
@property (nonatomic, assign) unsigned long long tableChips;
@property (nonatomic, assign) unsigned long long totalChips;
@property (nonatomic, assign) unsigned long long totalStartingChips;

@property (nonatomic, assign) bool shouldChangeTable;
@property (nonatomic, assign) bool justChangedTable;
@property (nonatomic, assign) bool isChangingTables;

@property (nonatomic, assign) unsigned long long totalPots;
@property (nonatomic, assign) unsigned long long totalBets;

// game state
// blinds, flop, turn, river
@property (nonatomic, assign) GameState gameState;
@property (nonatomic, assign) PlayerState playerState;

// each player on the table
@property (strong) PokerPlayer *p1;
@property (strong) PokerPlayer *p2;
@property (strong) PokerPlayer *p3;
@property (strong) PokerPlayer *p4;
@property (strong) PokerPlayer *p5;
@property (strong) PokerPlayer *p6;
@property (strong) PokerPlayer *myPlayer;//my hand
@property (strong) PokerPlayer *p8;
@property (strong) PokerPlayer *p9;

@property (strong) PlayingCard* card1;
@property (strong) PlayingCard* card2;
@property (strong) PlayingCard* card3;
@property (strong) PlayingCard* card4;
@property (strong) PlayingCard* card5;

@property (nonatomic, assign) HandStrength tableMatch;
@property (nonatomic, assign) int topSuitCount;

+ (ImageIndex*) IMIndex;
+ (Tesseract*) tessAPI;
+ (PokerLogger*) logger;

- (void)setTableCards:(NSArray*)cards;
- (void)setTableCards:(NSString*)card1str card2:(NSString*)card2str card3:(NSString*)card3str card4:(NSString*)card4str card5:(NSString*)card5str;
- (NSString*)getTableCards;

// move this into parent class
- (bool)readPlayerCardsFromImages:(NSImage*)image1 andImage2:(NSImage*)image2;

- (NSDictionary*)getOdds;
- (NSDictionary*)getOddsForPlayer:(PokerPlayer*)player;
- (NSString*)getStringFromState:(GameState)state;
- (void)clearTableForState:(GameState)gameState;
@end
