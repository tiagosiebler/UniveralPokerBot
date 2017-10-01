//
//  PokerChoices.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "PokerChoice.h"

@implementation PokerChoice
- (id)init{
    if (self = [super init]) {
        
        self.gameState      = kBlinds;
        self.winningOdds    = 0.0;
        self.handStrength   = kHandHighCard;
        
        self.canCheck       = false;
        self.canRaise       = true;
        self.isCallRequired = true;
        self.didRaise       = false;
        
        self.callAmount     = 0;// how much we need to call to continue
        self.raiseAmount    = 0;// current raise value, as well as how much we want to raise, if we're raising
        self.playerCount    = 0;
        
        self.totalPot       = 0;
        self.totalBets      = 0;
        
        self.readError      = false;
        self.nextAction     = kActionFold;
    }
    return self;
}

// whether to call smallBlind
static bool callSmallBlind = true;

// multipliers, this * bigBlind
static int callHighP = 7;
static int callHighF = 5;
static int callHighT = 7;
static int callHighR = 10;

static int callMidP = 5;
static int callMidF = 3;
static int callMidT = 5;
static int callMidR = 7;

static int callLowP = 4;
static int callLowF = 2;
static int callLowT = 3;
static int callLowR = 4;

static int raiseHighP = 12;
static int raiseHighF = 10;
static int raiseHighT = 10;
static int raiseHighR = 15;

static int raiseMidP = 9;
static int raiseMidF = 3;
static int raiseMidT = 5;
static int raiseMidR = 7;

static int raiseLowP = 6;
static int raiseLowF = 2;
static int raiseLowT = 3;
static int raiseLowR = 4;

- (void)dbgLog:(NSString*)msg{
    NSLog(@"######## GameState %lu : Odds are: %0.2f, playerCount %d, next action: (%@), (raiseAmt:%lld, callAmt:%lld)",(unsigned long)self.gameState, self.winningOdds, self.playerCount, msg, self.raiseAmount, self.callAmount);
}
- (BOOL)shouldFold{
    if(self.canCheck == false){
        return true;
    }else{
        return false;
    }
}
- (NextAction)foldAction{
    if(self.readError == true) self.nextAction = kActionWait;
    else if(self.canCheck == false) {
        if(callSmallBlind && self.gameState == kBlinds && self.isCallRequired && self.callAmount == (self.bigBlindSize / 2)) {
            self.nextAction = kActionCall;
            [self dbgLog:@"calling small blind, I think: "];

        }else{
            [self dbgLog:@"folding: "];
            self.nextAction = kActionFold;
        }
    }
    else{
        self.nextAction = kActionCheck;
        [self dbgLog:@"checking, because why not: "];
    }
    
    return self.nextAction;
}
- (NextAction)allInAction{
    if(self.readError == true) self.nextAction = kActionWait;
    else if(self.canRaise) {
        NSLog(@"####### going all in");
        [self dbgLog:@"going all in "];
        self.nextAction = kActionAllIn;
    }else{
        NSLog(@"####### going all in via call");
        [self dbgLog:@"want to go all in, but can't raise, so calling max value "];
        self.nextAction = kActionCall;
    }
    
    return self.nextAction;
}
- (NextAction)raiseAction:(int)multiplier{
    if(self.canRaise){
        self.nextAction = kActionRaise;
        self.raiseAmount = self.bigBlindSize * multiplier;
        
        [self dbgLog:@"performing raise with multiplier: "];
    }else if(self.isCallRequired){
        if(self.callAmount <= self.bigBlindSize * multiplier){
            self.nextAction = kActionCall;
            [self dbgLog:@"some else already raised to raise amount, will just call: "];
        }
        else{
            [self dbgLog:@"wanted to raise, but call amount is too high, folding: "];

            // call or fold if call amount is more?
            self.nextAction = kActionFold;
        }
    }else{
        NSLog(@"#### unhandled raiseAction condition - can't raise and can't call, error?");
        self.nextAction = kActionWait;
    }
    return self.nextAction;
}
- (NextAction)raiseOnce:(int)multiplier{
    if(self.canRaise){
        if(self.didRaise)
            self.nextAction = kActionCall;
        else
            self.nextAction = kActionRaise;
        
        self.raiseAmount = self.bigBlindSize * multiplier;
        [self dbgLog:@"performing raise with multiplier: "];
    }else if(self.isCallRequired){
        if(self.callAmount <= self.bigBlindSize * multiplier){
            self.nextAction = kActionCall;
            [self dbgLog:@"some else already raised to raise amount, will just call: "];
        }
        else{
            [self dbgLog:@"wanted to raise, but call amount is too high, folding: "];
            
            // call or fold if call amount is more?
            self.nextAction = kActionFold;
        }
    }else{
        NSLog(@"#### unhandled raiseAction condition - can't raise and can't call, error?");
        self.nextAction = kActionWait;
    }
    return self.nextAction;
}

