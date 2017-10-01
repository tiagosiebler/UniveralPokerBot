//
//  ImageRecognition.h
//  CardRecognition
//
//  Created by Siebler, Tiago on 04/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayingCard.h"
#import "Enums.h"

/*
    Tasks of this class:
 - store reference to where all images are/will be stored
 - maintain NSSet indexes of all images
 - process NSSets as needed
 
 // make another class, designed to take an NSImage and process it through the NSSets and handle unknown images?
 // maybe side-by-side classes rather than parent-child classes
 */

@interface ImageIndex : NSObject

// path containing all images, known and unknown
@property (nonatomic, strong) NSString *rootImagesPath;

/*
        all known images and their subsets
 */
@property (nonatomic, strong) NSSet *allKnownImagesSet;//all hashes that are known and classified

@property (nonatomic, strong) NSSet *knownNoiseSet;//all hashes that are
@property (nonatomic, strong) NSSet *knownTableSet;
// used to identify that card the table, that tells us that that player has a hand
@property (nonatomic, strong) NSSet *knownPlayerHandsSet;//knownOtherPlayerCardsSet

// all known cards - read from where we expect to actually see cards (table and hand)
@property (nonatomic, strong) NSMutableSet *knownCardsSet;
@property (nonatomic, strong) NSArray *knownCardsArray;

// used to recognise and differentiate buttons on-screen
@property (nonatomic, strong) NSSet *knownButtonsSet;
@property (nonatomic, strong) NSArray *knownButtonsArray;

/*
        all unknown images
 */
@property (nonatomic, strong) NSSet *allUnknownImagesSet;


/* 
        all monitoring vars
 */
@property (nonatomic, assign) int knownImagesCount;
@property (nonatomic, assign) int unknownImagesCount;
@property (nonatomic, assign) float percentageKnown;

/*
        instance methods
 */

- (id)initWithRootPath:(NSString*)rootPath;// setup
- (void)reloadIndex;// parse path for all images, populating class sets

- (ImageType)getImageType:(NSString*)checksum; // used to recognise specific image using checksum

/*
        boolean methods
 */
- (BOOL)isKnownChecksum:(NSString*)checksum __attribute__((deprecated("use getImageType instead, this method is slower and 2 calls instead of 1")));
- (BOOL)isPlayerCard:(NSImage*)playerCard;
- (BOOL)playerHasAHand:(NSImage*)playerCard outInt:(int*)outInt;
/*
        retrieval methods
 */
// method to write card to PlayingCard without overwriting pointer
- (BOOL)recogniseImage:(NSImage*)image forCard:(PlayingCard**)card;
- (PlayingCard*)getCardWithImage:(NSImage*)image;
- (NSString*)getCardStringWithImage:(NSImage*)image;

- (PlayingCard*)getCardWithChecksum:(NSString*)checksum;
- (ImageType)getCardWithChecksum:(NSString*)checksum toSuit:(NSString**)theSuit toValue:(NSString**)theValue;
- (ImageType)getTypeWithImage:(NSImage*)image;

- (ButtonType)getButtonWithTypeImage:(NSImage*)image;
/*
        NSImage retrieval methods
 */

- (void)handleUnknownImage:(NSImage*)image ofType:(NSString*)type andHash:(int)hash;

// debugging
- (void)dbgOutputImageType:(ImageType)type;
- (void)dbgOutputButtonType:(ButtonType)type context:(NSString*)context;

@end
