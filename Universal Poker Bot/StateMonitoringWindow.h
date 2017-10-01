//
//  StateMonitoringWindow.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Enums.h"

@interface StateMonitoringWindow : NSWindowController

// table cards
@property (strong) IBOutlet NSImageView *tableCard1;
@property (strong) IBOutlet NSImageView *tableCard2;
@property (strong) IBOutlet NSImageView *tableCard3;
@property (strong) IBOutlet NSImageView *tableCard4;
@property (strong) IBOutlet NSImageView *tableCard5;

// player hands
@property (strong) IBOutlet NSImageView *p1handview;
@property (strong) IBOutlet NSImageView *p2handview;
@property (strong) IBOutlet NSImageView *p3handview;
@property (strong) IBOutlet NSImageView *p4handview;
@property (strong) IBOutlet NSImageView *p5handview;
@property (strong) IBOutlet NSImageView *p6handview;
@property (strong) IBOutlet NSImageView *p8handview;
@property (strong) IBOutlet NSImageView *p9handview;

@property (strong) IBOutlet NSImageView *myCard1View;
@property (strong) IBOutlet NSImageView *myCard2View;

@property (strong) IBOutlet NSTextField *myCard1Txt;
@property (strong) IBOutlet NSTextField *myCard2Txt;


// recognised cards using hash method
@property (strong) IBOutlet NSTextField *flop1Txt;
@property (strong) IBOutlet NSTextField *flop2Txt;
@property (strong) IBOutlet NSTextField *flop3Txt;
@property (strong) IBOutlet NSTextField *flop4Txt;
@property (strong) IBOutlet NSTextField *flop5Txt;

@property (strong) IBOutlet NSTextField *card1Hash;
@property (strong) IBOutlet NSTextField *card2Hash;
@property (strong) IBOutlet NSTextField *card3Hash;
@property (strong) IBOutlet NSTextField *card4Hash;
@property (strong) IBOutlet NSTextField *card5Hash;

// various texts
@property (strong) IBOutlet NSTextField *windowFoundText;
@property (strong) IBOutlet NSTextField *chipLocationTxt;
@property (strong) IBOutlet NSTextField *gameStateTxt;
@property (strong) IBOutlet NSTextField *playerStateTxt;
@property (strong) IBOutlet NSTextField *botStateTxt;
@property (strong) IBOutlet NSTextField *onTableTxt;
@property (strong) IBOutlet NSTextField *seatedTxt;
@property (strong) IBOutlet NSTextField *haveCardsTxt;
@property (strong) IBOutlet NSTextField *waitingOnPlayerTxt;

@property (strong) IBOutlet NSTextField *knownImagesTxt;
@property (strong) IBOutlet NSTextField *unkownImagesTxt;
@property (strong) IBOutlet NSTextField *percentageKnownTxt;

@property (strong) IBOutlet NSTextField *oddsTxt;
@property (strong) IBOutlet NSTextField *oddsValueTxt;

@property (strong) IBOutlet NSTextField *oddsWinTxt;
@property (strong) IBOutlet NSTextField *oddsDrawTxt;
@property (strong) IBOutlet NSTextField *oddsPairTxt;
@property (strong) IBOutlet NSTextField *odds2PairTxt;
@property (strong) IBOutlet NSTextField *odds3OfAKindTxt;
@property (strong) IBOutlet NSTextField *oddsStraightTxt;
@property (strong) IBOutlet NSTextField *oddsFlushTxt;
@property (strong) IBOutlet NSTextField *oddsFullHouseTxt;
@property (strong) IBOutlet NSTextField *odds4OfAKindTxt;
@property (strong) IBOutlet NSTextField *oddsStraightFlushTxt;
@property (strong) IBOutlet NSTextField *playersWithHandField;


@property (strong) IBOutlet NSTextField *highestHandStr;

@property (strong) IBOutlet NSButton *pauseButton;
@property (strong) IBOutlet NSButton *pauseActionsButton;


@property (strong) IBOutlet NSTextField *startingTotalChipsField;
@property (strong) IBOutlet NSTextField *totalChipsField;
@property (strong) IBOutlet NSTextField *totalDiffField;
@property (strong) IBOutlet NSTextField *totalPercentChange;
@property (strong) IBOutlet NSTextField *playerTableChipsField;
@property (strong) IBOutlet NSTextField *blindsSizeField;

@property (strong) IBOutlet NSTextField *roundsPlayedField;
@property (strong) IBOutlet NSTextField *tableRoundsPlayedField;

@property (strong) IBOutlet NSTextField *totalPotField;
@property (strong) IBOutlet NSTextField *totalBetsField;



// helper methods
- (void)setChipLocation:(NSRect)chipLocationRect;
- (void)setGameState:(GameState)currGameState;
//-(void)setBotState:(BotState)currBotState;
@end
