//
//  PlayingCard.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 02/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (id)init
{
    if (self == [super init]) {
        self.stringValue = nil;
        self.dbgValue    = nil;
        
        self.intValue = 0;
        
        self.isRecognizedAsCard = false;
        self.isRecognizedAsTable = false;
    }
    return self;
}
- (void)setStringValue:(NSString *)stringValue{
    if(![_stringValue isEqualToString:stringValue]) _stringValue = stringValue;
}

- (void)clear{
    self.stringValue = nil;
    self.dbgValue = nil;
    
    self.intValue = 0;
    
    self.isRecognizedAsCard = false;
    self.isRecognizedAsTable = false;
}

// setters
- (void)setWithString:(NSString *)string{
    // only do this if it's a valid card, not some plain value
    if([self isPlayingCard:string]){
        self.stringValue = string;
        self.dbgValue = kCardTypeCard;
        NSLog(@"### setting card value to: %@",string);
    }else{
        [self clear];
        self.dbgValue = string;
        //NSLog(@"### not setting card value isPlayingCard/false: %@",string);
    }
}
- (void)setWithSuit:(NSString*)cardSuit andValue:(NSString*)cardValue{
    NSString *combinedCard = [cardValue stringByAppendingString:cardSuit];
    [self setWithString:combinedCard];
}
- (void)setWithInteger:(NSInteger *)integerValue{
    
}
- (void)setWithInt:(int)intValue{
    
}


// private helper methods
- (NSString*)suitString{
    if(self.stringValue == nil) return nil;
    
    //2nd character is suit
    NSString *theCharacter = [NSString stringWithFormat:@"%c", [self.stringValue characterAtIndex:1]];
    return theCharacter;
}
- (NSString*)valueString{
    if(self.stringValue == nil) return nil;
    
    // first character is value
    NSString *theCharacter = [NSString stringWithFormat:@"%c", [self.stringValue characterAtIndex:0]];
    return theCharacter;
}
- (BOOL)isPlayingCard:(NSString*)card{
    //NSLog(@"isPlayingCard: %@",card);
    
    BOOL retVal = true;
    self.isRecognizedAsTable = false;
    
    //[card isEqualToString:kCardTypeTable] ||
    if(card == nil || [card isEqual:[NSNull null]]){
        retVal = false;
    }else if([card isEqualToString:kCardTypeNoise] || [card isEqualToString:kCardTypeUnknown]){
        retVal = false;
    }else if([card isEqualToString:kCardTypeTable]){
        self.isRecognizedAsTable = true;
        retVal = false;
    }else{
        //unhandled
    }
    return self.isRecognizedAsCard = retVal;
}

@end
