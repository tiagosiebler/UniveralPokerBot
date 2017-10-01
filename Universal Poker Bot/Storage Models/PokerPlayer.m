//
//  PokerPlayer.m
//  TableTest
//
//  Created by Siebler, Tiago on 31/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "PokerPlayer.h"
#import "PlayingCard.h"

@implementation PokerPlayer

- (id)init
{
    if (self == [super init]) {
        self.tableChips     = 0;
        self.betAmount      = 0;
        self.lastWinnings   = 0;
        
        self.isSeated       = NO;
        self.isDealer       = NO;
        self.isPlayerTurn   = NO;
        self.isCalculatingOdds = NO;
        self.hasHand        = NO;
        self.hasPocketPair  = NO;
        
        self.card1          = [[PlayingCard alloc] init];
        self.card2          = [[PlayingCard alloc] init];
        
        self.handStrength   = kHandHighCard;
        
        self.odds           = [[PokerOdds alloc] init];
        
        self.lastAction     = kActionUnknown;
        
        self.wins           = 0;
        self.losses         = 0;
        self.roundsPlayed   = 0;
    }
    return self;
}
// override setters so the state isn't overwritten when unchanged
- (void)setTableChips:(unsigned long long)tableChips{
    if(_tableChips != tableChips) _tableChips = tableChips;
}
- (void)setBetAmount:(unsigned long long)betAmount{
    if(_betAmount != betAmount) _betAmount = betAmount;
}
- (void)setLastWinnings:(unsigned long long)lastWinnings{
    if(_lastWinnings != lastWinnings) _lastWinnings = lastWinnings;
}
- (void)setIsSeated:(BOOL)isSeated{
    if(_isSeated != isSeated) _isSeated = isSeated;
}
- (void)setIsDealer:(BOOL)isDealer{
    if(_isDealer != isDealer) _isDealer = isDealer;
}
- (void)setHasHand:(BOOL)hasHand{
    if(_hasHand != hasHand) _hasHand = hasHand;
}
- (void)setHasPocketPair:(BOOL)hasPocketPair{
    if(_hasPocketPair != hasPocketPair) _hasPocketPair = hasPocketPair;
}

- (void)setHandStrength:(HandStrength)handStrength{
    if(_handStrength != handStrength) _handStrength = handStrength;
}

- (void)setWins:(NSInteger)wins{
    if(_wins != wins) _wins = wins;
}
- (void)setLosses:(NSInteger)losses{
    if(_losses != losses) _losses = losses;
}
- (void)setRoundsPlayed:(NSInteger)roundsPlayed{
    if(_roundsPlayed != roundsPlayed) _roundsPlayed = roundsPlayed;
}

/*
- (void)setPlayerCards:(NSArray*)cards{
    //NSLog(@"#### pokerPlayer setPlayerCards: %@",cards);
}//*/

// custom methods
- (void)setCard1:(NSString*)card1str card2:(NSString*)card2str{
    [self.card1 setWithString:card1str];
    [self.card2 setWithString:card2str];
    
    if(self.card1.isRecognizedAsCard && self.card1.isRecognizedAsCard){
        if(!self.hasHand) self.hasHand = true;
    }
    else {
        self.hasHand = false;
    }
}

- (void)didFold{
    self.lastAction = kActionFold;
    self.hasHand = false;
    [self.card1 clear];
    [self.card2 clear];
}
- (void)didCall:(unsigned long long)amount{
    //self.tableChips -= amount;
    self.lastAction = kActionCall;
    self.hasHand = true;
    [self.card1 clear];
    [self.card2 clear];
}
- (void)didRaise:(unsigned long long)amount{
    
}
- (void)didJoinTable{
    
}
- (void)didLeaveTable{
    
}

- (bool)isHandSuited{
    bool result = false;
    if(!self.hasHand) return result;
    if(self.card1.suitString == nil || self.card2.suitString == nil){
        NSLog(@"getPocketCards: error reading pocket cards, returning false");
        return false;
    }
    
    if([self.card1.suitString isEqualToString:self.card2.suitString]){
        NSLog(@"suits match: %@",self.card1.suitString);
        result = true;
    }
    
    return result;
}
- (NSString*)getPocketCards{
    self.hasPocketPair = false;
    
    if(self.card1.valueString == nil || self.card2.valueString == nil){
        NSLog(@"getPocketCards: error reading pocket cards, returning null");
        return nil;
    }
    NSString *cards = [self.card1.valueString stringByAppendingString:self.card2.valueString];
    
    if(cards == nil){
        NSLog(@"getPocketCards: error reading pocket cards, returning null");
        return nil;
    }
    if([cards length] != 2){
        NSLog(@"getPocketCards: error unexpected length, returning null: %lu",(unsigned long)cards.length);
        return nil;
    }
    
    unichar card1 = [cards characterAtIndex:0];
    unichar card2 = [cards characterAtIndex:1];
    
    // pocket pair
    if(card1 == card2){
        self.hasPocketPair = true;
        self.lastHand = cards;
        return self.lastHand;
    }
    
    NSLog(@"p7 hand debug values: %@ - %@",self.card1.dbgValue,self.card2.dbgValue);
    
    //check debug value != folded, or clear prev value on fold.
    
    // swap cards, so lower card is first
    if(card2 == 'A'){
        //NSLog(@"card2 is a");
        self.lastHand = [[NSString stringWithFormat:@"%c", card2] stringByAppendingString:[NSString stringWithFormat:@"%c", card1]];
    }
    else if(card2 == 'K' && card1 != 'A')
    {
        //NSLog(@"card2 is K");
        self.lastHand = [[NSString stringWithFormat:@"%c", card2] stringByAppendingString:[NSString stringWithFormat:@"%c", card1]];
        
    }
    else if(card2 == 'Q' && card1 != 'A' && card1 != 'K')
    {
        //NSLog(@"card2 is Q");
        self.lastHand = [[NSString stringWithFormat:@"%c", card2] stringByAppendingString:[NSString stringWithFormat:@"%c", card1]];
        
    }
    else if(card2 == 'J' && card1 != 'A' && card1 != 'K' && card1 != 'Q'){
        //NSLog(@"card2 is J");
        self.lastHand = [[NSString stringWithFormat:@"%c", card2] stringByAppendingString:[NSString stringWithFormat:@"%c", card1]];
    }
    else if(card1 != 'A' && card1 != 'K' && card1 != 'Q' && card1 != 'J' && card2 > card1){
        //NSLog(@"card2 < card1");
        self.lastHand = [[NSString stringWithFormat:@"%c", card2] stringByAppendingString:[NSString stringWithFormat:@"%c", card1]];
    }else{
        //NSLog(@"last else, leaving unchanged");
        self.lastHand = cards;
    }
    
    return self.lastHand;
}














/*
- (bool)hasCard:(NSString*)card1 card2:(NSString*)card2 suited:(bool)suited{
    bool hasCard = false;
    if(suited)
    {
        // if we're checking for matching suit, return false if card 1 suit doesn't match card 2 suit
        if(![self.card1.suitString isEqualToString:self.card2.suitString])
            return hasCard;
    }
    
    hasCard = (([self.card1.valueString isEqualToString:card2] && [self.card2.valueString isEqualToString:card1])
               || ([self.card1.valueString isEqualToString:card2] && [self.card2.valueString isEqualToString:card1]));
    
    return hasCard;
}//*/
@end
