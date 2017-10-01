//
//  StateMonitoringWindow.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "StateMonitoringWindow.h"
#import "AppDelegate.h"
#import "NSImage+subImage.h"
#import "PATemplateMatch.hpp"
#import "CVHelper.hpp"
#import "CVSearchHelper.hpp"
#import "NSData+Adler32.h"
#import "NSString+cleaning.h"
#import "constants.h"
#import "Enums.h"
#import "POdds.h"
#import "NSScreen+PointConversion.h"
#import "Tesseract.h"
#import "NumbersHelper.h"

#import "PokerManager.h"


@interface StateMonitoringWindow ()

@end

@implementation StateMonitoringWindow
static AppDelegate* appDelegate;

//static BOOL haveChip __attribute__((deprecated("move this to the coordinatesManager")));

static NSString *tableCard1Val __attribute__((deprecated("replace with pkManager.pokerTable.card1.stringValue etc")));
static NSString *tableCard2Val;
static NSString *tableCard3Val;
static NSString *tableCard4Val;
static NSString *tableCard5Val;
static NSMutableArray *cardsOnTable;

static NSString *playerCard1Val;
static NSString *playerCard2Val;

static void * Card1Context = &Card1Context;
static void * Card2Context = &Card2Context;



static PokerManager* pkManager;


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    appDelegate = [[NSApplication sharedApplication] delegate];
    
    pkManager = [[PokerManager alloc] init];
    
    
    
    
    
    
    
    
    
    cardsOnTable = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 5; ++i)
    {
        [cardsOnTable addObject:[NSNull null]];
    }
    
    [pkManager.pokerTable addObserver:self forKeyPath:kGameStateKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable addObserver:self forKeyPath:kPlayersWithCardsKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    //pkManager.pokerTable.playerState
    
   // [pkManager.pokerTable.myPlayer addObserver:self forKeyPath:kLastOddsQueryKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable.myPlayer.odds addObserver:self forKeyPath:kDictionaryPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable.myPlayer addObserver:self forKeyPath:kHasHandKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable.myPlayer addObserver:self forKeyPath:kHandMatchKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];

    [pkManager.pokerTable.myPlayer.card1 addObserver:self forKeyPath:kPathdbgValue options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:Card1Context];
    [pkManager.pokerTable.myPlayer.card2 addObserver:self forKeyPath:kPathdbgValue options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:Card2Context];
    [pkManager.pokerTable addObserver:self forKeyPath:kPlayerStateKeyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable addObserver:self forKeyPath:kKeyPathTotalPots options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable addObserver:self forKeyPath:kKeyPathTotalBets options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable addObserver:self forKeyPath:kKeyPathTotalChips options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable addObserver:self forKeyPath:kKeyPathBBlind options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable addObserver:self forKeyPath:kKeyPathTotalRounds options:NSKeyValueObservingOptionNew context:nil];
    
    [pkManager.pokerTable.card1 addObserver:self forKeyPath:kKeyPathStringValue options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable.card2 addObserver:self forKeyPath:kKeyPathStringValue options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable.card3 addObserver:self forKeyPath:kKeyPathStringValue options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable.card4 addObserver:self forKeyPath:kKeyPathStringValue options:NSKeyValueObservingOptionNew context:nil];
    [pkManager.pokerTable.card5 addObserver:self forKeyPath:kKeyPathStringValue options:NSKeyValueObservingOptionNew context:nil];
    
    [PokerTable.IMIndex addObserver:self forKeyPath:kUnknownImagesCount options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"observeValueForKeyPath StateMonitoringWindow called: %@ - change: %@",keyPath, change);
    // handle changes to the blinds
    if(keyPath == nil) return;
    
    if(kGameStateKeyPath != nil && [keyPath isEqualToString:kGameStateKeyPath]){
        [self handleGameStateChanged:change];
    }
    else if(kLastOddsQueryKeyPath != nil && [keyPath isEqualToString:kLastOddsQueryKeyPath]){
        [self handleLastOddsQueryChanged:change];
    }else if(kDictionaryPath != nil && [keyPath isEqualToString:kDictionaryPath]){
        [self handlePlayerOddsDictionaryChanged:change];
    }
    else if(kHasHandKeyPath != nil && [keyPath isEqualToString:kHasHandKeyPath]){
        [self handleHaveHandChanged:change];
    }
    else if(kUnknownImagesCount != nil && [keyPath isEqualToString:kUnknownImagesCount]){
        [self handleUnknownImageCountChange:change];
    }
    else if(kPathdbgValue != nil && [keyPath isEqualToString:kPathdbgValue]){
        [self handleMyPlayerDbgValueChange:change context:context];
    }
    else if(kPlayerStateKeyPath != nil && [keyPath isEqualToString:kPlayerStateKeyPath]){
        [self handlePlayerStateChange:change];
    }else if(kHandMatchKeyPath != nil && [keyPath isEqualToString:kHandMatchKeyPath]){
        [self handleHandMatchChanged:change];
    }else if(kKeyPathTotalPots != nil && [keyPath isEqualToString:kKeyPathTotalPots]){
        [self handleTotalPotsChanged:change];
    }else if(kKeyPathTotalBets != nil && [keyPath isEqualToString:kKeyPathTotalBets]){
        [self handleTotalBetsChanged:change];
    }else if([keyPath isEqualToString:kKeyPathTotalChips]){
        [self handleTotalChipsChanged:change];
    }else if([keyPath isEqualToString:kPlayersWithCardsKeyPath]){
        [self handlePlayerCountChanged:change];
    }else if([keyPath isEqualToString:kKeyPathStringValue]){
        [self handleCommunityCardChanged:change];
    }else if([keyPath isEqualToString:kKeyPathBBlind]){
        [self handleBigBlindChanged:change];
    }else if([keyPath isEqualToString:kKeyPathTotalRounds]){
        [self handleTotalRoundsChanged:change];
    }
}
- (void)handleTotalRoundsChanged:(NSDictionary*)change{
    self.roundsPlayedField.stringValue = [NSString stringWithFormat:@"%d", pkManager.pokerTable.numberRoundsTotal];
    self.tableRoundsPlayedField.stringValue = [NSString stringWithFormat:@"%d", pkManager.pokerTable.numberRoundsTable];
}
- (void)handleBigBlindChanged:(NSDictionary*)change{
    self.blindsSizeField.stringValue = [NumbersHelper formatMoneyAsString:pkManager.pokerTable.blindBig];
}
- (void)handleCommunityCardChanged:(NSDictionary*)change{
    NSString *tableCard1Val = pkManager.pokerTable.card1.stringValue;
    if(tableCard1Val == nil) tableCard1Val = pkManager.pokerTable.card1.dbgValue;
    if(tableCard1Val == nil) tableCard1Val = @"unkn";
    self.flop1Txt.stringValue = tableCard1Val;
    
    NSString *tableCard2Val = pkManager.pokerTable.card2.stringValue;
    if(tableCard2Val == nil) tableCard2Val = pkManager.pokerTable.card2.dbgValue;
    if(tableCard2Val == nil) tableCard2Val = @"unkn";
    self.flop2Txt.stringValue = tableCard2Val;
    
    NSString *tableCard3Val = pkManager.pokerTable.card3.stringValue;
    if(tableCard3Val == nil) tableCard3Val = pkManager.pokerTable.card3.dbgValue;
    if(tableCard3Val == nil) tableCard3Val = @"unkn";
    self.flop3Txt.stringValue = tableCard3Val;
    
    NSString *tableCard4Val = pkManager.pokerTable.card4.stringValue;
    if(tableCard4Val == nil) tableCard4Val = pkManager.pokerTable.card4.dbgValue;
    if(tableCard4Val == nil) tableCard4Val = @"unkn";
    self.flop4Txt.stringValue = tableCard4Val;
    
    NSString *tableCard5Val = pkManager.pokerTable.card5.stringValue;
    if(tableCard5Val == nil) tableCard5Val = pkManager.pokerTable.card5.dbgValue;
    if(tableCard5Val == nil) tableCard5Val = @"unkn";
    self.flop5Txt.stringValue = tableCard5Val;
    
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
            self.playersWithHandField.stringValue = [NSString stringWithFormat:@"%d",newInt];
        }
    }
}
- (void)handleTotalChipsChanged:(NSDictionary*)change{
    long long int difference = pkManager.pokerTable.totalChips - pkManager.pokerTable.totalStartingChips;
    
    self.startingTotalChipsField.stringValue = [NumbersHelper formatMoneyAsString:pkManager.pokerTable.totalStartingChips];
    self.totalChipsField.stringValue = [NumbersHelper formatMoneyAsString:pkManager.pokerTable.totalChips];
    self.totalDiffField.stringValue = [NumbersHelper formatMoneyAsString:difference];
    NSLog(@"got difference between start and new formatted: %@",self.totalDiffField.stringValue);
    
    if(difference == 0) return;
    float percentageDifference = (((float)pkManager.pokerTable.totalChips / (float)pkManager.pokerTable.totalStartingChips) * 100) - 100;
    self.totalPercentChange.stringValue = [NSString stringWithFormat:@"%0.2f%@",percentageDifference,@"%"];
    if(percentageDifference > 0){
        [self.totalChipsField       setTextColor:[NSColor colorWithCalibratedRed: 0.1 green: 0.5 blue: 0.1 alpha: 1]];
        [self.totalPercentChange    setTextColor:[NSColor colorWithCalibratedRed: 0.1 green: 0.5 blue: 0.1 alpha: 1]];
        [self.totalDiffField        setTextColor:[NSColor colorWithCalibratedRed: 0.1 green: 0.5 blue: 0.1 alpha: 1]];
        
    }else if(percentageDifference < 0){
        [self.totalChipsField       setTextColor:[NSColor redColor]];
        [self.totalPercentChange    setTextColor:[NSColor redColor]];
        [self.totalDiffField        setTextColor:[NSColor redColor]];
        
    }
    //NSLog(@"percent difference: %f",percentageDifference);
    
}
- (void)handleGameStateChanged:(NSDictionary *)change{
    if([change[@"old"] intValue] != [change[@"new"] intValue]){
        [self gameStateDidChange:(GameState)[change[@"new"] intValue]];
    }
}
- (void)handleLastOddsQueryChanged:(NSDictionary*)change{
    NSString *lastKeyPath = [NSString stringWithFormat:@"%@",change[@"new"]];
    if(lastKeyPath == nil) return;
    
    //NSLog(@"last key path: %@",lastKeyPath);
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        //Run UI Updates

    });
}
- (void)handlePlayerOddsDictionaryChanged:(NSDictionary*)change{
    NSString *newValue = [NSString stringWithFormat:@"%@",change[@"new"]];
    if(newValue == nil) return;
    
    ////{"cores":8,"games":200000,"win":0.161,"draw":0.025,"pair":0.518,"two-pairs":0.374,"three-of-a-kind":0.067,"straight":0.015,"flush":0.000,"full-house":0.025,"four-of-a-kind":0.001,"straight-flush":0.000}

    [self.oddsWinTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.win]];
    [self.oddsDrawTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.draw]];

    [self.oddsPairTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.pair]];
    [self.odds2PairTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.twoPair]];
    [self.odds3OfAKindTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.threeOfAKind]];
    [self.oddsStraightTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.straight]];
    [self.oddsFlushTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.flush]];
    [self.oddsFullHouseTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.fullHouse]];
    [self.odds4OfAKindTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.fourOfAKind]];
    [self.oddsStraightFlushTxt setStringValue:[NSString formatPercentageFromFloat:pkManager.pokerTable.myPlayer.odds.straightFlush]];
    
    if(pkManager.pokerTable.myPlayer.lastOddsQuery != nil) [self.oddsTxt setStringValue:pkManager.pokerTable.myPlayer.lastOddsQuery];
}

