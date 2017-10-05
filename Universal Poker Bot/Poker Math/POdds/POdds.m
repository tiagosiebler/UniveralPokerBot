//
//  POdds.m
//  podds
//
//  Created by Siebler, Tiago on 29/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "POdds.h"
#include <stdlib.h>
#include <time.h>
#include <stdio.h>
#include <unistd.h>

#include "poker.h"
#include <pthread.h>


@implementation POdds


/* total number of games for the simulation */
#define MAXGAMES        200000

/*~~ Argument parsing ~~~~~~~~~~~~~~~~~*/

#define SYMBOL_TEN    84 // 'T'
#define SYMBOL_JACK   74 // 'J'
#define SYMBOL_QUEEN  81 // 'Q'
#define SYMBOL_KING   75 // 'K'
#define SYMBOL_ACE    65 // 'A'

#define SYMBOL_HEARTS     104 // 'h'
#define SYMBOL_DIAMONDS   100 // 'd'
#define SYMBOL_CLUBS      99  // 'c'
#define SYMBOL_SPADES     115 // 's'

int char2rank(char c) {
    // 50 = '2', 57 = '9'
    if (c >= 50 && c <= 57) return c - 50;
    else if (c == SYMBOL_TEN) return 8;
    else if (c == SYMBOL_JACK) return 9;
    else if (c == SYMBOL_QUEEN) return 10;
    else if (c == SYMBOL_KING) return 11;
    else if (c == SYMBOL_ACE) return 12;
    return -1;
}

int char2suit(char c) {
    if (c == SYMBOL_HEARTS) return 0;
    else if (c == SYMBOL_DIAMONDS) return 1;
    else if (c == SYMBOL_CLUBS) return 2;
    else if (c == SYMBOL_SPADES) return 3;
    return -1;
}

int string2index(char * str) {
    int r, s;
    r = char2rank(str[0]);
    s = char2suit(str[1]);
    if (r < 0 || s < 0) return -1;
    return s*13 + r;
}

/*~~ Global (shared) data ~~~~~~~~~~~~~*/

int counters[] = {0,0,0,0,0,0,0,0,0,0,0,0};
int np, kc, as[7];

/*~~ Threading ~~~~~~~~~~~~~~~~~~~~~~~~*/

int NUMTHREADS, NUMGAMES, GAMESPERTHREAD;
pthread_t * tpool;
pthread_mutex_t tlock;

void * simulator(void * v) {
    int * ohs = (int *)malloc(2*(np-1)*sizeof(int));
    int cs[7], myas[7], cs0, cs1, result, result1, i, j, k;
    int mycounters[] = {0,0,0,0,0,0,0,0,0,0,0,0};
    // int mywins = 0, mydraws = 0;
    deck * d = newdeck();
    for (i=0; i<kc; i++) {
        pick(d, as[i]);
        myas[i] = as[i];
    }
    for (i=0; i<GAMESPERTHREAD; i++) {
        long long score;
        initdeck(d, 52-kc);
        for (j=0; j<2*(np-1); j++) ohs[j] = draw(d);
        for (j=kc; j<7; j++) myas[j] = draw(d);
        for (j=0; j<7; j++) cs[j] = myas[j];
        sort(cs);
        score = eval7(cs);
        result = WIN;
        for (j=0; j<np-1; j++) {
            cs[0] = ohs[2*j];
            cs[1] = ohs[2*j+1];
            for (k=2; k<7; k++) cs[k] = myas[k];
            sort(cs);
            result1 = comp7(cs, score);
            if (result1 < result) result = result1;
            if (result == LOSS) break;
        }
        mycounters[result]++;
        mycounters[hand(score)]++;
    }
    pthread_mutex_lock(&tlock);
    for (i=0; i<12; i++) {
        counters[i] += mycounters[i];
    }
    pthread_mutex_unlock(&tlock);
    free(ohs);
    free(d);
    return NULL;
}

