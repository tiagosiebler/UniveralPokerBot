//
//  PokerLogger.m
//  CSVLogger
//
//  Created by Siebler, Tiago on 18/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "PokerLogger.h"
#import "CHCSVParser.h"

@implementation PokerLogger{
    CHCSVWriter *writer;
    int roundNumber;
}
static NSString *kDefaultCSVPath = @"/Users/tsiebler/Desktop/pkr/log.csv";

- (id)init{
    return [self initWithPath:kDefaultCSVPath];
}
- (id)initWithPath:(NSString*)path{
    self = [super init];
    if (self) {
        NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
        writer = [[CHCSVWriter alloc] initWithOutputStream:stream encoding:NSUTF8StringEncoding delimiter:','];
        roundNumber = 0;
        
        self.chipsTotal             = 0;
        self.chipsTotalTable        = 0;
        self.chipsDifferenceTotal   = 0;
        self.winningOdds            = 0;
        self.aggressionFactor       = 0;//not used right now
        
        self.playerCountStart       = 0;
        self.playerCountEnd         = 0;
        
        self.pocketCards            = nil;
        self.pocketCardsSuited      = 0;
        
        self.playerAction           = nil;
        self.playerActionAmount     = 0;//more for calls and raises, maybe useful for all-in too.
        
        self.gameState              = nil;
        self.finalHand              = nil;
        
        self.communityCard1         = nil;
        self.communityCard2         = nil;
        self.communityCard3         = nil;
        self.communityCard4         = nil;
        self.communityCard5         = nil;
        
        NSString *dateTime = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                            dateStyle:NSDateFormatterShortStyle
                                                            timeStyle:NSDateFormatterShortStyle];
        dateTime = [dateTime stringByReplacingOccurrencesOfString:@"," withString:@""];
        self.sessionDt = dateTime;
        
        [writer writeComment:@"New Session Start - App Reopened"];
        /*
        [writer writeLineOfFields:@[
                                    @"roundNumber",
                                    @"dateTime",
                                    @"bigBlind",
                                    @"chipsTotal",
                                    @"chipsTotalTable",
                                    @"chipsDifferenceTotal",
                                    @"winningOdds",
                                    @"aggressionFactor",
                                    
                                    
                                    @"playerCountStart",
                                    @"playerCountEnd",
                                    
                                    @"pocketCards",
                                    @"PocketCardsSuited",
                                    
                                    @"playerAction",
                                    @"playerActionAMount",
                                    
                                    @"gameState",
                                    @"finalHand",
                                    
                                    
                                    ]];//*/
        
    }
    return self;
}
- (void)write{
    // column 1
    NSString *dateTime = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                        dateStyle:NSDateFormatterShortStyle
                                                        timeStyle:NSDateFormatterShortStyle];
    NSArray *dateTimeArray = [dateTime componentsSeparatedByString:@","];