- (NextAction)callMax:(int)multiplier{
    if(self.isCallRequired){
        if(self.callAmount <= (self.bigBlindSize * multiplier)){
            [self dbgLog:@"callMax: call is less or = to max call, will call "];

            self.nextAction = kActionCall;
        }else{
            
            [self dbgLog:@"callMax: call amount is too high, folding: "];

            [self foldAction];
        }
    }else{
        [self dbgLog:@"callMax: unhandled condition, folding "];

        [self foldAction];
    }
    return self.nextAction;
}
- (NextAction)callBlind{
    NSLog(@"####### trying to call blind, if possible. BigBlindSize(%d), callAmount(%lld)",self.bigBlindSize, self.callAmount);
    if(self.canCheck) {
        
        self.nextAction = kActionCheck;
        [self dbgLog:@"callBlind: can check, so why not"];
    }
    else if(self.isCallRequired && self.gameState == kBlinds && self.callAmount == self.bigBlindSize){
        self.nextAction = kActionCall;
        [self dbgLog:@"callBlind: calling blinds"];
    }else{
        [self dbgLog:@"callBlind: can't call blinds, folding since call requirement too high"];
        self.nextAction = kActionFold;
    }
    
    return self.nextAction;
}
- (void)makeDecision{
    self.readError = false;
    
    if(self.bigBlindSize == 0 || self.playerCount == 0 || (self.winningOdds == 0.00 && self.gameState != kRiver)){
        NSLog(@"######### makeDecision: warning, blinds size (%d), player count (%d) or winning odds (%f) unexpected value.",self.bigBlindSize, self.playerCount, self.winningOdds);
        self.readError = true;
        self.nextAction = kActionWait;
        return;
    }else if(self.winningOdds == 0.00 ){
        NSLog(@"######### makeDecision: WARNING: Winnning Odds(%f) at river stage of game",self.winningOdds);
    }
    [self oddsLogic];
    //[self bingoLogic];
    
    if(self.readError == true) self.nextAction = kActionWait;

    /*
    if([self shouldFold]){
        self.nextAction = kActionFold;
        return;
    }else{
        self.nextAction = kActionCheck;
        return;
    }*/
}
- (void)handleMaxCall:(long long)maxCall{
    // raise multiples of the big blind
    
    /*
     2017-04-28 17:02:58.497220 ImageExperiments[2496:11942318] ###### postBlinds action required - totalBets (0), totalPot (36000), winning odds (0.805000)
     2017-04-28 17:02:58.497231 ImageExperiments[2496:11942318] ####### calculateOddsAction action - maxCall (28980), currentCallAmount: (28050)
     2017-04-28 17:02:58.497241 ImageExperiments[2496:11942318] ######## folding, call amount too high: 28050 - max:(28000)
     2017-04-28 17:02:58.497264 ImageExperiments[2496:11942318] ######## GameState 2 : Odds are: 0.81, playerCount 3, next action: (folding: ), (0 28050)

     
     */
    long long multiplier = ((float)maxCall / (float)self.bigBlindSize) + 0.5f;
    maxCall = (self.bigBlindSize * multiplier);
    if(self.callAmount <= (maxCall + (self.bigBlindSize / 2))){//divided by 2, so it doesn't call min raise every time, even on shitty hands
        if((self.callAmount + self.bigBlindSize) >= maxCall){
            NSLog(@"######## call: raising would go over max (%lld), so just call (%lld)", maxCall, self.callAmount);
            [self callMax:multiplier];
            self.nextAction = kActionCall;
        }else{
            NSLog(@"######## raise: callAmount(%lld) is less than max. Raise amount (%lld), multiplier (%lld)", self.callAmount, maxCall, multiplier);
            [self raiseAction:multiplier];
#warning this should subtract the current call amount, no?
        }
    }else{//if(self.callAmount > (self.bigBlindSize * multiplier))
        NSLog(@"######## folding, call amount too high: %lld - max:(%lld)",self.callAmount, maxCall);
        [self foldAction];
    }/*else{
        NSLog(@"####### folding, unhandled handleMaxCall else");
        [self foldAction];
    }//*/

}
- (void)oddsLogic{
    switch(self.gameState){
        case kBlinds:
            [self handlePreflopOdds];
            
            break;
            
        case kFlop:
        case kRiver:
        case kTurn:
            NSLog(@"###### postBlinds action required - totalBets (%lld), totalPot (%lld), winning odds (%f)",self.totalBets, self.totalPot, self.winningOdds);
            
            [self calculateOddsAction];
            
           // [self foldAction];
            //self.nextAction = kActionWait;
            //NSLog(@"post-blinds logic not written yet");
            break;
    }
}
/*
 preflop odds:
        2       3       4       5       6       7       8       9
 AA 	0.851	0.733	0.634	0.557	0.489	0.431	0.384	0.343
 KK 	0.822	0.688	0.581	0.495	0.426	0.372	0.326	0.290
 QQ 	0.796	0.644	0.533	0.443	0.375	0.322	0.279	0.246
 JJ 	0.771	0.608	0.489	0.399	0.333	0.282	0.243	0.213
 TT 	0.748	0.573	0.448	0.360	0.294	0.246	0.213	0.186
 99 	0.716	0.534	0.409	0.322	0.262	0.222	0.191	0.168
 88 	0.689	0.497	0.373	0.292	0.235	0.198	0.175	0.154
 77 	0.657	0.461	0.338	0.264	0.214	0.182	0.160	0.145
 
 Suited
 AK 	0.663	0.499	0.406	0.345	0.302	0.267	0.241	0.217
 AQ 	0.663	0.483	0.388	0.323	0.282	0.249	0.221	0.200
 AJ 	0.664	0.472	0.372	0.310	0.267	0.235	0.210	0.188
 KQ     0.625	0.462	0.373	0.316	0.275	0.243	0.215	0.196
 KJ     0.615	0.446	0.358	0.298	0.259	0.227	0.204	0.182
 KT     0.605	0.435	0.341	0.288	0.247	0.214	0.191	0.172
 
 Unsuited
 AK 	0.643	0.475	0.376	0.316	0.269	0.235	0.206	0.185
 AQ 	0.645	0.457	0.357	0.293	0.249	0.215	0.186	0.165
 AJ 	0.625	0.442	0.339	0.276	0.232	0.198	0.171	0.150
 KQ     0.603	0.433	0.342	0.283	0.241	0.208	0.181	0.159
 KJ     0.593	0.419	0.325	0.263	0.223	0.189	0.165	0.146
 KT     0.584	0.404	0.309	0.252	0.210	0.179	0.154	0.135
 */

