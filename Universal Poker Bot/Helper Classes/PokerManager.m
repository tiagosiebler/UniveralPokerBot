//
//  PokerManager.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/05/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "PokerManager.h"
#import "NSImage+subImage.h"
#import "NSString+cleaning.h"
#import "NumbersHelper.h"

@implementation PokerManager
static int loopCycle = 0;
static float changeTableMultiplier = 3;
- (id)init
{
    if (self == [super init]) {
        [self initialise];
    }
    return self;
}
- (void)initialise{
    // coordinates manager
    if(self.coordManager == nil)
        self.coordManager = [[CoordinatesManager alloc] init];
    
    self.coordManager.pathToTableMap = [[NSBundle mainBundle] pathForResource:@"relativeZyngaDict" ofType:@"plist"];
    
    self.zyngaPokerWindow = [[ExternalWindow alloc] init];
    
    self.pokerTable = [[PokerTable alloc] init];
    //self = [[NSApplication sharedApplication] delegate];
    
    self.isPaused = false;
    self.actionsEnabled = true;
    self.isInMainLoop = false;
    
    [self.pokerTable addObserver:self forKeyPath:kGameStateKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.pokerTable addObserver:self forKeyPath:kPlayersWithCardsKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(keyPath == nil) return;
    
    if(kGameStateKeyPath != nil && [keyPath isEqualToString:kGameStateKeyPath]){
        [self handleGameStateChanged:change];
    }
    else if(kPlayersWithCardsKeyPath != nil && [keyPath isEqualToString:kPlayersWithCardsKeyPath]){
        [self handlePlayerCountChanged:change];
    }
}
- (void)handleGameStateChanged:(NSDictionary *)change{
    if([change[@"old"] intValue] != [change[@"new"] intValue]){
        [self gameStateDidChange:(GameState)[change[@"new"] intValue]];
    }
}
- (void)handlePlayerCountChanged:(NSDictionary*)change{
    NSNumber *oldValue = change[@"old"];
    NSNumber *newValue = change[@"new"];
    
    //NSLog(@"player count changed: %@",change);
    
    if([oldValue isKindOfClass:[NSNumber class]] && [newValue isKindOfClass:[NSNumber class]]){
        int oldInt = [oldValue intValue];
        int newInt = [newValue intValue];
        
        if(oldInt != newInt){
            NSLog(@"player count changed from %d to %d",oldInt,newInt);
            [self.pokerTable getOdds];//recalculate because player count changed
            
            if(oldInt == 0 || oldInt == 1){
                NSLog(@"##### new round player count is: %d",newInt);
#warning track number of players on table like this
                // store newInt, as that contains the maximum number of players currently on table.
                // store another int for minPlayerConflictCount++. If that's hit 3 times, then change tables because not enough people.
                // ++ it every time there's not enough people in the max value
                [self didStartNewRound:@"player count went 0-1"];
                
            }
        }
    }
}
- (void)gameStateDidChange:(GameState)currGameState{
    switch(currGameState){
        case kBlinds:
            self.pokerTable.tableMatch = kHandHighCard;

            break;
            
        case kFlop:

            break;
            
        case kTurn:

            break;
            
        case kRiver:

            break;
            
        default:
            self.pokerTable.tableMatch = kHandHighCard;
            break;
    }
    NSLog(@"###### game state changed: %lu",(unsigned long)currGameState);
    [self.pokerTable clearTableForState:currGameState];
    self.pokerTable.totalBets = 0;
    self.didRaise = false;
}


- (void)findWindow{
    [self.zyngaPokerWindow getWindowZynga];
}
- (void)findReferencePoint{
    @autoreleasepool {
        
        NSLog(@"findReferencePoint: checking if chipImage is loaded from bundle");
        if(self.coordManager.chipImage == nil){
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:kImageChip ofType:@"png"];
            NSImage *image = [[NSImage alloc] initWithContentsOfFile: imagePath];
            [image setCacheMode:NSImageCacheNever];
            
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            image.size = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            [image makeThreadSafe];
            
            self.coordManager.chipImage = image;
        }
        
        NSLog(@"findReferencePoint: attempting to search for location");
        
        if(!self.zyngaPokerWindow.haveWindow){
            [self findWindow];
            [self performSelector:@selector(findReferencePoint) withObject:nil afterDelay:1];
        }else{
            self.coordManager.windowImage = self.zyngaPokerWindow.screenshot;
            
            NSError *error;
            BOOL result = [self.coordManager getChipLocationWithError:&error];
            if(!result){
                NSLog(@"findReferencePoint: couldn't find chip: %@",error);
                return;
            }
            
            NSLog(@"findReferencePoint: got location of chip: %@",NSStringFromPoint(self.coordManager.chipLocation.origin));
            [self.coordManager getChipHash];
            [self.coordManager calibrateCoordinatesFromTableMap];
        }
    }
}
- (void)referencePointDidMove{
    self.coordManager.isCalibrated = false;
    NSLog(@"chip moved, recalibrating");
    [self findReferencePoint];
}

