//
//  POdds.h
//  podds
//
//  Created by Siebler, Tiago on 29/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POdds : NSObject
+ (int)intForCard:(NSString*)card;
+ (NSDictionary*)simulateCards:(NSString*)cards;
+ (float)simulateCards:(NSString*)card1 card2:(NSString*)card2 card3:(NSString*)card3 card4:(NSString*)card4 card5:(NSString*)card5 card6:(NSString*)card6 card7:(NSString*)card7 players:(int)_players;
+ (float)simulateCards:(char*[])cards count:(int)_numberOfCards players:(int)_players;//newer method

// checks what top match player currently has with cards on table
+ (void)outputHand:(int)hand;
+ (NSString*)getMatchString:(int)hand;
+ (int)getTopMatchForTable:(NSString*)cards;
+ (int)getTopMatchForCards:(NSString*)cards;
+ (int)getTopMatchForCards:(NSString*)card1 card2:(NSString*)card2 card3:(NSString*)card3 card4:(NSString*)card4 card5:(NSString*)card5 card6:(NSString*)card6 card7:(NSString*)card7;
+ (void)testHandRecog;
@end