- (float)getAggressionFactorForGameState:(GameState)gameState handStrength:(HandStrength)hand andHandState:(bool)pocketPair{
    float aggressionFactor = 1.0;
    
    /*
        Change aggression level depending on these factors:
     - Less aggression for pocket pairs
     - Especially if not the highest pair on-table
     - Especially at the turn and river
     
     - More aggression for rarer matches
     - Especially on the flop
     - and on the turn
     - toned down for the river
     
     */
    
    // set to true if table cards have a pair
    bool tablePair = false;
    
    switch(gameState){
        case kBlinds:
            // blinds don't need tweaking, so why bother
            break;
            
        case kFlop:
            // high cards are weak, tone it down
            if(hand == kHandHighCard) aggressionFactor = 0.8;
            
            // table pairs are weak pairs
            else if(
                    (hand == kHandPair && tablePair) ||
                    (hand == kHandTwoPair && tablePair)
                    )
                aggressionFactor = 0.9;
            
            // pairs and two pairs are not great, especially if we're holding one of the pairs in-hand
            else if((hand == kHandPair && pocketPair) ||
                    (hand == kHandTwoPair && pocketPair)
                    )
                aggressionFactor = 0.9;

            // pair here isn't great in general, so tone it down
            else if(hand == kHandPair) aggressionFactor = 0.7;
            
            // but two pairs are pretty good here, if we're not holding a pair
            else if(hand == kHandTwoPair) aggressionFactor = 1.2;
            
            // trips rock, even if we're holding two out of three.
            else if(hand == kHandThreeOfAKind && pocketPair) aggressionFactor = 1.5;
            
            // though on-table trips are also okay
            else if(hand == kHandThreeOfAKind) aggressionFactor = 1.4;

            // generally strong hands to have in the flop, as unlikely as they are, worth pushing
            else if(hand == kHandStraight || hand == kHandFlush) aggressionFactor = 3.0;

            // rare in the flop, but awesome at this stage, let's push it more
            else if(hand == kHandFullHouse) aggressionFactor = 1.7;

            // absolute beast to have it at this stage, don't hold back
            else if(hand == kHandFourOfAKind) aggressionFactor = 2.0;

            // rare
            else if(hand == kHandStraightFlush) aggressionFactor = 3;
            
            break;
            
        case kTurn:
            // high cards are weak, tone it down even more, only one card left
            if(hand == kHandHighCard) aggressionFactor = 0.7;
            
            // table pairs are weak pairs
            else if(
                    (hand == kHandPair && tablePair) ||
                    (hand == kHandTwoPair && tablePair)
                    )
                aggressionFactor = 0.7;
            
            // pairs and two pairs are not great, especially if we're holding one of the pairs in-hand
            else if((hand == kHandPair && pocketPair) ||
                    (hand == kHandTwoPair && pocketPair)
                    )
                aggressionFactor = 0.7;
            
            // pair here isn't great, so tone it down
            else if(hand == kHandPair) aggressionFactor = 0.6;
            
            // but two pairs are pretty good here, if we're not holding a pair
            else if(hand == kHandTwoPair) aggressionFactor = 1.3;
            
            // trips rock, even if we're holding two out of three.
            else if(hand == kHandThreeOfAKind && pocketPair) aggressionFactor = 1.8;
            
            // though on-table trips are also okay
            else if(hand == kHandThreeOfAKind) aggressionFactor = 1.4;
            
            // generally strong hands to have in the turn
            else if(hand == kHandFlush) aggressionFactor = 1.4;
            
            //
            else if(hand == kHandStraight) aggressionFactor = 10.0;
            
            // more common in the flop, but rare enough to keep pushing on
            else if(hand == kHandFullHouse) aggressionFactor = 1.7;
            
            // absolute beast to have it at this stage, don't hold back
            else if(hand == kHandFourOfAKind) aggressionFactor = 2.0;
            
            // rare
            else if(hand == kHandStraightFlush) aggressionFactor = 3;
            
            break;
            
        case kRiver:
            // high cards are weak, tone it down even more, any pair wins over this
            if(hand == kHandHighCard) aggressionFactor = 0.6;
            
            // table pairs are weak pairs
            else if(
                    (hand == kHandPair && tablePair) ||
                    (hand == kHandTwoPair && tablePair)
                    )
                aggressionFactor = 0.6;
            
            // pairs and two pairs are not great, especially if we're holding one of the pairs in-hand
            else if((hand == kHandPair && pocketPair) ||
                    (hand == kHandTwoPair && pocketPair)
                    )
                aggressionFactor = 0.6;
            
            // pair here isn't great in general, so tone it down
            else if(hand == kHandPair) aggressionFactor = 0.4;
            
            // but two pairs are pretty good here, if we're not holding a pair
            else if(hand == kHandTwoPair) aggressionFactor = 1.2;
            
            // trips rock, even if we're holding two out of three.
            else if(hand == kHandThreeOfAKind && pocketPair) aggressionFactor = 2;
            
            // though on-table trips are also okay
            else if(hand == kHandThreeOfAKind) aggressionFactor = 1.2;
            
            // generally strong hands to have in the turn
            else if(hand == kHandFlush) aggressionFactor = 1.4;
            
            //
            else if(hand == kHandStraight) aggressionFactor = 20.0;
            
            // more common in the river, but rare enough to keep pushing on
            else if(hand == kHandFullHouse) aggressionFactor = 20.0;
            
            // absolute beast to have, let's get all that we can
            else if(hand == kHandFourOfAKind) aggressionFactor = 5.0;
            
            // rare
            else if(hand == kHandStraightFlush) aggressionFactor = 10.0;
            
            break;
    }
    
    return aggressionFactor;
}
- (void)calculateOddsAction{
    NSString *pocketCards = self.pokerTable.myPlayer.getPocketCards;
    NSLog(@"got pocket cards: %@",pocketCards);
    if(pocketCards == nil) {
        //NSLog(@"======= couldn't read pocket cards for some reason, waiting one tick");
        self.readError = true;
        [self foldAction];
        return;
    }
    
    bool hasPocketPair = self.pokerTable.myPlayer.hasPocketPair;
    float aggression = [self getAggressionFactorForGameState:self.gameState handStrength:self.handStrength andHandState:hasPocketPair];
    long long maxCall = (self.totalBets + self.totalPot) * self.winningOdds * aggression;
    
    NSLog(@"####### calculateOddsAction action - aggression(%0.02f) maxCall/current (%lld / %lld), gameState(%lu), handStrength(%lu), hasPocketPair(%d)", aggression, maxCall, self.callAmount, (unsigned long)self.gameState, (unsigned long)self.handStrength, hasPocketPair);
    [self handleMaxCall:maxCall];

}
- (void)handlePreflopBingo{
    switch(self.playerCount){
        case 2:
            if(self.winningOdds > 0.58){
                [self allInAction];
                
            }else{
                [self foldAction];
            }
            break;
            
        case 3:
            if(self.winningOdds > 0.435){
                [self allInAction];
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 4:
            if(self.winningOdds > 0.340){
                [self allInAction];
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 5:
            if(self.winningOdds > 0.250){
                [self allInAction];
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 6:
            if(self.winningOdds > 0.246){//includes AQ unsuited (0.247)
                [self allInAction];
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 7:
            if(self.winningOdds > 0.200){
                [self allInAction];
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 8:
            if(self.winningOdds > 0.200){
                [self allInAction];
                
            }else{
                [self foldAction];
                
            }
            break;
        case 9:
            if(self.winningOdds > 0.18){
                [self allInAction];
            }else{
                [self foldAction];
                
            }
            break;
            
        default:
            NSLog(@"unhandled player count: %d", self.playerCount);
    }
}
- (void)handlePreflopOdds{
    switch(self.playerCount){
        case 2:
            if(self.winningOdds > 0.58){
                [self allInAction];
                                            
            }else if(self.winningOdds > 0.50){
                [self raiseOnce:raiseHighP];
                
            }else if(self.winningOdds > 0.45){
                [self raiseOnce:raiseLowP];
                
            }else if(self.winningOdds > 0.35){
                [self callMax:callHighP];
                
            }else if(self.winningOdds > 0.25){
                [self callMax:callMidP];
                
            }else if(self.winningOdds > 0.17){
                [self callMax:callLowP];
                
            }else if(self.winningOdds > 0.15){
                [self callBlind];
                
            }else{
                [self foldAction];
            }
            break;
            
        case 3:
            if(self.winningOdds > 0.46){
                [self allInAction];
                
            }else if(self.winningOdds > 0.45){
                [self raiseOnce:raiseHighP];
                
            }else if(self.winningOdds > 0.44){
                [self raiseOnce:raiseLowP];
                
            }else if(self.winningOdds > 0.37){
                [self callMax:callHighP];
                
            }else if(self.winningOdds > 0.30){
                [self callMax:callMidP];
                
            }else if(self.winningOdds > 0.24){
                [self callMax:callLowP];
                
            }else if(self.winningOdds > 0.15){
                [self callBlind];//*/
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 4:
            if(self.winningOdds > 0.340){
                [self allInAction];
                
            }else if(self.winningOdds > 0.31){
                [self raiseOnce:raiseHighP];
                
            }else if(self.winningOdds > 0.30){
                [self raiseOnce:raiseLowP];
                
            }else if(self.winningOdds > 0.25){
                [self callMax:callHighP];
                
            }else if(self.winningOdds > 0.20){
                [self callMax:callMidP];
                
            }else if(self.winningOdds > 0.17){
                [self callMax:callLowP];
                
            }else if(self.winningOdds > 0.15){
                [self callBlind];//*/
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 5:
            if(self.winningOdds > 0.265){
                [self allInAction];
                
            }else if(self.winningOdds > 0.24){
                [self raiseOnce:raiseHighP];
                
            }else if(self.winningOdds > 0.23){
                [self raiseOnce:raiseLowP];
                
            }else if(self.winningOdds > 0.22){
                [self callMax:callHighP];
                
            }else if(self.winningOdds > 0.19){
                [self callMax:callMidP];
                
            }else if(self.winningOdds > 0.16){
                [self callMax:callLowP];
                
            }else if(self.winningOdds > 0.12){
                [self callBlind];//*/
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 6:
            if(self.winningOdds > 0.246){//includes AQ unsuited (0.247)
                [self allInAction];
            
            }else if(self.winningOdds > 0.22){//lowered for KJ unsuited, since we're raising for that with 7 players (0.19)
                [self raiseOnce:raiseHighP];
                
            }else if(self.winningOdds > 0.21){
                [self raiseOnce:raiseLowP];
                
            }else if(self.winningOdds > 0.18){
                [self callMax:callHighP];
                
            }else if(self.winningOdds > 0.16){
                [self callMax:callMidP];
                
            }else if(self.winningOdds > 0.15){
                [self callMax:callLowP];
                
            }else if(self.winningOdds > 0.10){
                [self callBlind];//*/
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 7:
            if(self.winningOdds > 0.200){
                [self allInAction];
            
            }else if(self.winningOdds > 0.19){
                [self raiseOnce:raiseHighP];
                
            }else if(self.winningOdds > 0.18){
                [self raiseOnce:raiseLowP];
                
            }else if(self.winningOdds > 0.16){
                [self callMax:callHighP];
                
            }else if(self.winningOdds > 0.15){
                [self callMax:callMidP];
                
            }else if(self.winningOdds > 0.14){
                [self callMax:callLowP];
                
            }else if(self.winningOdds > 0.08){
                [self callBlind];//*/
                
            }else{
                [self foldAction];
                
            }
            break;
            
        case 8:
            if(self.winningOdds > 0.200){
                [self allInAction];
            
            }else if(self.winningOdds > 0.19){
                [self raiseOnce:raiseHighP];
            
            }else if(self.winningOdds > 0.18){
                [self raiseOnce:raiseLowP];
            
            }else if(self.winningOdds > 0.16){
                [self callMax:callHighP];
            
            }else if(self.winningOdds > 0.15){
                [self callMax:callMidP];
            
            }else if(self.winningOdds > 0.14){
                [self callMax:callLowP];
            
            }else if(self.winningOdds > 0.08){
                [self callBlind];
                
            }else{
                [self foldAction];
                
            }
            break;
        case 9:
            if(self.winningOdds > 0.18){
                [self allInAction];
            
            }else if(self.winningOdds > 0.17){
                [self raiseOnce:raiseHighP];
                
            }else if(self.winningOdds > 0.16){
                [self raiseOnce:raiseLowP];
                
            }else if(self.winningOdds > 0.15){
                [self callMax:callHighP];
                
            }else if(self.winningOdds > 0.14){
                [self callMax:callMidP];
                
            }else if(self.winningOdds > 0.12){
                [self callMax:callLowP];
                
            }else if(self.winningOdds > 0.07){
                [self callBlind];//*/
                
            }else{
                [self foldAction];
                
            }
            break;
            
        default:
            NSLog(@"unhandled player count: %d", self.playerCount);
    }
}

- (void)bingoLogic{
    switch(self.gameState){
        case kBlinds:
            if([self shouldAllInBlinds]) [self allInAction];
            else [self foldAction];
            
            break;
            
        case kFlop:
        case kRiver:
        case kTurn:
            [self foldAction];
            break;
    }
}
- (bool)shouldAllInBlinds{
    bool shouldAllIn = false;
    
    NSString *pocketCards = self.pokerTable.myPlayer.getPocketCards;
    NSLog(@"got pocket cards: %@",pocketCards);
    if(pocketCards == nil) {
        //NSLog(@"======= couldn't read pocket cards for some reason, waiting one tick");
        self.readError = true;
        return false;
    }
    
    NSString *allInCardsStr = @"AA KK QQ JJ AJ AK TT 99 88 77 AQ KQ";
    NSSet *allInCardsSet = [NSSet setWithArray:[allInCardsStr componentsSeparatedByString:@" "]];
    
    NSLog(@"checking if cards (%@) are found in set: %@",pocketCards, allInCardsStr);
    shouldAllIn = [allInCardsSet containsObject:pocketCards];
    if(shouldAllIn){
        NSLog(@"####### all in time baby!! - %@",pocketCards);
    }
    if(!shouldAllIn){
        NSString *allInSuitedStr = @"AK AQ KQ";
        NSSet *allInSuitedSet = [NSSet setWithArray:[allInSuitedStr componentsSeparatedByString:@" "]];

        if(self.pokerTable.myPlayer.isHandSuited){
            shouldAllIn = [allInSuitedSet containsObject:pocketCards];
        }
    }
    return shouldAllIn;
}

- (NSString*)getStringFromNextAction:(NextAction)action{
    switch(action){
        case kActionCheck:
            return @"Check";
            break;
            
        case kActionFold:
            return @"Fold";
            break;
            
        case kActionCall:
            return @"Call";
            break;
            
        case kActionRaise:
            return @"Raise";
            break;
            
        case kActionAllIn:
            return @"AllIn";
            break;
            
            // these two aren't sent to this method right now
        case kActionUnknown:
        case kActionWait:
            return @"nil";
            break;
    }
}

@end