- (void)handleHaveHandChanged:(NSDictionary*)change{
    NSNumber *oldValue = change[@"old"];
    NSNumber *newValue = change[@"new"];
    
    if([oldValue isKindOfClass:[NSNumber class]] && [newValue isKindOfClass:[NSNumber class]]){
        int oldInt = [oldValue intValue];
        int newInt = [newValue intValue];
        
        if(oldInt != newInt){
            NSLog(@"haveHand changed from %d to %d",oldInt,newInt);
            if(oldInt == 0 && newInt == 1){
                [PokerTable.logger clearForGameState:kBlinds];
            }else if(oldInt == 1 && newInt == 0){
                [self didFold];
            }            
        }
    }
}
- (void)didFold{
    NSLog(@"##### player folded");
    self.myCard1Txt.stringValue = @"folded";
    self.myCard2Txt.stringValue = @"folded";
}
- (void)handleUnknownImageCountChange:(NSDictionary*)change{
    if(change[@"new"] != nil){
        //if([change[@"new"] intValue] == [change[@"old"] intValue]) return;
        NSLog(@"unknownImagesCount changed: %@",change);
        [self updateKnownImagesCount];
    }
}
- (void)handleMyPlayerDbgValueChange:(NSDictionary*)change context:(void*)context{
    if(change[@"new"] != nil){
        NSString *value;
        if(context == Card1Context){
            if([pkManager.pokerTable.myPlayer.card1.dbgValue isEqualToString:kCardTypeCard])
                value = pkManager.pokerTable.myPlayer.card1.stringValue;
            else
                value = pkManager.pokerTable.myPlayer.card1.dbgValue;
            
            if(value == nil) value = @"unkn";
            [[self myCard1Txt] setStringValue:value];
        }
        if(context == Card2Context){
            if([pkManager.pokerTable.myPlayer.card2.dbgValue isEqualToString:kCardTypeCard])
                value = pkManager.pokerTable.myPlayer.card2.stringValue;
            else
                value = pkManager.pokerTable.myPlayer.card2.dbgValue;
            
            if(value == nil) value = @"unkn";
            [[self myCard2Txt] setStringValue:value];
        }
    }
}
- (void)handlePlayerStateChange:(NSDictionary*)change{
    if([change[@"old"] intValue] == kPlayerStateInLobby){
        [pkManager performSelector:@selector(readBlinds) withObject:nil afterDelay:3];
    }
    
    switch([change[@"new"] intValue]) {
        case kPlayerStateInLobby:
            [self.playerStateTxt setStringValue:@"kInLobby"];
            break;
            
        case kPlayerStateWaitingForSeat:
            [self.playerStateTxt setStringValue:@"kWaitingForSeat"];
            break;
            
        case kPlayerStateSeated:
            [self.playerStateTxt setStringValue:@"kSeated"];
            break;
            
            /*//unused
        case kPlayerStateWaitingForNewGame:
            [self.playerStateTxt setStringValue:@"kWaitingForNewGame"];
            break;//*/
            
        case kPlayerStateWaitingForHand:
            [self.playerStateTxt setStringValue:@"kWaitingForHand"];
            break;
            
        case kPlayerStateWaitingForTurn:
            [self.playerStateTxt setStringValue:@"kWaitingForTurn"];
            break;
            
        case kPlayerStateTurn:
            [self.playerStateTxt setStringValue:@"!player turn!"];
            break;
            
        case kPlayerStateUnknown:
            [self.playerStateTxt setStringValue:@"kPlayerStateUnknown"];
            break;
            
            
    }
}
- (void)handleHandMatchChanged:(NSDictionary*)change{
    [self.highestHandStr setStringValue:change[@"new"]];
}
- (void)handleTotalPotsChanged:(NSDictionary*)change{
    self.totalPotField.stringValue = [NumbersHelper formatMoneyAsString:[change[@"new"] unsignedLongLongValue]];
}
- (void)handleTotalBetsChanged:(NSDictionary*)change{
    self.totalBetsField.stringValue = [NumbersHelper formatMoneyAsString:[change[@"new"] unsignedLongLongValue]];
}

