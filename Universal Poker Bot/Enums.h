//
//  Enums.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 29/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#ifndef Enums_h
#define Enums_h

typedef NS_ENUM(NSUInteger, InternalEvents) {
    kNewGame,
};


typedef NS_ENUM(NSUInteger, ImageType) {
    kImageTypeNoise,
    kImageTypeTable,
    kImageTypePlayerHand,
    kImageTypeCard,
    kImageTypeButton,
    kImageTypeUnknown,
};

typedef NS_ENUM(NSUInteger, ButtonType){
    kButtonTypeAllIn,
    kButtonTypeCall,
    kButtonTypeRaise,
    kButtonTypeCheck,
    kButtonTypeFold,
    kButtonTypeNewTable,
    kButtonTypeStandUp,
    kButtonTypeInactive,
    kButtonTypeToLobby,
    kButtonTypeUnknown
};
typedef NS_ENUM(NSUInteger, NextAction) {
    kActionCheck,
    kActionFold,
    kActionCall,
    kActionRaise,
    kActionAllIn,
    kActionWait,
    kActionUnknown,
};


/*
typedef NS_ENUM(NSUInteger, ImageType) {
    kUnknown,
    kCard,
    kNoise,
    kTable,
};//*/
typedef NS_ENUM(NSUInteger, GameState) {
    kBlinds,
    kFlop,
    kTurn,
    kRiver,
};

typedef NS_ENUM(NSUInteger, HandStrength) {
    kHandHighCard = 3,
    kHandPair = 4,
    kHandTwoPair = 5,
    kHandThreeOfAKind = 6,
    kHandStraight = 7,
    kHandFlush = 8,
    kHandFullHouse = 9,
    kHandFourOfAKind = 10,
    kHandStraightFlush = 11,
    kHandRoyalFlush = 12,//unused
};

typedef NS_ENUM(NSUInteger, PlayerState) {
    kPlayerStateInLobby,
    kPlayerStateWaitingForSeat,
    kPlayerStateSeated,
    kPlayerStateWaitingForHand,
    kPlayerStateWaitingForTurn,
    kPlayerStateTurn,
    kPlayerStateUnknown
};


#endif /* Enums_h */
