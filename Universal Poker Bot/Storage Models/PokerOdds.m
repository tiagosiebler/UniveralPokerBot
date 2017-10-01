//
//  PokerOdds.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 14/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "PokerOdds.h"

@implementation PokerOdds

- (void)loadOddsDictionary:(NSDictionary*)dictionary{
    self.win            = [dictionary[@"win"] floatValue];
    self.draw           = [dictionary[@"draw"] floatValue];

    self.pair           = [dictionary[@"pair"] floatValue];
    self.twoPair        = [dictionary[@"twoPair"] floatValue];
    self.threeOfAKind   = [dictionary[@"threeOfAKind"] floatValue];
    self.straight       = [dictionary[@"straight"] floatValue];
    self.flush          = [dictionary[@"flush"] floatValue];
    self.fullHouse      = [dictionary[@"fullHouse"] floatValue];
    self.fourOfAKind    = [dictionary[@"fourOfAKind"] floatValue];
    self.straightFlush  = [dictionary[@"straightFlush"] floatValue];
    
    self.dictionary = dictionary;

    //NSLog(@"loadOddsDictionary: %@ %0.2f",dictionary[@"win"], [dictionary[@"win"] floatValue]);
}

// maybe this can maintain the odds calculation?
- (void)calculateWithCards:(NSString*)cards andPlayers:(int)players{
    
}
- (void)clear{
    self.win = 0.0f;
    self.draw = 0.0f;
    self.pair = 0.0f;
    self.twoPair = 0.0f;
    self.threeOfAKind = 0.0f;
    self.straight = 0.0f;
    self.flush = 0.0f;
    self.fullHouse = 0.0f;
    self.fourOfAKind = 0.0f;
    self.straightFlush = 0.0f;
}
@end