// test methods
/*
- (void)testTotalChipReading{
    NSImage *tableImage = [CVHelper NSImageFromPath:@"/Users/tsiebler/Screenies/Screen Shot 2017-05-07 at 11.56.09.png"];
    [appDelegate.mainImageView setImage:tableImage];
    
    [self calibrateForTestImage:tableImage];
    
    //[self updateTotalChips];
    if(![readTotalChipsTimer isValid]) readTotalChipsTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(readTotalChips) userInfo:nil repeats: YES];

}//*/
- (void)calibrateForTestImage:(NSImage*)tableImage{
    pkManager.zyngaPokerWindow.haveWindow = true;
    pkManager.coordManager.windowImage = tableImage;
    
    if(pkManager.coordManager.chipImage == nil)
        pkManager.coordManager.chipImage = [CVHelper NSImageFromBundle:kImageChip];
    
    
    NSError *error;
    BOOL result = [pkManager.coordManager getChipLocationWithError:&error];
    if(!result){
        NSLog(@"couldn't find chip: %@",error);
        return;
    }
    
    NSLog(@"got location of chip: %@",NSStringFromPoint(pkManager.coordManager.chipLocation.origin));
    [pkManager.coordManager getChipHash];
    [pkManager.coordManager calibrateCoordinatesFromTableMap];
}