+ (int)intForCard:(NSString*)card{
    char *cardChar = (char*)[card UTF8String];
    int cardInt = string2index(cardChar);
    return cardInt;
}
+ (NSDictionary*)simulateCards:(NSString*)cards{
    
    NSArray *params = [cards componentsSeparatedByString:@" "];
    NSDictionary *oddsSimulation = nil;
    
    //NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSString *commandOutput = [self.class callPOddsWithArray:params];
    //NSLog (@"task returned:\n%@", commandOutput);
    
    if([commandOutput containsString:@"ERROR"]){
        NSLog(@"simulateCards: Error happened in odds calculation - %@",commandOutput);
    }else{
        NSError *error;
        id object = [NSJSONSerialization
                     JSONObjectWithData:[commandOutput dataUsingEncoding:NSUTF8StringEncoding]
                     options:0
                     error:&error];
        
        if(error) { /* JSON was malformed, act appropriately here */ }
        
        // the originating poster wants to deal with dictionaries;
        // assuming you do too then something like this is the first
        // validation step:
        if([object isKindOfClass:[NSDictionary class]])
        {
            oddsSimulation = object;
            //NSLog(@"results dict: %@",oddsSimulation);
            /* proceed with results as you like; the assignment to
             an explicit NSDictionary * is artificial step to get
             compile-time checking from here on down (and better autocompletion
             when editing). You could have just made object an NSDictionary *
             in the first place but stylistically you might prefer to keep
             the question of type open until it's confirmed */
        }
        else
        {
            /* there's no guarantee that the outermost object in a JSON
             packet will be a dictionary; if we get here then it wasn't,
             so 'object' shouldn't be treated as an NSDictionary; probably
             you need to report a suitable error condition */
            NSLog(@"simulateCards: error unexpected format!! %@", object);
        }
        
    }
    return oddsSimulation;
}
+ (NSString*)callPOddsWithArray:(NSArray*)params{
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [[NSBundle mainBundle] pathForResource:@"podds" ofType:nil];
    task.arguments = params;
    task.standardOutput = pipe;
    /*
     
     When "podds" isn't found in main bundle. Should probably have a harder error when that's the case...
     
     2017-10-05 23:03:02.890814+0100 Universal Poker Bot[4276:11907769] [General] must provide a launch path
     2017-10-05 23:03:02.891796+0100 Universal Poker Bot[4276:11907769] [General] (
     0   CoreFoundation                      0x00007fff500ce0fb __exceptionPreprocess + 171
     1   libobjc.A.dylib                     0x00007fff769bac76 objc_exception_throw + 48
     2   CoreFoundation                      0x00007fff5015fbfd +[NSException raise:format:] + 205
     3   Foundation                          0x00007fff52188a55 COPY_SETTER_IMPL + 145
     
     ?
     
     */
    
    //NSLog(@"calling task: \n\n%@ %@",task.launchPath, cards);
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}
+ (float)simulateCards:(NSString*)card1 card2:(NSString*)card2 card3:(NSString*)card3 card4:(NSString*)card4 card5:(NSString*)card5 card6:(NSString*)card6 card7:(NSString*)card7 players:(int)_players{
    int numCards = 0;
    char *cards[7];
    cards[0] = "";
    cards[1] = "";
    cards[2] = "";
    cards[3] = "";
    cards[4] = "";
    cards[5] = "";
    cards[6] = "";
    
    if(card1 != nil){
        cards[numCards] = (char*)[card1 UTF8String];
        numCards += 1;
    }
    if(card2 != nil){
        cards[numCards] = (char*)[card2 UTF8String];
        numCards += 1;
    }
    if(card3 != nil){
        cards[numCards] = (char*)[card3 UTF8String];
        numCards += 1;
    }
    if(card4 != nil){
        cards[numCards] = (char*)[card4 UTF8String];
        numCards += 1;
    }
    if(card5 != nil){
        cards[numCards] = (char*)[card5 UTF8String];
        numCards += 1;
    }
    if(card6 != nil){
        cards[numCards] = (char*)[card6 UTF8String];
        numCards += 1;
    }
    if(card7 != nil){
        cards[numCards] = (char*)[card7 UTF8String];
        numCards += 1;
    }
    NSLog(@"simulate cards called with %d cards, %s %s %s %s %s %s %s", numCards, cards[0], cards[1], cards[2], cards[3], cards[4], cards[5], cards[6]);
    return [self simulateCards:cards count:numCards players:_players];
}

