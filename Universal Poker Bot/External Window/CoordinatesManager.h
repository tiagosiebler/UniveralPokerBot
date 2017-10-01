//
//  CoordinatesManager.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageSection.h"
#import "PokerTable.h"
#import "PokerChoice.h"

/*
 Create instance of this, setting the client-type (pokerstars, zynga, th, etc)
 - load tableMap
 - getter methods for coordinates (getCoords:player1, etc)
 
 */

@interface CoordinatesManager : NSObject
@property (strong) NSString *pathToTableMap;

- (void)loadTableMap:(NSString*)mapPath;
-(void)calibrateCoordinatesFromTableMap;



// at start of loop, store window in image
@property (nonatomic, strong) NSImage *windowImage;

// The pokerchip on the top left of the screen is a good reference point that we're on znyga's poker game. Everything else will be relative to this.
@property (nonatomic) NSRect chipLocation;
@property (nonatomic) int chipHash;
@property (nonatomic) int recognitionFailCount;
@property (strong) NSImage* chipImage;

@property (nonatomic) bool isCalibrated;


// buttons
@property (strong) ImageSection *buttonActionBottomLeft;
@property (strong) ImageSection *buttonActionBottomRight;
@property (strong) ImageSection *buttonActionTopLeft;
@property (strong) ImageSection *buttonActionTopRight;
@property (strong) ImageSection *buttonActionFoldActive;
@property (strong) ImageSection *buttonActionAllIn;
@property (strong) ImageSection *buttonActionPot;
@property (strong) ImageSection *buttonActionHalfPot;

@property (strong) ImageSection *raiseAmount;


@property (strong) ImageSection *buttonChatSend;
@property (strong) ImageSection *buttonNewTable;
@property (strong) ImageSection *buttonStandUp;
@property (strong) ImageSection *buttonToLobby;

@property (strong) ImageSection *dealerChip;

@property (strong) ImageSection *mainPot;
@property (strong) ImageSection *mainPot2;
@property (strong) ImageSection *sidePot1;
@property (strong) ImageSection *sidePot1Shifted;
@property (strong) ImageSection *sidePot2;
@property (strong) ImageSection *sidePot2Shifted;
@property (strong) ImageSection *sidePot3;

@property (strong) ImageSection *p1Bet;
@property (strong) ImageSection *p2Bet;
@property (strong) ImageSection *p3Bet;
@property (strong) ImageSection *p4Bet;
@property (strong) ImageSection *p5Bet;
@property (strong) ImageSection *p6Bet;
@property (strong) ImageSection *p7Bet;
@property (strong) ImageSection *p8Bet;
@property (strong) ImageSection *p9Bet;

@property (strong) ImageSection *p7TableChips;


// total money
//@property (nonatomic) NSRect money;
@property (strong) ImageSection* money;

/*
 players:
- each player should have 3 px vertically between name/last action and top of frame
- each player should have 3 px vertically between bottom of current chipcount comma and bottom of frame.
//*/
@property (nonatomic) NSRect p1TopLeftCorner;
@property (nonatomic) NSRect p2TopTopLeft;
@property (nonatomic) NSRect p3TopTopRight;
@property (nonatomic) NSRect p4TopRightCorner;
@property (nonatomic) NSRect p5BottomRightCorner;
@property (nonatomic) NSRect p6BottomRight;
@property (nonatomic) NSRect p7BottomMidSelf;
@property (nonatomic) NSRect p8BottomLeft;
@property (nonatomic) NSRect p9BottomLeftCorner;

// used to see if players are still playing
@property (nonatomic) NSRect playerCards1;
@property (nonatomic) NSRect playerCards2;
@property (nonatomic) NSRect playerCards3;
@property (nonatomic) NSRect playerCards4;
@property (nonatomic) NSRect playerCards5;
@property (nonatomic) NSRect playerCards6;
@property (nonatomic) NSRect playerCards7;
@property (nonatomic) NSRect playerCards8;
@property (nonatomic) NSRect playerCards9;

@property (nonatomic) NSRect myCard1;
@property (nonatomic) NSRect myCard2;

// cards on center of table
@property (nonatomic) NSRect tableCard1;
@property (nonatomic) NSRect tableCard2;
@property (nonatomic) NSRect tableCard3;
@property (nonatomic) NSRect tableCard4;
@property (nonatomic) NSRect tableCard5;

// main pot in play
@property (nonatomic) NSRect tablePotMain;
@property (strong) ImageSection* tableBlindsSize;

// NSImage retrieval methods
- (NSImage*)getChipImage;

- (NSImage*)getPlayerCard1Image;
- (NSImage*)getPlayerCard2Image;


- (int)getChipHash;

// NSRect retrieval methods, return NSRect from NSImage
- (BOOL)getChipLocationFromImage:(NSImage*)image error:(NSError**)error;
- (BOOL)getChipLocationWithError:(NSError**)error;
- (BOOL)hasChipMoved;
- (BOOL)haveChipLocation;

- (bool)getNewTablePlayButton:(NSRect*)resultRect;

- (BOOL)isOnTable;
- (BOOL)isSeated;
- (BOOL)isNewRound;
- (BOOL)isPlayerTurn;

- (PokerChoice *)getAvailableChoicesForTable:(PokerTable*)table;

// class methods
+ (NSRect)adjustCoordsForRect:(NSRect)src relativeToRect:(NSRect)reference;
+ (NSRect)getAdjustedRectForKey:(NSString*)key fromDict:(NSDictionary*)dict relativeToRect:(NSRect)reference;
+ (NSRect)getRectForKey:(NSString*)key fromDict:(NSDictionary*)dict;
+ (float)getValue:(NSString*)value fromDict:(NSDictionary*)dict forKey:(NSString*)key forType:(NSString*)type;

@end


