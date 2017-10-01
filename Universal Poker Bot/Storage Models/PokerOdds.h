//
//  PokerOdds.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 14/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerOdds : NSObject

@property (strong) NSDictionary* dictionary;

@property (nonatomic) float win;
@property (nonatomic) float draw;

@property (nonatomic) float pair;
@property (nonatomic) float twoPair;
@property (nonatomic) float threeOfAKind;
@property (nonatomic) float straight;
@property (nonatomic) float flush;
@property (nonatomic) float fullHouse;
@property (nonatomic) float fourOfAKind;
@property (nonatomic) float straightFlush;

// load dictionary containing this kind of information
//{"cores":8,"games":200000,"win":0.161,"draw":0.025,"pair":0.518,"two-pairs":0.374,"three-of-a-kind":0.067,"straight":0.015,"flush":0.000,"full-house":0.025,"four-of-a-kind":0.001,"straight-flush":0.000}
- (void)loadOddsDictionary:(NSDictionary*)dictionary;
- (void)clear;
@end