- (void)updateKnownImagesCount{
    [[self knownImagesTxt] setStringValue:[NSString stringWithFormat:@"%d",PokerTable.IMIndex.knownImagesCount]];
    [[self unkownImagesTxt] setStringValue:[NSString stringWithFormat:@"%d",PokerTable.IMIndex.unknownImagesCount]];
    [[self percentageKnownTxt] setStringValue:[NSString stringWithFormat:@"%.003f%@",PokerTable.IMIndex.percentageKnown,@"%"]];
}

/*
- (void)triggerEvent:(InternalEvents)nextEvent{
    switch(nextEvent){
        case kNewGame:
            NSLog(@"new game started");
            pkManager.pokerTable.numberRoundsTotal++;
            pkManager.pokerTable.numberRoundsTable++;
            [[self roundsPlayedTxt] setStringValue:[NSString stringWithFormat:@"%ld", (long)pkManager.pokerTable.numberRoundsTotal]];
            break;
    }
}//*/

- (void)gameStateDidChange:(GameState)currGameState{
    switch(currGameState){
        case kBlinds:
            [self.gameStateTxt setStringValue:@"kBlinds"];
        break;
            
        case kFlop:
            [self.gameStateTxt setStringValue:@"kFlop"];
            break;
            
        case kTurn:
            [self.gameStateTxt setStringValue:@"kTurn"];
            break;
            
        case kRiver:
            [self.gameStateTxt setStringValue:@"kRiver"];
            break;
            
        default:
            [self.gameStateTxt setStringValue:@"unknown"];
            break;
    }
}

