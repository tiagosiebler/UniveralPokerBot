//
//  PokerTable.m
//  TableTest
//
//  Created by Siebler, Tiago on 31/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "PokerTable.h"
#import "POdds.h"

@implementation PokerTable
static ImageIndex *IMIndex = nil;
static Tesseract *tessAPI = nil;
static PokerLogger *logger = nil;
+ (ImageIndex*) IMIndex{
    return IMIndex;
}
+ (Tesseract*) tessAPI{
    return tessAPI;
}
+ (PokerLogger*) logger{
    return logger;
}

- (id)init
{
    if (self == [super init]) {
        
        self.blindBig = 0;
        self.numberPlayersWithCards = 0;
        
        self.dealerPosition = 1;
        self.numberRoundsTotal = 0;
        self.numberRoundsTable = 0;
        
        self.tableStartingChips = 0;
        self.tableChips = 0;
        self.totalChips = 0;
        self.totalStartingChips = 0;
        
        self.shouldChangeTable = false;
        self.justChangedTable = true;
        self.isChangingTables = false;
        
        self.totalPots = 0;
        self.totalBets = 0;
        
        self.p1         = [[PokerPlayer alloc] init];
        self.p2         = [[PokerPlayer alloc] init];
        self.p3         = [[PokerPlayer alloc] init];
        self.p4         = [[PokerPlayer alloc] init];
        self.p5         = [[PokerPlayer alloc] init];
        self.p6         = [[PokerPlayer alloc] init];
        self.myPlayer   = [[PokerPlayer alloc] init];
        self.p8         = [[PokerPlayer alloc] init];
        self.p9         = [[PokerPlayer alloc] init];
        
        self.playerState = kPlayerStateInLobby;
        self.card1      = [[PlayingCard alloc] init];
        self.card2      = [[PlayingCard alloc] init];
        self.card3      = [[PlayingCard alloc] init];
        self.card4      = [[PlayingCard alloc] init];
        self.card5      = [[PlayingCard alloc] init];
        
        self.tableMatch = kHandHighCard;
        self.topSuitCount = 0;
        
        IMIndex = [[ImageIndex alloc] init];
        [IMIndex reloadIndex];
        
        if(tessAPI == nil) tessAPI = [[Tesseract alloc] init];
        [tessAPI setPageSegmentationDefault];
        
        if(logger == nil) logger = [[PokerLogger alloc] init];
       
        
        //[self addObserver:self forKeyPath:kGameStateKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setBlindBig:(long long)blindBig{
    if(_blindBig != blindBig) _blindBig = blindBig;
}
- (void)setnumberPlayersWithCards:(int)numberPlayersWithCards{
    if(_numberPlayersWithCards != numberPlayersWithCards) _numberPlayersWithCards = numberPlayersWithCards;
}

- (void)setDealerPosition:(int)dealerPosition{
    if(_dealerPosition != dealerPosition) _dealerPosition = dealerPosition;
}
- (void)setNumberRoundsTotal:(int)numberRoundsTotal{
    if(_numberRoundsTotal != numberRoundsTotal) _numberRoundsTotal = numberRoundsTotal;
}
- (void)setNumberRoundsTable:(int)numberRoundsTable{
    if(_numberRoundsTable != numberRoundsTable) _numberRoundsTable = numberRoundsTable;
}

- (void)setShouldChangeTable:(bool)shouldChangeTable{
    if(_shouldChangeTable != shouldChangeTable) _shouldChangeTable = shouldChangeTable;
}
- (void)setJustChangedTable:(bool)justChangedTable{
    if(_justChangedTable != justChangedTable) _justChangedTable = justChangedTable;
}
- (void)setTotalStartingChips:(unsigned long long)totalStartingChips{
    if(_totalStartingChips != totalStartingChips && totalStartingChips != 0) _totalStartingChips = totalStartingChips;
}

- (void)setTotalPots:(unsigned long long)totalPots{
    if(_totalPots != totalPots) _totalPots = totalPots;
}
- (void)setTotalBets:(unsigned long long)totalBets{
    if(_totalBets != totalBets) _totalBets = totalBets;
}

- (void)setPlayerState:(PlayerState)playerState{
    if(_playerState != playerState) _playerState = playerState;
}
- (void)setGameState:(GameState)gameState{
    if(_gameState != gameState) _gameState = gameState;
}


- (void)setTableCards:(NSArray*)cards{
    //NSLog(@"setTableCards: %@",cards);
    
    [self.card1 setWithString: [cards objectAtIndex:0]];
    [self.card2 setWithString: [cards objectAtIndex:1]];
    [self.card3 setWithString: [cards objectAtIndex:2]];
    [self.card4 setWithString: [cards objectAtIndex:3]];
    [self.card5 setWithString: [cards objectAtIndex:4]];
    
    [self updateGameState];
}
- (void)setTableCards:(NSString*)card1str card2:(NSString*)card2str card3:(NSString*)card3str card4:(NSString*)card4str card5:(NSString*)card5str{
    
    [self.card1 setWithString:card1str];
    [self.card2 setWithString:card2str];
    [self.card3 setWithString:card3str];
    [self.card4 setWithString:card4str];
    [self.card5 setWithString:card5str];
    
    [self updateGameState];
}
- (void)updateGameState{
    //NSLog(@"checking for change in game state: ");
    
    if(self.card5.isRecognizedAsCard){
        if(self.myPlayer.hasHand){
            if(self.card5.stringValue != nil) PokerTable.logger.communityCard5 = self.card5.stringValue;
            if(self.card4.stringValue != nil) PokerTable.logger.communityCard4 = self.card4.stringValue;
            if(self.card3.stringValue != nil) PokerTable.logger.communityCard3 = self.card3.stringValue;
            if(self.card2.stringValue != nil) PokerTable.logger.communityCard2 = self.card2.stringValue;
            if(self.card1.stringValue != nil) PokerTable.logger.communityCard1 = self.card1.stringValue;
        }
        
        
        if(self.gameState == kRiver) return;
        
        self.gameState = kRiver;
        NSLog(@"#####################game state changed to: river");
    }
    else if(self.card4.isRecognizedAsCard){
        if(self.myPlayer.hasHand){
            if(self.card4.stringValue != nil) PokerTable.logger.communityCard4 = self.card4.stringValue;
            if(self.card3.stringValue != nil) PokerTable.logger.communityCard3 = self.card3.stringValue;
            if(self.card2.stringValue != nil) PokerTable.logger.communityCard2 = self.card2.stringValue;
            if(self.card1.stringValue != nil) PokerTable.logger.communityCard1 = self.card1.stringValue;
            
            //logger.communityCard5 = nil;
        }
        if(self.gameState == kTurn) return;
        
        self.gameState = kTurn;
        NSLog(@"#####################game state changed to: turn");
    }
    else if(self.card1.isRecognizedAsCard || self.card2.isRecognizedAsCard || self.card3.isRecognizedAsCard){
        if(self.myPlayer.hasHand){
            if(self.card3.stringValue != nil) PokerTable.logger.communityCard3 = self.card3.stringValue;
            if(self.card2.stringValue != nil) PokerTable.logger.communityCard2 = self.card2.stringValue;
            if(self.card1.stringValue != nil) PokerTable.logger.communityCard1 = self.card1.stringValue;
            
            //logger.communityCard4 = nil;
            //logger.communityCard5 = nil;
        }
        if(self.gameState == kFlop) return;
        
        self.gameState = kFlop;
        NSLog(@"#####################game state changed to: flop");
    }else{
        if(self.myPlayer.hasHand){
            /*
             self.logger.communityCard1 = nil;
             self.logger.communityCard2 = nil;
             self.logger.communityCard3 = nil;
             self.logger.communityCard4 = nil;
             self.logger.communityCard5 = nil;//*/
        }
        if(self.gameState == kBlinds) return;
        
        self.gameState = kBlinds;
        NSLog(@"#####################game state changed to: blinds");
    }
}
- (NSString*)getTableCards{
    NSString *tableCards = nil;
    if(self.gameState == kFlop){
        if(self.card1.stringValue == nil || self.card2.stringValue == nil || self.card3.stringValue == nil){
            NSLog(@"#### getTableCards: returning, since 1 of 3 cards is missing: %@, %@, %@",self.card1.stringValue,self.card2.stringValue,self.card3.stringValue);
            return tableCards;
        }
        
        tableCards = [NSString stringWithFormat:@" %@ %@ %@", self.card1.stringValue, self.card2.stringValue, self.card3.stringValue];
        
    }else if(self.gameState == kTurn){
        if(self.card1.stringValue == nil || self.card2.stringValue == nil || self.card3.stringValue == nil || self.card4.stringValue == nil){
            NSLog(@"#### getTableCards: returning, since 1 of 4 cards is missing: %@, %@, %@, %@",self.card1.stringValue,self.card2.stringValue,self.card3.stringValue,self.card4.stringValue);
            return tableCards;
        }
        
        tableCards = [NSString stringWithFormat:@" %@ %@ %@ %@", self.card1.stringValue, self.card2.stringValue, self.card3.stringValue, self.card4.stringValue];
        
    }else if(self.gameState == kRiver){
        if(self.card1.stringValue == nil || self.card2.stringValue == nil || self.card3.stringValue == nil || self.card4.stringValue == nil || self.card5.stringValue == nil){
            NSLog(@"#### getTableCards: returning, since 1 of 5 cards is missing: %@, %@, %@, %@, %@",self.card1.stringValue,self.card2.stringValue,self.card3.stringValue,self.card4.stringValue,self.card5.stringValue);
            return tableCards;
        }
        
        tableCards = [NSString stringWithFormat:@" %@ %@ %@ %@ %@", self.card1.stringValue, self.card2.stringValue, self.card3.stringValue, self.card4.stringValue, self.card5.stringValue];
    }
    return tableCards;
}
- (void)clearTableForState:(GameState)gameState{
    switch(gameState){
        case kBlinds:
            [self.card1 clear];
            [self.card2 clear];
            [self.card3 clear];
            [self.card4 clear];
            [self.card5 clear];
            break;
            
        case kFlop:
            [self.card4 clear];
            [self.card5 clear];
            break;
            
        case kTurn:
            [self.card5 clear];
            break;
            
        case kRiver:
            
            break;
            
        default:
            [self.card1 clear];
            [self.card2 clear];
            [self.card3 clear];
            [self.card4 clear];
            [self.card5 clear];
            break;
    }
}


/*
- (void)countOccurancesOfString: (NSString*)matchingString inArray:(NSArray*)array{
    int occurrences = 0;
    for(NSString *string in array){
        occurrences += ([string isEqualToString:matchingString]?1:0); //certain object is equal to @"stringValue"
    }
    NSLog(@"number of occurences %d", occurrences);
}//*/
- (NSString*)getStringFromState:(GameState)state{
    switch(state){
        case kBlinds:
            return @"kBlinds";
            break;
            
        case kFlop:
            return @"kFlop";
            break;
            
        case kTurn:
            return @"kTurn";
            break;
            
        case kRiver:
            return @"kRiver";
            break;
    }
}

- (NSDictionary*)getOdds{
    return [self getOddsForPlayer:self.myPlayer];
}
- (NSDictionary*)getOddsForPlayer:(PokerPlayer*)player{
    NSDictionary *oddsSimulation = nil;
    
    // Sanity checks
    if(!player.hasHand) return oddsSimulation;
    else if(!player.card1.isRecognizedAsCard || !player.card2.isRecognizedAsCard) return oddsSimulation;
    else if(player.card1.stringValue == nil || player.card2.stringValue == nil) return oddsSimulation;
    
    player.isCalculatingOdds = true;
    
    NSString *cards = [NSString stringWithFormat:@"%@ %@",player.card1.stringValue, player.card2.stringValue];
    
    //NSLog(@"#### calculate odds called, player params: %@",cards);
    NSString *tableCards = [self getTableCards];
    if(tableCards != nil){
        cards = [cards stringByAppendingString:tableCards];
    }else{
        //NSLog(@"warning couldn't read table cards completely");
    }
    
    self.tableMatch = [POdds getTopMatchForTable:cards];
    //self.topSuitCount = [POdds getTopSuitCountForTable:cards];// ability to see which? Maybe build this into the fuller POOds call.
    NSLog(@"####### top match for table: %@, topSuitCount: %d, cards: %@", [POdds getMatchString:self.tableMatch], self.topSuitCount, cards);
    
    //test that this is accurate in seeing pairs and trips on table, as well as when there's 3 or 4 of the same suit
    
    player.handStrength = [POdds getTopMatchForCards:cards];
    player.handMatch    = [POdds getMatchString:player.handStrength];
    //NSLog(@"####### current match: %@, with strength: %d",player.handMatch, player.handStrength);
    
    cards = [NSString stringWithFormat:@"%ld %@",(long)self.numberPlayersWithCards, cards];
    //NSLog(@"####### calculateOddsForPlayer: %@",cards);
    
    oddsSimulation = [POdds simulateCards:cards];
    
    player.lastOddsQuery = cards;
    [player.odds loadOddsDictionary:oddsSimulation];
    
    player.isCalculatingOdds = false;
    
    return oddsSimulation;
}








- (bool)readPlayerCardsFromImages:(NSImage*)image1 andImage2:(NSImage*)image2{
    bool result = false;
    
    NSString *playerCard1Val = [IMIndex getCardStringWithImage:image1];
    NSString *playerCard2Val = [IMIndex getCardStringWithImage:image2];
    
    [self.myPlayer setCard1:playerCard1Val card2:playerCard2Val];
    
    if(self.myPlayer.card1 != nil && self.myPlayer.card2 != nil)
        result = true;
    
    return result;
}
@end