- (void)recalibrate{
    [self.coordManager calibrateCoordinatesFromTableMap];
}

- (void)willStartInitialising{
    
}
- (void)didFinishInitialising{
    
}


- (void)startLoops{
    
}

static NSDate *methodStart;
- (void)startCount{
    methodStart = [NSDate date];
}
- (void)checkTimeTaken{
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"####### executionTime = %f seconds", executionTime);
    printf("\n\n\n");
}
- (void)checkTimeTaken:(NSString*)event{
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"#%@ - executionTime = %f seconds", event, executionTime);
}

// loops - main read loop is at end
- (void)readPotLoop{
    if(self.isPaused || !self.zyngaPokerWindow.haveWindow || !self.coordManager.isCalibrated) {
        //NSLog(@"bot paused");
        return;
    }
    @autoreleasepool {
        NSDate *methodStart = [NSDate date];
        
        self.pokerTable.totalPots = [self readCurrentPots];
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"###=== readTotalPot = %f seconds", executionTime);
    }
}
- (void)readBetsLoop{
    if(self.isPaused || !self.zyngaPokerWindow.haveWindow || !self.coordManager.isCalibrated) {
        //NSLog(@"bot paused");
        return;
    }
    @autoreleasepool {
        NSDate *methodStart = [NSDate date];
        
        self.pokerTable.totalBets = [self readCurrentBets];
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"###=== readTotalBets = %f seconds", executionTime);
    }
}
- (void)readTotalChipsLoop{
    if(self.isPaused || !self.zyngaPokerWindow.haveWindow || !self.coordManager.isCalibrated) {
        //NSLog(@"bot paused");
        return;
    }
    @autoreleasepool {
        NSImage *moneys = [self.coordManager.money getImageFromScreenshot:self.coordManager.windowImage];
        //[moneys saveAsPNGWithName:@"/Users/tsiebler/Screenies/moneys.png"];
        moneys = [moneys clearForTableChips];
        
        NSString * result = [[PokerTable tessAPI] getCurrencyValueFromImage:moneys];
        if(result == nil) return;
        
        NSLog(@"##### updateTotalChips: total chips: %@",result);
        long long int totalChips = [result betValue:@"total chips"];
        if(totalChips == 0) return;
        
        [self didReadTotalChips:totalChips];
    }
}
// read methods