//    NSLog(@"%@",dateTime);
    
    NSLog(@"self.chipsDifferenceTotal: %lld", self.chipsDifferenceTotal);
    
    if(self.playerAction == nil || self.gameState == nil){
        NSLog(@"====== error: playerAction (%@) or gameState (%@) == nil",self.playerAction, self.gameState);
        return;
    }
    /*else if([self.gameState isEqualToString:@"kBlinds"]){
        self.communityCard1 = nil;
        self.communityCard2 = nil;
        self.communityCard3 = nil;
        self.communityCard4 = nil;
        self.communityCard5 = nil;
    }else if([self.gameState isEqualToString:@"kFlop"]){
        self.communityCard4 = nil;
        self.communityCard5 = nil;
    }else if([self.gameState isEqualToString:@"kTurn"]){
        self.communityCard5 = nil;
    }//*/
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);

    
    [writer writeLineOfFields:@[
                                [NSString stringWithFormat:@"%lld",milliseconds],
                                [NSString stringWithFormat:@"%@",self.sessionDt],
                                [dateTimeArray objectAtIndex:0],
                                [[dateTimeArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@""],
                                [NSString stringWithFormat:@"%lld",self.bigBlind],
                                [NSString stringWithFormat:@"%lld",self.chipsTotal],
                                [NSString stringWithFormat:@"%lld",self.chipsTotalTable],
                                [NSString stringWithFormat:@"%lld",self.chipsDifferenceTotal],
                                [NSString stringWithFormat:@"%f",self.winningOdds],
                                [NSString stringWithFormat:@"%f",self.aggressionFactor],

                                
                                [NSString stringWithFormat:@"%d",self.playerCountStart],
                                [NSString stringWithFormat:@"%d",self.playerCountEnd],

                                [NSString stringWithFormat:@"%@",self.pocketCards],
                                [NSString stringWithFormat:@"%d",self.pocketCardsSuited],

                                [NSString stringWithFormat:@"%@",self.playerAction],
                                [NSString stringWithFormat:@"%lld",self.playerActionAmount],
                                
                                [NSString stringWithFormat:@"%@",self.gameState],
                                [NSString stringWithFormat:@"%@",self.finalHand],
                                
                                [NSString stringWithFormat:@"%@",self.communityCard1],
                                [NSString stringWithFormat:@"%@",self.communityCard2],
                                [NSString stringWithFormat:@"%@",self.communityCard3],
                                [NSString stringWithFormat:@"%@",self.communityCard4],
                                [NSString stringWithFormat:@"%@",self.communityCard5],
                                
                                [NSString stringWithFormat:@"%d",self.didWin],
                                
                                [NSString stringWithFormat:@"%s","writeCall"],

                                ]];
    
 
    [self newRound];
}
- (void)write:(NSString*)location{
    // column 1
    NSString *dateTime = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                        dateStyle:NSDateFormatterShortStyle
                                                        timeStyle:NSDateFormatterShortStyle];
    NSArray *dateTimeArray = [dateTime componentsSeparatedByString:@","];
    //    NSLog(@"%@",dateTime);
    
    NSLog(@"self.chipsDifferenceTotal: %lld", self.chipsDifferenceTotal);
    
    if(self.playerAction == nil || self.gameState == nil){
        NSLog(@"====== error: playerAction (%@) or gameState (%@) == nil",self.playerAction, self.gameState);
        return;
    }
    /*else if([self.gameState isEqualToString:@"kBlinds"]){
     self.communityCard1 = nil;
     self.communityCard2 = nil;
     self.communityCard3 = nil;
     self.communityCard4 = nil;
     self.communityCard5 = nil;
     }else if([self.gameState isEqualToString:@"kFlop"]){
     self.communityCard4 = nil;
     self.communityCard5 = nil;
     }else if([self.gameState isEqualToString:@"kTurn"]){
     self.communityCard5 = nil;
     }//*/
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    
    
    [writer writeLineOfFields:@[
                                [NSString stringWithFormat:@"%lld",milliseconds],
                                [NSString stringWithFormat:@"%@",self.sessionDt],
                                [dateTimeArray objectAtIndex:0],
                                [[dateTimeArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@""],
                                [NSString stringWithFormat:@"%lld",self.bigBlind],
                                [NSString stringWithFormat:@"%lld",self.chipsTotal],
                                [NSString stringWithFormat:@"%lld",self.chipsTotalTable],
                                [NSString stringWithFormat:@"%lld",self.chipsDifferenceTotal],
                                [NSString stringWithFormat:@"%f",self.winningOdds],
                                [NSString stringWithFormat:@"%f",self.aggressionFactor],
                                
                                
                                [NSString stringWithFormat:@"%d",self.playerCountStart],
                                [NSString stringWithFormat:@"%d",self.playerCountEnd],
                                
                                [NSString stringWithFormat:@"%@",self.pocketCards],
                                [NSString stringWithFormat:@"%d",self.pocketCardsSuited],
                                
                                [NSString stringWithFormat:@"%@",self.playerAction],
                                [NSString stringWithFormat:@"%lld",self.playerActionAmount],
                                
                                [NSString stringWithFormat:@"%@",self.gameState],
                                [NSString stringWithFormat:@"%@",self.finalHand],
                                
                                [NSString stringWithFormat:@"%@",self.communityCard1],
                                [NSString stringWithFormat:@"%@",self.communityCard2],
                                [NSString stringWithFormat:@"%@",self.communityCard3],
                                [NSString stringWithFormat:@"%@",self.communityCard4],
                                [NSString stringWithFormat:@"%@",self.communityCard5],
                                
                                [NSString stringWithFormat:@"%@",location],
                                
                                ]];
    
    
    [self newRound];
}
- (void)clearForGameState:(GameState)state{
    switch (state) {
        case kBlinds:
            self.communityCard1         = nil;
            self.communityCard2         = nil;
            self.communityCard3         = nil;
            self.communityCard4         = nil;
            self.communityCard5         = nil;
            break;
            
        case kFlop:
            self.communityCard4         = nil;
            self.communityCard5         = nil;
            break;
            
        case kRiver:
            self.communityCard5         = nil;
            break;
            
        default:
            break;
    }
}
- (void)newRound{
    roundNumber++;
    
    self.chipsTotalTable        = 0;
    self.chipsDifferenceTotal   = 0;
    self.winningOdds            = 0;
    self.aggressionFactor       = 0;//not used right now
    
    self.playerCountStart       = 0;
    self.playerCountEnd         = 0;
    
    self.pocketCards            = nil;
    self.pocketCardsSuited      = 0;
    
    self.playerAction           = nil;
    self.playerActionAmount     = 0;//more for calls and raises
    
    self.gameState              = nil;
    self.finalHand              = nil;

    self.communityCard1         = nil;
    self.communityCard2         = nil;
    self.communityCard3         = nil;
    self.communityCard4         = nil;
    self.communityCard5         = nil;
    
}
@end