+ (float)simulateCards:(char*[])cards count:(int)_numberOfCards players:(int)_players{
    int i;
    
    NUMTHREADS = (int)sysconf(_SC_NPROCESSORS_ONLN);
    GAMESPERTHREAD = MAXGAMES/NUMTHREADS;
    NUMGAMES = GAMESPERTHREAD*NUMTHREADS;
    
    NSLog(@"cores: %d, games: %d, perThread: %d", NUMTHREADS, NUMGAMES, GAMESPERTHREAD);
    
    // read the arguments and create the known cards
    np = _players;
    kc = _numberOfCards;
    for (i=0; i<kc; i++) {
        as[i] = string2index(cards[i]);
        if (as[i] < 0) {
            NSLog(@"wrong card identifier: %s", cards[i]);
            return 0.0f;
        }
    }
    // initialize the rng seed and the mutex
    srand((unsigned int)time(NULL));
    pthread_mutex_init(&tlock, NULL);
    pthread_mutex_unlock(&tlock);
    
    // run the simulation threads
    tpool = (pthread_t *)malloc(NUMTHREADS*sizeof(pthread_t));
    for (i=0; i<NUMTHREADS; i++) {
        pthread_create(&tpool[i], NULL, simulator, NULL);
    }
    
    // wait for the threads to finish
    for (i=0; i<NUMTHREADS; i++) {
        pthread_join(tpool[i], NULL);
    }
    
    // show the results
    float totalWins = ((float)counters[WIN])/NUMGAMES;
    NSLog(@"wins:%.3f\n", totalWins);
    NSLog(@"draws:%.3f\n", ((float)counters[DRAW])/NUMGAMES);
    
    // clear all
    pthread_mutex_destroy(&tlock);
    
    return totalWins;
}
+ (void)outputHand:(int)hand{
    switch(hand){
        case STRFLUSH:
            NSLog(@"straight flush");
            break;
            
        case FOAK:
            NSLog(@"FOAK");
            break;
            
        case FULLHOUSE:
            NSLog(@"FULLHOUSE");
            break;
            
        case FLUSH:
            NSLog(@"FLUSH");
            break;
            
        case STRAIGHT:
            NSLog(@"STRAIGHT");
            break;
            
        case TOAK:
            NSLog(@"three of a kind");
            break;
            
        case TWOPAIRS:
            NSLog(@"TWOPAIRS");
            break;
            
        case PAIR:
            NSLog(@"PAIR");
            break;
            
        default:
            NSLog(@"high card");
            break;
    }
}
+ (NSString*)getMatchString:(int)hand{
    NSString *result;
    switch(hand){
        case STRFLUSH:
            result = @"Straight Flush";
            break;
            
        case FOAK:
            result = @"Four of a Kind";
            break;
            
        case FULLHOUSE:
            result = @"Full House";
            break;
            
        case FLUSH:
            result = @"Flush";
            break;
            
        case STRAIGHT:
            result = @"Straight";
            break;
            
        case TOAK:
            result = @"Three of a Kind";
            break;
            
        case TWOPAIRS:
            result = @"Two Pairs";
            break;
            
        case PAIR:
            result = @"Pair";
            break;
            
        default:
            result = @"High Card";
            break;
    }
    
    return result;
}

