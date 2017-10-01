//
//  constants.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 02/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#ifndef constants_h
#define constants_h

static NSString *kCardTypeSuit      = @"cardSuit";
static NSString *kCardTypeCard      = @"card";
static NSString *kCardTypeTable     = @"table";
static NSString *kCardTypeNoise     = @"noise";
//static NSString *kCardTypeButton    = @"button";
static NSString *kCardTypeUnknown   = @"unkn";

static NSString *kGameStateKeyPath      = @"gameState";
static NSString *kLastOddsQueryKeyPath  = @"lastOddsQuery";
static NSString *kPlayersWithCardsKeyPath = @"numberPlayersWithCards";
//static NSString *kWinningOddsPath       = @"winningOdds";
static NSString *kDictionaryPath        = @"dictionary";//for PokerOdds
static NSString *kHasHandKeyPath        = @"hasHand";
static NSString *kUnknownImagesCount    = @"unknownImagesCount";
static NSString *kPlayerStateKeyPath    = @"playerState";
static NSString *kHandMatchKeyPath      = @"handMatch";

static NSString *kKeyPathTotalPots      = @"totalPots";
static NSString *kKeyPathTotalBets      = @"totalBets";
static NSString *kKeyPathTotalChips     = @"totalChips";
static NSString *kKeyPathTotalRounds    = @"numberRoundsTotal";
static NSString *kKeyPathTableRounds    = @"numberRoundsTable";
static NSString *kKeyPathStringValue    = @"stringValue";
static NSString *kKeyPathDbgValue       = @"dbgValue";
static NSString *kKeyPathBBlind         = @"blindBig";


//self.pokerTable.playerState


static NSString *kCardSuitHeart     = @"h";
static NSString *kCardSuitClub      = @"c";
static NSString *kCardSuitDiamond   = @"d";
static NSString *kCardSuitSpade     = @"s";

static NSString *kCardValue2        = @"2";
static NSString *kCardValue3        = @"3";
static NSString *kCardValue4        = @"4";
static NSString *kCardValue5        = @"5";
static NSString *kCardValue6        = @"6";
static NSString *kCardValue7        = @"7";
static NSString *kCardValue8        = @"8";
static NSString *kCardValue9        = @"9";
static NSString *kCardValue10       = @"T";
static NSString *kCardValueJ        = @"J";
static NSString *kCardValueQ        = @"Q";
static NSString *kCardValueK        = @"K";
static NSString *kCardValueA        = @"A";

static NSString *kPathImageRoot     = @"/Users/tsiebler/Desktop/pkr/images";
static NSString *kPathKnown         = @"known";
static NSString *kPathUnknown       = @"unknown";
static NSString *kPathCards         = @"cards";
static NSString *kPathUnknownCards  = @"card";
static NSString *kPathButtons       = @"buttons";
static NSString *kPathUnknownButtons= @"button";

static NSString *kPathTable         = @"_table";
static NSString *kPathNoise         = @"_noise";
static NSString *kPathSuits         = @"_suits";
static NSString *kPathPlayerHands   = @"playerHands";
static NSString *kPathdbgValue      = @"dbgValue";


static NSString *kButtonStringFold      = @"Fold";
static NSString *kButtonStringInactive  = @"Inactive";
static NSString *kButtonStringCheck     = @"Check";
static NSString *kButtonStringAllIn     = @"AllIn";
static NSString *kButtonStringNewTable  = @"NewTable";
static NSString *kButtonStringStandUp   = @"StandUp";
static NSString *kButtonStringRaise     = @"Raise";
static NSString *kButtonStringCall      = @"Call";

static NSString *kImageChip             = @"chip";
static NSString *kImageDealerChip       = @"dealerChip";
static NSString *kImageMoney            = @"money";
static NSString *kImageBlinds           = @"tableBlinds";
static NSString *kImageButtonChatSend   = @"buttonChatSend";
static NSString *kImageButtonNewTable   = @"buttonNewTable";
static NSString *kImageButtonStandUp    = @"buttonStandUp";
static NSString *kImageButtonToLobby    = @"buttonToLobby";
static NSString *kImageButtonFoldActive = @"buttonToLobby";
static NSString *kImageButtonBottomLeft = @"buttonActionBottomLeft";
static NSString *kImageButtonBottomRight= @"buttonActionBottomRight";
static NSString *kImageButtonTopLeft    = @"buttonActionTopLeft";
static NSString *kImageButtonTopRight   = @"buttonActionTopRight";
static NSString *kImageButtonHalfPot    = @"buttonActionHalfPot";
static NSString *kImageButtonPot        = @"buttonActionPot";
static NSString *kImageButtonAllIn      = @"buttonActionAllIn";
static NSString *kImageRaiseAmount      = @"valueRaiseAmount";
static NSString *kImageNewTablePlay     = @"newTablePlay";

static NSString *kPlayerBet1            = @"playerBet1";
static NSString *kPlayerBet2            = @"playerBet2";
static NSString *kPlayerBet3            = @"playerBet3";
static NSString *kPlayerBet4            = @"playerBet4";
static NSString *kPlayerBet5            = @"playerBet5";
static NSString *kPlayerBet6            = @"playerBet6";
static NSString *kPlayerBet7            = @"playerBet7";
static NSString *kPlayerBet8            = @"playerBet8";
static NSString *kPlayerBet9            = @"playerBet9";

static NSString *kPlayerTableChips7     = @"playerTableChips7";

static NSString *kMainPot               = @"mainPot";
static NSString *kMainPot2              = @"mainPot2";
static NSString *kSidePot1              = @"sidePot1";
static NSString *kSidePot1Shifted       = @"sidePot1Shifted";
static NSString *kSidePot2              = @"sidePot2";
static NSString *kSidePot2Shifted       = @"sidePot2Shifted";
static NSString *kSidePot3              = @"sidePot3";


static NSString *kDictRect           = @"rect";
static NSString *kDictHash           = @"hash";
static NSString *kDictFound          = @"posFound";

#endif /* constants_h */