- (void)readPlayersPlaying{
    int playersWithCards = 0;
    NSImage *playerTableCard = [self.zyngaPokerWindow.windowImage greyScaleImage];
    
    NSImage *p1Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards1];
    NSImage *p2Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards2];
    NSImage *p3Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards3];
    NSImage *p4Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards4];
    NSImage *p5Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards5];
    NSImage *p6Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards6];
    NSImage *p7Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards7];
    NSImage *p8Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards8];
    NSImage *p9Cards = [playerTableCard getSubImageWithRect:self.coordManager.playerCards9];
    
    self.pokerTable.p1.hasHand          = [PokerTable.IMIndex playerHasAHand:p1Cards outInt:&playersWithCards];
    self.pokerTable.p2.hasHand          = [PokerTable.IMIndex playerHasAHand:p2Cards outInt:&playersWithCards];
    self.pokerTable.p3.hasHand          = [PokerTable.IMIndex playerHasAHand:p3Cards outInt:&playersWithCards];
    self.pokerTable.p4.hasHand          = [PokerTable.IMIndex playerHasAHand:p4Cards outInt:&playersWithCards];
    self.pokerTable.p5.hasHand          = [PokerTable.IMIndex playerHasAHand:p5Cards outInt:&playersWithCards];
    self.pokerTable.p6.hasHand          = [PokerTable.IMIndex playerHasAHand:p6Cards outInt:&playersWithCards];
    
    self.pokerTable.myPlayer.hasHand    = [PokerTable.IMIndex playerHasAHand:p7Cards outInt:&playersWithCards];
    
    self.pokerTable.p8.hasHand          = [PokerTable.IMIndex playerHasAHand:p8Cards outInt:&playersWithCards];
    self.pokerTable.p9.hasHand          = [PokerTable.IMIndex playerHasAHand:p9Cards outInt:&playersWithCards];
    
    self.pokerTable.numberPlayersWithCards = playersWithCards;
    
    //NSLog(@"players with cards: %ld, self.pokerTable.myPlayer.hasHand: %d",(long)self.pokerTable.numberPlayersWithCards, self.pokerTable.myPlayer.hasHand);
    //[[self roundsPlayedTxt] setStringValue:[NSString stringWithFormat:@"%ld",(long)self.pokerTable.numberPlayersWithCards]];
}
- (void)readTableCards{
    //NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    //NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    
    //[self.zyngaPokerWindow.windowImage saveAsPNGWithName:[NSString stringWithFormat:@"/Users/tsiebler/Desktop/pkr/images/auto/mainScreen-%@.png",timeStampObj]];
#warning move cards to ImageSection class and use loadImageFromSCreenshot
    NSImage *tableCards = [self.zyngaPokerWindow.windowImage greyScaleImage];
    
    NSImage *tbCard1 = [tableCards getSubImageWithRect:self.coordManager.tableCard1];
    NSImage *tbCard2 = [tableCards getSubImageWithRect:self.coordManager.tableCard2];
    NSImage *tbCard3 = [tableCards getSubImageWithRect:self.coordManager.tableCard3];
    NSImage *tbCard4 = [tableCards getSubImageWithRect:self.coordManager.tableCard4];
    NSImage *tbCard5 = [tableCards getSubImageWithRect:self.coordManager.tableCard5];
    
    //PlayingCard *card1 = [self.IMIndex getCardWithImage:tbCard1];
    NSString *tableCard1Val = [PokerTable.IMIndex getCardStringWithImage:tbCard1];
    NSString *tableCard2Val = [PokerTable.IMIndex getCardStringWithImage:tbCard2];
    NSString *tableCard3Val = [PokerTable.IMIndex getCardStringWithImage:tbCard3];
    NSString *tableCard4Val = [PokerTable.IMIndex getCardStringWithImage:tbCard4];
    NSString *tableCard5Val = [PokerTable.IMIndex getCardStringWithImage:tbCard5];
    
    NSMutableArray *cardsOnTable;
    cardsOnTable = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 5; ++i)
    {
        [cardsOnTable addObject:[NSNull null]];
    }
    
    if(tableCard1Val != nil) [cardsOnTable replaceObjectAtIndex:0 withObject:tableCard1Val];
    if(tableCard2Val != nil) [cardsOnTable replaceObjectAtIndex:1 withObject:tableCard2Val];
    if(tableCard3Val != nil) [cardsOnTable replaceObjectAtIndex:2 withObject:tableCard3Val];
    if(tableCard4Val != nil) [cardsOnTable replaceObjectAtIndex:3 withObject:tableCard4Val];
    if(tableCard5Val != nil) [cardsOnTable replaceObjectAtIndex:4 withObject:tableCard5Val];
    
    /*
    if(tableCard1Val != nil) [[self flop1Txt] setStringValue:tableCard1Val];
    else [[self flop1Txt] setStringValue:@"unhandled"];
    
    if(tableCard2Val != nil) [[self flop2Txt] setStringValue:tableCard2Val];
    else [[self flop2Txt] setStringValue:@"unhandled"];
    
    if(tableCard3Val != nil) [[self flop3Txt] setStringValue:tableCard3Val];
    else [[self flop3Txt] setStringValue:@"unhandled"];
    
    if(tableCard4Val != nil) [[self flop4Txt] setStringValue:tableCard4Val];
    else [[self flop4Txt] setStringValue:@"unhandled"];
    
    if(tableCard5Val != nil) [[self flop5Txt] setStringValue:tableCard5Val];
    else [[self flop5Txt] setStringValue:@"unhandled"];//*/
    
    //NSLog(@"finished recognizing");
    //[self updateGameStateUsingTableArray:cardsOnTable];
    [self.pokerTable setTableCards:cardsOnTable];
}
- (void)readPlayerCards{
    //pokerTable class should directly access coordManager, and assign images to subclasses
    NSImage *myCard1 = [self.coordManager getPlayerCard1Image];
    NSImage *myCard2 = [self.coordManager getPlayerCard2Image];
    
    //[self.myCard1View setImage:myCard1];
    //[self.myCard2View setImage:myCard2];
    
    [self.pokerTable readPlayerCardsFromImages:myCard1 andImage2:myCard2];
}
- (unsigned long long)readCurrentPots{
    unsigned long long result = 0;
    NSImage *potScreenshot = [self.coordManager.windowImage clearForPots];
    
    NSString *mainPot = [[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.mainPot getPlainImageFromScreenshot:potScreenshot]];
    NSString *sidePot1 = [[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.sidePot1 getPlainImageFromScreenshot:potScreenshot]];
    NSString *sidePot1Shifted = [[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.sidePot1Shifted getPlainImageFromScreenshot:potScreenshot]];
    NSString *sidePot2 = [[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.sidePot2 getPlainImageFromScreenshot:potScreenshot]];
    NSString *sidePot2Shifted = [[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.sidePot2Shifted getPlainImageFromScreenshot:potScreenshot]];
    NSString *sidePot3 = [[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.sidePot3 getPlainImageFromScreenshot:potScreenshot]];
    
    result += [mainPot betValue:@"mainPot"];
    if(result == 0){
        NSString *mainPot2 = [[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.mainPot2 getPlainImageFromScreenshot:potScreenshot]];
        result += [mainPot2 betValue:@"mainPot2"];
    }
    result += [sidePot1 betValue:@"sidePot1"];
    result += [sidePot1Shifted betValue:@"sidePot1Shifted"];
    result += [sidePot2 betValue:@"sidePot2"];
    result += [sidePot2Shifted betValue:@"sidePot2Shifted"];
    result += [sidePot3 betValue:@"sidePot3"];
    
    NSLog(@"----- totalPots: %llu", result);
    
    return result;
}
bool checkHandlessPlayers = true;
- (unsigned long long)readCurrentBets{
    unsigned long long result = 0;
    
    NSImage *betScreenshot = [self.coordManager.windowImage clearForBets];
    if(self.pokerTable.p1.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p1Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p1"];
    if(self.pokerTable.p2.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p2Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p2"];
    if(self.pokerTable.p3.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p3Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p3"];
    if(self.pokerTable.p4.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p4Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p4"];
    if(self.pokerTable.p5.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p5Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p5"];
    if(self.pokerTable.p6.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p6Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p6"];
    if(self.pokerTable.myPlayer.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p7Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p7"];
    if(self.pokerTable.p8.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p8Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p8"];
    if(self.pokerTable.p9.hasHand || checkHandlessPlayers) result += [[[PokerTable tessAPI] getCurrencyValueFromImage:[self.coordManager.p9Bet getPlainImageFromScreenshot:betScreenshot]] betValue:@"p9"];
    
    NSLog(@"----- totalCurrentBets: %llu", result);
    
    return result;
}
- (void)readBlinds{
    @autoreleasepool {
        
        NSImage *blinds = [self.coordManager.tableBlindsSize getImageFromScreenshot:self.coordManager.windowImage];
        blinds = [blinds clearForBlinds];
        
        NSString * blindsStr = [[PokerTable tessAPI] getStringFromImage:blinds];
        blindsStr = [blindsStr clean];
        
        NSArray * splitBlinds = [blindsStr componentsSeparatedByString:@"/"];
        if([splitBlinds count] < 2){
            
            splitBlinds = [blindsStr componentsSeparatedByString:@":"];
            if([splitBlinds count] < 2){
                NSLog(@"######## ERROR: COULDN'T READ BLINDS, RETURNING: %@",blindsStr);
                return;
            }
        }
        
        NSLog(@"readBlinds: got text: %@ , length: %lu",blindsStr, (unsigned long)splitBlinds.count);
        blindsStr = [splitBlinds objectAtIndex:1];
        
        //long long int sb = [self numberFromBlind:[blindArr objectAtIndex:0]];
        long long int bb = [NumbersHelper getNumberFromFormattedString:blindsStr];
        if(bb != 0){
            self.pokerTable.blindBig    = bb;
            PokerTable.logger.bigBlind  = bb;
            //[self.blindsSizeField setStringValue:[self formatMoneyAsString:bb]];
        }else{
            NSLog(@"######## ERROR: COULDN'T READ BLINDS, value == 0");
        }
        
        NSLog(@"bigBlind: %llu",self.pokerTable.blindBig);
    }
}
- (unsigned long long)readMyTableChips{
    // read chips for my player, should only be triggered while player is seated.
    unsigned long long result = 0;
    
    NSImage *tableScreenshot = [self.coordManager.windowImage clearForTableChips];
    NSImage *p7TableChipsImage = [self.coordManager.p7TableChips getPlainImageFromScreenshot:tableScreenshot];
    NSString *p7TableChips = [[PokerTable tessAPI] getCurrencyValueFromImage:p7TableChipsImage];
    
    result += [p7TableChips betValue:@"p7 table chips"];
    
    NSLog(@"got p7 table chips: %@, %llu",p7TableChips, result);
    
    return result;
}

// delegate methods
- (void)didReadTotalChips:(long long int)totalChips{//updateStatsWithNewValue
    NSLog(@"didReadTotalChips: %lld",totalChips);
    if(totalChips != 0){
        // set starting value if not yet set
        if(self.pokerTable.totalStartingChips == 0){
            NSLog(@"setting startingChipCount, since it's currently at 0");
            self.pokerTable.totalStartingChips = totalChips;
            //self.startingTotalChipsField.stringValue = [self formatMoneyAsString:totalChips];
        }
        if(self.pokerTable.totalChips == 0){
            self.pokerTable.totalChips = totalChips;
        }
        
        PokerTable.logger.chipsTotal = totalChips;
        
        // if new chips are more than previous chips, then assume win
        if(self.pokerTable.totalChips < totalChips && self.pokerTable.totalChips != 0){
            NSLog(@"==== WIN total chip count increased from %lld to %lld",self.pokerTable.totalChips, totalChips);
            [self didWinRound:totalChips - self.pokerTable.totalChips];
            
        }else if(self.pokerTable.totalChips > totalChips){
            NSLog(@"==== LOSS total chip count decreased from %lld to %lld",self.pokerTable.totalChips, totalChips);
            [self didLoseRound:totalChips - self.pokerTable.totalChips];
        }else{
            // no change in chip count
        }
        
        //NSLog(@"updating total chip count");
        self.pokerTable.totalChips = totalChips;
        //[self.totalChipsField setStringValue:[self formatMoneyAsString:totalChips]];
        
        long long int difference = self.pokerTable.totalChips - self.pokerTable.totalStartingChips;
        if(difference == 0) return;
        
        //NSLog(@"got difference between start and new: %lld",difference);
        /*

        self.totalDiffField.stringValue = [self formatMoneyAsString:difference];
        NSLog(@"got difference between start and new formatted: %@",self.totalDiffField.stringValue);
        
        float percentageDifference = (((float)self.pokerTable.tableChips / (float)self.pokerTable.tableStartingChips) * 100) - 100;
        self.totalPercentChange.stringValue = [NSString stringWithFormat:@"%0.2f%@",percentageDifference,@"%"];
        if(percentageDifference > 0){
            [self.totalChipsField       setTextColor:[NSColor colorWithCalibratedRed: 0.1 green: 0.5 blue: 0.1 alpha: 1]];
            [self.totalPercentChange    setTextColor:[NSColor colorWithCalibratedRed: 0.1 green: 0.5 blue: 0.1 alpha: 1]]; //dark green colour
            [self.totalDiffField        setTextColor:[NSColor colorWithCalibratedRed: 0.1 green: 0.5 blue: 0.1 alpha: 1]]; //dark green colour
        }else if(percentageDifference < 0){
            [self.totalChipsField       setTextColor:[NSColor redColor]];
            [self.totalPercentChange setTextColor:[NSColor redColor]];
            [self.totalDiffField setTextColor:[NSColor redColor]];
        }//*/
        //NSLog(@"percent difference: %f",percentageDifference);
    }
}
- (void)didWinRound:(long long int)amount{
    if(self.pokerTable.myPlayer.lastWinnings == 0){
        self.pokerTable.myPlayer.wins++;
    }
    
    // in case there's multiple pots in play, and we won more than 1
    self.pokerTable.myPlayer.lastWinnings += amount;
    
    PokerTable.logger.chipsDifferenceTotal = amount;
    PokerTable.logger.pocketCards = self.pokerTable.myPlayer.lastHand;
    PokerTable.logger.didWin = 1;
    PokerTable.logger.playerCountEnd = self.pokerTable.numberPlayersWithCards;
    PokerTable.logger.finalHand = self.pokerTable.myPlayer.handMatch;
    
    //[PokerTable.logger clearForGameState:self.pokerTable.gameState];
    [PokerTable.logger write:@"handleWin:"];
    NSLog(@"===== total winnings: %lld (total: %lld) with hand: %@",amount, self.pokerTable.myPlayer.lastWinnings, self.pokerTable.myPlayer.lastHand);
    
    [self didStartNewRound:@"didWin"];
}
- (void)didLoseRound:(long long int)amount{
    if(self.pokerTable.myPlayer.lastWinnings == 0){
        self.pokerTable.myPlayer.losses++;
    }
    
    PokerTable.logger.chipsDifferenceTotal = amount;
    PokerTable.logger.pocketCards = self.pokerTable.myPlayer.lastHand;
    PokerTable.logger.didWin = -1;
    PokerTable.logger.playerCountEnd = self.pokerTable.numberPlayersWithCards;
    PokerTable.logger.finalHand = self.pokerTable.myPlayer.handMatch;
    
    //[PokerTable.logger clearForGameState:self.pokerTable.gameState];
    [PokerTable.logger write:@"handleLoss:"];
    NSLog(@"===== total loss: %lld - with hand: %@",amount, self.pokerTable.myPlayer.lastHand);
    
    [self didStartNewRound:@"didLose"];
}
- (void)didStartNewRound:(NSString*)source{
    NSLog(@"##### new round started - round number %ld, %@",(long)self.pokerTable.numberRoundsTotal, source);
    
    // reset round and +1 round count
    self.pokerTable.numberRoundsTotal++;
    self.pokerTable.numberRoundsTable++;
    
    self.pokerTable.gameState = kBlinds;
    
    // just in case we couldn't read earlier
    [self readBlinds];
}

// actions on game interface
- (void)triggerCheck{
    [self.zyngaPokerWindow triggerClick:self.coordManager.buttonActionTopLeft.getClickablePoint];
}
- (void)triggerFold{
    [self.zyngaPokerWindow triggerClick:self.coordManager.buttonActionTopRight.getClickablePoint];
}
- (void)triggerCall{
    [self.zyngaPokerWindow triggerClick:self.coordManager.buttonActionTopLeft.getClickablePoint];
}
- (void)triggerRaise:(long long)amount{
    [self.zyngaPokerWindow typeString:[NSString stringWithFormat:@"%lld",amount] atPoint:self.coordManager.raiseAmount.getClickablePoint];
}
- (void)triggerAllIn{
    [self.zyngaPokerWindow triggerClick:self.coordManager.buttonActionAllIn.getClickablePoint];
    sleep(0.2);
    
    [self.zyngaPokerWindow triggerClick:self.coordManager.buttonActionBottomLeft.getClickablePoint];
}
- (void)triggerTableChange{
    self.pokerTable.isChangingTables = true;
    // logic to trigger table change
    
    // click on new table button
    [self.zyngaPokerWindow triggerClick:self.coordManager.buttonNewTable.getClickablePoint];
    
    // delay
    NSLog(@"##### triggerTableChange: sleeping 1");
    sleep(1);
    
    // get newest image
    self.coordManager.windowImage = self.zyngaPokerWindow.screenshot;
    //[self.mainImageView setImage:self.coordManager.windowImage];
    
    // get OK button, and then click on it if found
    NSRect resultRect;
    BOOL result = [self.coordManager getNewTablePlayButton:&resultRect];
    int changeAttempts = 0;
    while(!result){
        changeAttempts++;
        NSLog(@"##### triggerTableChange: failed %d times",changeAttempts);
        if(changeAttempts > 3) return;

        NSLog(@"##### triggerTableChange: sleeping 1 then trying again");
        sleep(1);
        result = [self.coordManager getNewTablePlayButton:&resultRect];
    }
    
    //NSLog(@"=======## found image at location: %@",NSStringFromRect(resultRect));
    [self.zyngaPokerWindow triggerClick:resultRect.origin];
    self.pokerTable.shouldChangeTable = false;
    self.pokerTable.justChangedTable = true;
    self.pokerTable.isChangingTables = false;
        
    self.pokerTable.numberRoundsTable = 0;
}

// track if already raised once this game state
- (void)triggerTurnWithDecision:(PokerChoice*)decision{
    //NSNumber *timeStampObj = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]];
    //[self.zyngaPokerWindow.windowImage saveAsPNGWithName:[NSString stringWithFormat:@"%@/development/auto/playerTurn-%@.png",kPathImageRoot,timeStampObj]];
    
    if(decision.nextAction != kActionWait && decision.nextAction != kActionUnknown){
        PokerTable.logger.gameState = [self.pokerTable getStringFromState:self.pokerTable.gameState];
        PokerTable.logger.playerAction = [decision getStringFromNextAction:decision.nextAction];
    }
    
    PokerTable.logger.winningOdds = self.pokerTable.myPlayer.odds.win;
    [self.pokerTable.myPlayer getPocketCards];
    
    PokerTable.logger.pocketCards = self.pokerTable.myPlayer.lastHand;
    PokerTable.logger.pocketCardsSuited = self.pokerTable.myPlayer.isHandSuited;
    PokerTable.logger.playerCountStart = self.pokerTable.numberPlayersWithCards;
    
    //NSLog(@"triggering decision for cycle: %d, %d",loopCycle, withinLoop);
    
    switch(decision.nextAction){
        case kActionCheck:
            if(self.actionsEnabled){
                PokerTable.logger.playerAction = [decision getStringFromNextAction:decision.nextAction];
                PokerTable.logger.finalHand = self.pokerTable.myPlayer.handMatch;
                
                [self triggerCheck];
                
            }
            break;
            
        case kActionFold:
            //NSLog(@"#####warning deliberately not yet folding, player needs to click!!");
            if(self.actionsEnabled){
                if(decision.callAmount == 0){
                    PokerTable.logger.finalHand = self.pokerTable.myPlayer.handMatch;
                    PokerTable.logger.playerCountEnd = self.pokerTable.numberPlayersWithCards;
                    
                    [PokerTable.logger clearForGameState:self.pokerTable.gameState];
                    [PokerTable.logger write:@"fold:"];
                }
                
                [self triggerFold];
                [self.pokerTable.myPlayer didFold];
                
            }
            break;
            
        case kActionCall:
            if(self.actionsEnabled){
                PokerTable.logger.playerAction = [decision getStringFromNextAction:decision.nextAction];
                PokerTable.logger.playerActionAmount = decision.callAmount;
                
                [self triggerCall];
                [self.pokerTable.myPlayer didCall:decision.callAmount];
                
            }
            break;
            
        case kActionRaise:
            if(self.actionsEnabled){
                PokerTable.logger.playerAction = [decision getStringFromNextAction:decision.nextAction];
                PokerTable.logger.playerActionAmount = decision.raiseAmount;
                
                [self triggerRaise:decision.raiseAmount];
                [self.pokerTable.myPlayer didRaise:decision.raiseAmount];
                self.didRaise = true;
            }
            break;
            
            
            
        case kActionAllIn:
            if(self.actionsEnabled){
                PokerTable.logger.playerAction = [decision getStringFromNextAction:decision.nextAction];
                PokerTable.logger.playerActionAmount = self.pokerTable.tableChips;
                
                [self triggerAllIn];
                [self.pokerTable.myPlayer didRaise:self.pokerTable.tableChips];
                self.didRaise = true;
            }
            break;
            
        case kActionWait:
            NSLog(@"waiting, due to error");
            break;
            
        case kActionUnknown:
            NSLog(@"WARNING: Unhandled action logic");
            break;
    }
    
    if(!self.actionsEnabled) NSLog(@"WARNING: actions paused");
}
- (void)didCompleteMainReadLoop{
    self.isInMainLoop = false;
}

- (void)mainReadLoop{
    if(self.isInMainLoop) return;
    
    if(self.isPaused) {
        NSLog(@"bot paused");
        return;
    }
    
    self.isInMainLoop = true;
    loopCycle++;
    
    @autoreleasepool {
        
        //NSLog(@"readloop");
        [self startCount];
        //[self reloadImageDictionary];
        
        self.coordManager.windowImage = self.zyngaPokerWindow.screenshot;
        //[self.mainImageView setImage:self.coordManager.windowImage];
        
        if([self.coordManager hasChipMoved] || ![self.coordManager haveChipLocation]){
            [self referencePointDidMove];
        }
        else{
            
            if([self.coordManager isOnTable]){
                //NSLog(@"is on table");
                
                // probably use isChangingTables here
                
                [self readTableCards];
                [self readPlayersPlaying];
                
                if([self.coordManager isSeated]){
                    //NSLog(@"is seated");
                    self.pokerTable.myPlayer.isSeated = true;
                    
                    // read table chips for my player
                    unsigned long long tableChips = [self readMyTableChips];
                    if(tableChips != 0){
                        self.pokerTable.tableChips = tableChips;
                        
                        if(self.pokerTable.justChangedTable && tableChips != 0){
                            // update starting chips
                            self.pokerTable.tableStartingChips = tableChips;
                            //NSLog(@"set table starting chips to: %llu", self.pokerTable.tableStartingChips);
                            self.pokerTable.justChangedTable = false;
                        }
                        if(self.pokerTable.tableChips != 0 && self.pokerTable.tableStartingChips != 0){
                            float differenceFactor = ((float)self.pokerTable.tableChips / (float)self.pokerTable.tableStartingChips);
                            if(differenceFactor >= changeTableMultiplier){
                                NSLog(@"###### queueing table change - tableChips: %llu, tableStartingChips: %llu, differenceFactor, %f",self.pokerTable.tableChips, self.pokerTable.tableStartingChips, differenceFactor);
                                self.pokerTable.shouldChangeTable = true;
                            }
                            
                            NSLog(@"table chips starting(%llu) and current (%llu), difference factor: (%f)",self.pokerTable.tableStartingChips,self.pokerTable.tableChips, differenceFactor);
                        }
                    }
                    
                    //if([self.coordManager isNewRound]) [self handleNewRound];
                    if(self.pokerTable.myPlayer.hasHand){
                        
                        [self checkTimeTaken:@"--= realised I have a hand"];
                        self.pokerTable.myPlayer.lastWinnings = 0;
                        [self.pokerTable.myPlayer.odds clear];
                        
                        [self readPlayerCards];
                        [self checkTimeTaken:@"--= read player cards"];
                        
                        [self.pokerTable getOdds];
                        
                        [self checkTimeTaken:@"--= calculated odds"];
                        
                        
                        if([self.coordManager isPlayerTurn]){
                            [self checkTimeTaken:@"--== realised its my turn"];
                            
                            [self.pokerTable setPlayerState:kPlayerStateTurn];
                            [self.pokerTable.myPlayer getPocketCards];
                            [self checkTimeTaken:@"--== got my pocket cards"];
                            
                            
                            PokerChoice *decision = [self.coordManager getAvailableChoicesForTable:self.pokerTable];
                            decision.didRaise = self.didRaise;
                            [decision makeDecision];
                            
                            [self checkTimeTaken:@"--== made a decision"];
                            
                            [self triggerTurnWithDecision:decision];
                            [self checkTimeTaken:@"--======================= end of player turn"];
                            
                        }else{
                            [self.pokerTable setPlayerState:kPlayerStateWaitingForTurn];
                        }
                        [self checkTimeTaken:@"--======================= end of have hand logic"];
                        
                        
                    }else{
                        //self.pokerTable.myPlayer.lastHand = @"";
                        
                        //[self.myCard1View setImage:nil];
                        //[self.myCard2View setImage:nil];
                        [self.pokerTable setPlayerState:kPlayerStateWaitingForHand];
                        
                        
                        if(self.pokerTable.shouldChangeTable){
                            NSLog(@"####### CHANGING TABLES #######");
                            [self triggerTableChange];
                        }
                    }
                }else{
                    self.pokerTable.myPlayer.isSeated = false;
                    
                    NSLog(@"###### is not seated");
                    [self.pokerTable setPlayerState:kPlayerStateWaitingForSeat];
                    // logic to look for seat
                    
                    // click on seat
                    
                    // click "buy in" coordinate
                    
                    
                }
            }else{
                NSLog(@"WARNING: table not detected, am I in lobby?");//am I on table selection screen? (refresh list)
                [self.pokerTable setPlayerState:kPlayerStateInLobby];
            }
            
        }
        
        [self checkTimeTaken];
        
    }
    // delay next loop execution by at least 1 second
    [self performSelector:@selector(didCompleteMainReadLoop) withObject:nil afterDelay:1.2];
}


@end
