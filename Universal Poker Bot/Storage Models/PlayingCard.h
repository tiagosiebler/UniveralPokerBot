//
//  PlayingCard.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 02/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface PlayingCard : NSObject
@property (nonatomic, strong) NSString* stringValue;//e.g. As (value then suit). nil if not a valid card
@property (nonatomic, strong) NSString* dbgValue;//e.g. As (value then suit) or table or noise etc nil if not a card

//int representation 0-13 for first suit, etc. 0 if not a card
@property (nonatomic, assign) NSInteger* integerValue;
@property (nonatomic, assign) int intValue;

@property (nonatomic, assign) BOOL isRecognizedAsCard;
@property (nonatomic, assign) BOOL isRecognizedAsTable;

- (void)clear;

- (void)setWithString:(NSString *)string;
- (void)setWithSuit:(NSString*)cardSuit andValue:(NSString*)cardValue;
- (void)setWithInteger:(NSInteger *)integerValue;
- (void)setWithInt:(int)intValue;

// getters
- (NSString*)suitString;
- (NSString*)valueString;

@end