- (IBAction)takeScreenshot:(id)sender {
    [pkManager.zyngaPokerWindow screenshot];
    [appDelegate.mainImageView setImage:pkManager.zyngaPokerWindow.windowImage];
    [pkManager.zyngaPokerWindow.windowImage saveAsPNGWithName:@"/Users/tsiebler/Desktop/pkr/images/mainScreen.png"];
}

- (IBAction)findPokerWindow:(id)sender {
    [pkManager findWindow];
}
- (IBAction)findOtherCoordinates:(id)sender {
    [pkManager recalibrate];
}


- (void)dbgMousePos{
    NSPoint location = [NSEvent mouseLocation];
    
    for (id screen in [NSScreen screens]) {
        if (NSMouseInRect(location, [screen frame], NO)) {
            NSSize size = {1, 1};
            NSRect mouseRect = {location, size};
            NSRect retinaMouseRect = [screen convertRectToBacking:mouseRect];
            
            NSLog(@"Mouse Rect = %@", NSStringFromRect(mouseRect));
            NSLog(@"Retina Mouse Rect = %@", NSStringFromRect(retinaMouseRect));
        }
    }
}
//https://awwapp.com/
- (void)testWhiteboard:(BOOL)shouldClick{
    //NSScreen *screen = [NSScreen mainScreen];
    
    NSLog(@"clicking on top left button (call/check)");
    [pkManager.zyngaPokerWindow getWindowWithTitleContaining:@"whiteboard"];
    NSPoint testPoint = NSMakePoint(467, 1161);
    //CGFloat backingScaleFactor = [screen backingScaleFactor];
    
    //testPoint = [self getPointFromPixels:testPoint adjustment:5];
    
    // x is correct now.
    //testPoint.x -= pkManager.zyngaPokerWindow.windowBounds.origin.x;
    //testPoint.y -= pkManager.zyngaPokerWindow.windowBounds.origin.y * backingScaleFactor;//still flipped, should be
    //testPoint.y -= (pkManager.zyngaPokerWindow.windowBounds.origin.y * backingScaleFactor);
    
    NSLog(@"finalCoordinate: %@",NSStringFromPoint(testPoint));
    
    if(shouldClick){
        //testPoint = [self adjustForClick:testPoint];
        testPoint.y += pkManager.zyngaPokerWindow.windowBounds.origin.y;  testPoint.y += 5;
        [pkManager.zyngaPokerWindow triggerBackgroundClick:testPoint];

        //[pkManager.zyngaPokerWindow triggerClick:testPoint];
    }
    else
        [pkManager.zyngaPokerWindow moveMouse:testPoint];
}