+ (int)getTopMatchForCards:(NSString*)cards{
    NSString *card1 = nil;
    NSString *card2 = nil;
    NSString *card3 = nil;
    NSString *card4 = nil;
    NSString *card5 = nil;
    NSString *card6 = nil;
    NSString *card7 = nil;
    
    NSArray *cardsArray = [cards componentsSeparatedByString:@" "];
    if(cardsArray.count > 6){
        card7 = [cardsArray objectAtIndex:6];
    }
    if(cardsArray.count > 5) card6 = [cardsArray objectAtIndex:5];
    if(cardsArray.count > 4) card5 = [cardsArray objectAtIndex:4];
    if(cardsArray.count > 3) card4 = [cardsArray objectAtIndex:3];
    if(cardsArray.count > 2) card3 = [cardsArray objectAtIndex:2];
    if(cardsArray.count > 1) card2 = [cardsArray objectAtIndex:1];
    if(cardsArray.count > 0) card1 = [cardsArray objectAtIndex:0];
    
    return [self getTopMatchForCards:card1
                               card2:card2
                               card3:card3
                               card4:card4
                               card5:card5
                               card6:card6
                               card7:card7];
}
+ (char*)getCharFromString:(NSString*)string{
    if(string == nil)
        return "";
    
    char *result = (char*)[string UTF8String];
    //NSLog(@"got char: %s",result);
    return result;
}
// ignores pocket cards, purely what's on table
+ (int)getTopMatchForTable:(NSString*)cards{
    NSString *card1 = nil;
    NSString *card2 = nil;
    NSString *card3 = nil;
    NSString *card4 = nil;
    NSString *card5 = nil;
    
    NSArray *cardsArray = [cards componentsSeparatedByString:@" "];
    
    // ignore first two cards
    if(cardsArray.count > 4) card5 = [cardsArray objectAtIndex:4];
    if(cardsArray.count > 3) card4 = [cardsArray objectAtIndex:3];
    if(cardsArray.count > 2) card3 = [cardsArray objectAtIndex:2];
    if(cardsArray.count > 1) card2 = [cardsArray objectAtIndex:1];
    if(cardsArray.count > 0) card1 = [cardsArray objectAtIndex:0];
    
    NSLog(@"####### getTopMatchForTable: %@ %@ %@ %@ %@ ", card1, card2, card3, card4, card5);
    
    return [self getTopMatchForTable:card1
                               card2:card2
                               card3:card3
                               card4:card4
                               card5:card5];
}
+ (int)getTopMatchForTable:(NSString*)card1 card2:(NSString*)card2 card3:(NSString*)card3 card4:(NSString*)card4 card5:(NSString*)card5{
    int numCards = 0;
    
    if(card1 != nil){
        numCards += 1;
    }
    if(card2 != nil){
        numCards += 1;
    }
    if(card3 != nil){
        numCards += 1;
    }
    if(card4 != nil){
        numCards += 1;
    }
    if(card5 != nil){
        numCards += 1;
    }
    
    int cards[numCards];
    switch (numCards) {
        case 5:
            cards[4] = string2index([self getCharFromString:card5]);
            break;
            
        case 4:
            cards[3] = string2index([self getCharFromString:card4]);
            break;
            
        case 3:
            cards[2] = string2index([self getCharFromString:card3]);
            break;
            
        case 2:
            cards[1] = string2index([self getCharFromString:card2]);
            break;
            
        case 1:
            cards[0] = string2index([self getCharFromString:card1]);
            break;
            
        default:
            break;
    }
    /*
     int cards[] = {
     string2index([self getCharFromString:card1]),
     string2index([self getCharFromString:card2]),
     string2index([self getCharFromString:card3]),
     string2index([self getCharFromString:card4]),
     string2index([self getCharFromString:card5]),
     };//*/
    
    sort(cards);
    
    //NSLog(@"cards player:%d %d %d %d %d %d %d", cs1[0], cs1[1], cs1[2], cs1[3], cs1[4], cs1[5], cs1[6]);
    //    NSLog(@"card ranks: %d %d %d %d %d %d %d", rank(cs1[0]), rank(cs1[1]), rank(cs1[2]), rank(cs1[3]), rank(cs1[4]), rank(cs1[5]), rank(cs1[6]));
    
    if(numCards == 2){
        //NSLog(@"only have a hand, no cards on table yet");
        if(rank(cards[0]) == rank(cards[1])){
            //NSLog(@"card1 rank == card2 rank, pocket pair");
            return PAIR;
        }
        return HC;
    }
    
    long long evaluatedCards = eval5(cards);
    int handValue = (int)hand(evaluatedCards);
    return handValue;
}
+ (int)getTopMatchForCards:(NSString*)card1 card2:(NSString*)card2 card3:(NSString*)card3 card4:(NSString*)card4 card5:(NSString*)card5 card6:(NSString*)card6 card7:(NSString*)card7{
    int numCards = 0;
    
    if(card1 != nil){
        numCards += 1;
    }
    if(card2 != nil){
        numCards += 1;
    }
    if(card3 != nil){
        numCards += 1;
    }
    if(card4 != nil){
        numCards += 1;
    }
    if(card5 != nil){
        numCards += 1;
    }
    if(card6 != nil){
        numCards += 1;
    }
    if(card7 != nil){
        numCards += 1;
    }
    
    int cs1[] = {
        string2index([self getCharFromString:card1]),
        string2index([self getCharFromString:card2]),
        string2index([self getCharFromString:card3]),
        string2index([self getCharFromString:card4]),
        string2index([self getCharFromString:card5]),
        string2index([self getCharFromString:card6]),
        string2index([self getCharFromString:card7]),
    };
    
    sort(cs1);
    
    //*/
    //    NSLog(@"cards player:%d %d %d %d %d %d %d", cs1[0], cs1[1], cs1[2], cs1[3], cs1[4], cs1[5], cs1[6]);
    //    NSLog(@"card ranks: %d %d %d %d %d %d %d", rank(cs1[0]), rank(cs1[1]), rank(cs1[2]), rank(cs1[3]), rank(cs1[4]), rank(cs1[5]), rank(cs1[6]));
    
    if(numCards == 2){
        //NSLog(@"only have a hand, no cards on table yet");
        if(rank(cs1[0]) == rank(cs1[1])){
            //NSLog(@"card1 rank == card2 rank, pocket pair");
            return PAIR;
        }
        return HC;
    }
    
    long long evaluatedCards = 0;
    if(numCards < 7){
        sortLen(cs1,numCards);
        evaluatedCards = eval7(cs1);
    }else{
        sortLen(cs1,numCards);
        evaluatedCards = eval5(cs1);
    }
    return hand(evaluatedCards);
}

+ (void)testHandRecog{
    NSString *card1 = @"6s";
    NSLog(@"cardInt (%@): %d %d",card1, [self.class intForCard:card1], string2index("6s"));
    
    //int cs1[] = {12, 25, -1, -1, -1, -1, -1};
    int cs1[] = {
        // player hand
        string2index("6s"),
        string2index("Ad"),
        
        // flop
        string2index("8d"),
        string2index("5h"),
        string2index("7h"),
        
        // river
        string2index("5c"),
        
        // turn
        string2index("4d")
    };
    
    long long s1;
    sort(cs1);
    printf("player 1 cards: %d %d %d %d %d %d %d\n", cs1[0], cs1[1], cs1[2], cs1[3], cs1[4], cs1[5], cs1[6]);
    printf("player 1 ranks: %d %d %d %d %d %d %d\n", rank(cs1[0]), rank(cs1[1]), rank(cs1[2]), rank(cs1[3]), rank(cs1[4]), rank(cs1[5]), rank(cs1[6]));
    s1 = eval7(cs1);
    printf("strength: %lld\n", s1);
    printf("%d\n", hand(s1));
    
    [self outputHand:hand(s1)];
}

@end