NSTimer *readLoopTimer;
NSTimer *readPotTimer;
NSTimer *readChipTimer;

NSTimer *readTotalChipsTimer;
- (IBAction)readLoop:(id)sender {
    if(![readLoopTimer isValid]){
        readLoopTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:pkManager selector:@selector(mainReadLoop) userInfo:nil repeats: YES];
        //[self performSelector:@selector(startPotAndChipTimers) withObject:nil afterDelay:2.5];
    }
    else
        NSLog(@"timer already running");
    
    // bring back pot and chip timers if either crash
    if(![readPotTimer isValid]) readPotTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:pkManager selector:@selector(readPotLoop) userInfo:nil repeats: YES];
    if(![readChipTimer isValid]) readChipTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:pkManager selector:@selector(readBetsLoop) userInfo:nil repeats: YES];
    if(![readTotalChipsTimer isValid]) readTotalChipsTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:pkManager selector:@selector(readTotalChipsLoop) userInfo:nil repeats: YES];

}
- (IBAction)pause:(id)sender {
    pkManager.isPaused = !pkManager.isPaused;
    if(pkManager.isPaused) [self.pauseButton setTitle:@"Continue Read"];
    else [self.pauseButton setTitle:@"Pause Reading"];
}
- (IBAction)pauseActions:(id)sender {
    pkManager.actionsEnabled = !pkManager.actionsEnabled;
    if(!pkManager.actionsEnabled) [self.pauseActionsButton setTitle:@"Continue Acts"];
    else [self.pauseActionsButton setTitle:@"Pause Actions"];
}


- (IBAction)readBlinds:(id)sender {
    //pkManager.pokerTable.totalBets = [pkManager readCurrentBets];
    //pkManager.pokerTable.totalPots = [self readCurrentPots];
    
}
- (IBAction)testButton:(id)sender {
    pkManager.pokerTable.tableStartingChips = 5000;
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As Ad Ac"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As 5s Ac"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As 5s 3s"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As Ad Ac Ah"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As Ad 2c Ac"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As 4d 2c Ac"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As 4s 2s Ad"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As 4d 2c Ac"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As Qs Ks Js Ts"]]);
    NSLog(@"result: %@",[POdds getMatchString:[POdds getTopMatchForCards:@"As 4s 5s Ts 9s"]]);
    
    //getSuitOccurancesForTable
}



@end
