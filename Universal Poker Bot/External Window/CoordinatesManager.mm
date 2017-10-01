//
//  CoordinatesManager.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "CoordinatesManager.h"
#import "CVHelper.hpp"
#import "CVSearchHelper.hpp"
#import "NSData+Adler32.h"
#import "NSImage+subImage.h"
#import "constants.h"
#import "PokerTable.h"
#import "NSString+cleaning.h"

@implementation CoordinatesManager

- (id)init{
    if (self = [super init]) {
        // initialization here
        NSLog(@"coordinateManagerInit");
        self.chipImage = [CVHelper NSImageFromBundle:kImageChip];
        
        self.buttonActionBottomLeft     = [[ImageSection alloc] init];
        self.buttonActionBottomRight    = [[ImageSection alloc] init];
        self.buttonActionTopLeft        = [[ImageSection alloc] init];
        self.buttonActionTopRight       = [[ImageSection alloc] init];
        self.buttonNewTable             = [[ImageSection alloc] init];
        self.buttonStandUp              = [[ImageSection alloc] init];
        self.buttonToLobby              = [[ImageSection alloc] init];
        self.dealerChip                 = [[ImageSection alloc] init];
        self.buttonActionFoldActive     = [[ImageSection alloc] init];
        
        self.buttonActionHalfPot        = [[ImageSection alloc] init];
        self.buttonActionPot            = [[ImageSection alloc] init];
        self.buttonActionAllIn          = [[ImageSection alloc] init];
        
        // amount that I'll raise if I click the raise button
        self.raiseAmount                = [[ImageSection alloc] init];
        
        self.money                      = [[ImageSection alloc] init];
        self.tableBlindsSize            = [[ImageSection alloc] init];

        self.mainPot                    = [[ImageSection alloc] init];
        self.mainPot2                   = [[ImageSection alloc] init];
        self.sidePot1                   = [[ImageSection alloc] init];
        self.sidePot1Shifted            = [[ImageSection alloc] init];
        self.sidePot2                   = [[ImageSection alloc] init];
        self.sidePot2Shifted            = [[ImageSection alloc] init];
        self.sidePot3                   = [[ImageSection alloc] init];
        
        self.p1Bet                      = [[ImageSection alloc] init];
        self.p2Bet                      = [[ImageSection alloc] init];
        self.p3Bet                      = [[ImageSection alloc] init];
        self.p4Bet                      = [[ImageSection alloc] init];
        self.p5Bet                      = [[ImageSection alloc] init];
        self.p6Bet                      = [[ImageSection alloc] init];
        self.p7Bet                      = [[ImageSection alloc] init];
        self.p8Bet                      = [[ImageSection alloc] init];
        self.p9Bet                      = [[ImageSection alloc] init];
        
        self.p7TableChips               = [[ImageSection alloc] init];

        self.dealerChip.image           = [CVHelper NSImageFromBundle:kImageDealerChip];
        self.recognitionFailCount       = 0;
        self.isCalibrated               = false;
    }
    return self;
}
- (void)loadTableMap:(NSString*)mapPath{
    // read everything from text
    NSString* fileContents =
    [NSString stringWithContentsOfFile:mapPath
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    NSLog(@"printing filtered strings");

    //NSLog(@"opened map: %@",allLinedStrings);
    for (NSString* line in allLinedStrings) {
        if([line length] != 0 && ![line hasPrefix:@"//"] && [line containsString:@"$"]){
            //NSArray *strings = [line componentsSeparatedByString:@"\t"];
            //strings = [[strings objectAtIndex:0] componentsSeparatedByString:@" "];
            //NSLog(@"line: %@",[strings objectAtIndex:0]);
            //printf("%s\n",[[strings objectAtIndex:0] UTF8String]);
            
            if([line hasPrefix:@"z"]){
                //sizes
                
            }else if([line hasPrefix:@"s"]){
                //strings
                
            }else if([line hasPrefix:@"r"]){
                //strings
                
            }else if([line hasPrefix:@"h"]){
                //hashes
                
            }else if([line hasPrefix:@"i"]){
                //images
                
            }
        }
    }
}
- (NSMutableDictionary*)getTemplateDictionaryWithRect:(NSRect)rect{
    NSString *rectStr = NSStringFromRect(rect);
    NSMutableDictionary *templateDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                               rectStr, kDictRect,
                                               5, kDictHash,
                                               true, kDictFound,
                                               nil];
                                               
    return templateDictionary;
}
- (NSRect)rectFromDictionary:(NSDictionary*)dictionary{
    return NSRectFromString(dictionary[kDictRect]);
}

-(void)calibrateCoordinatesFromTableMap{
    NSMutableDictionary *relativeCoords = [[NSMutableDictionary alloc] initWithContentsOfFile:self.pathToTableMap];
    //NSLog(@"relative coords: %@",relativeCoords);
    
    [self.buttonActionBottomLeft    updateRect:[self getRelativeRectForKey:kImageButtonBottomLeft       fromDict:relativeCoords]];
    [self.buttonActionBottomRight   updateRect:[self getRelativeRectForKey:kImageButtonBottomRight      fromDict:relativeCoords]];
    [self.buttonActionTopLeft       updateRect:[self getRelativeRectForKey:kImageButtonTopLeft          fromDict:relativeCoords]];
    [self.buttonActionTopRight      updateRect:[self getRelativeRectForKey:kImageButtonTopRight         fromDict:relativeCoords]];
    [self.buttonActionHalfPot       updateRect:[self getRelativeRectForKey:kImageButtonHalfPot          fromDict:relativeCoords]];
    [self.buttonActionPot           updateRect:[self getRelativeRectForKey:kImageButtonPot              fromDict:relativeCoords]];
    [self.buttonActionAllIn         updateRect:[self getRelativeRectForKey:kImageButtonAllIn            fromDict:relativeCoords]];
    
    [self.buttonChatSend            updateRect:[self getRelativeRectForKey:kImageButtonChatSend         fromDict:relativeCoords]];
    [self.buttonNewTable            updateRect:[self getRelativeRectForKey:kImageButtonNewTable         fromDict:relativeCoords]];
    [self.buttonStandUp             updateRect:[self getRelativeRectForKey:kImageButtonStandUp          fromDict:relativeCoords]];
    [self.buttonToLobby             updateRect:[self getRelativeRectForKey:kImageButtonToLobby          fromDict:relativeCoords]];
    
    [self.raiseAmount               updateRect:[self getRelativeRectForKey:kImageRaiseAmount            fromDict:relativeCoords]];

    [self.money                     updateRect:[self getRelativeRectForKey:kImageMoney                  fromDict:relativeCoords]];
    [self.tableBlindsSize           updateRect:[self getRelativeRectForKey:kImageBlinds                 fromDict:relativeCoords]];

    [self.p1Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet1                 fromDict:relativeCoords]];
    [self.p2Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet2                 fromDict:relativeCoords]];
    [self.p3Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet3                 fromDict:relativeCoords]];
    [self.p4Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet4                 fromDict:relativeCoords]];
    [self.p5Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet5                 fromDict:relativeCoords]];
    [self.p6Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet6                 fromDict:relativeCoords]];
    [self.p7Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet7                 fromDict:relativeCoords]];
    [self.p8Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet8                 fromDict:relativeCoords]];
    [self.p9Bet                     updateRect:[self getRelativeRectForKey:kPlayerBet9                 fromDict:relativeCoords]];
    
    [self.mainPot                   updateRect:[self getRelativeRectForKey:kMainPot                     fromDict:relativeCoords]];
    [self.mainPot2                  updateRect:[self getRelativeRectForKey:kMainPot2                    fromDict:relativeCoords]];
    [self.sidePot1                  updateRect:[self getRelativeRectForKey:kSidePot1                    fromDict:relativeCoords]];
    [self.sidePot1Shifted           updateRect:[self getRelativeRectForKey:kSidePot1Shifted             fromDict:relativeCoords]];
    [self.sidePot2                  updateRect:[self getRelativeRectForKey:kSidePot2                    fromDict:relativeCoords]];
    [self.sidePot2Shifted           updateRect:[self getRelativeRectForKey:kSidePot2Shifted             fromDict:relativeCoords]];
    [self.sidePot3                  updateRect:[self getRelativeRectForKey:kSidePot3                    fromDict:relativeCoords]];
    
    [self.p7TableChips              updateRect:[self getRelativeRectForKey:kPlayerTableChips7           fromDict:relativeCoords]];

    self.p1TopLeftCorner            = [self getRelativeRectForKey:@"p1TopLeftCorner"            fromDict:relativeCoords];
    self.p2TopTopLeft               = [self getRelativeRectForKey:@"p2TopTopLeft"               fromDict:relativeCoords];
    self.p3TopTopRight              = [self getRelativeRectForKey:@"p3TopTopRight"              fromDict:relativeCoords];
    self.p4TopRightCorner           = [self getRelativeRectForKey:@"p4TopRightCorner"           fromDict:relativeCoords];
    self.p5BottomRightCorner        = [self getRelativeRectForKey:@"p5BottomRightCorner"        fromDict:relativeCoords];
    self.p6BottomRight              = [self getRelativeRectForKey:@"p6BottomRight"              fromDict:relativeCoords];
    self.p7BottomMidSelf            = [self getRelativeRectForKey:@"p7BottomMidSelf"            fromDict:relativeCoords];
    self.p8BottomLeft               = [self getRelativeRectForKey:@"p8BottomLeft"               fromDict:relativeCoords];
    self.p9BottomLeftCorner         = [self getRelativeRectForKey:@"p9BottomLeftCorner"         fromDict:relativeCoords];
    
    self.tableCard1                 = [self getRelativeRectForKey:@"tableCard1"                 fromDict:relativeCoords];
    self.tableCard2                 = [self getRelativeRectForKey:@"tableCard2"                 fromDict:relativeCoords];
    self.tableCard3                 = [self getRelativeRectForKey:@"tableCard3"                 fromDict:relativeCoords];
    self.tableCard4                 = [self getRelativeRectForKey:@"tableCard4"                 fromDict:relativeCoords];
    self.tableCard5                 = [self getRelativeRectForKey:@"tableCard5"                 fromDict:relativeCoords];
    
    self.myCard1                    = [self getRelativeRectForKey:@"myCard1"                    fromDict:relativeCoords];
    self.myCard2                    = [self getRelativeRectForKey:@"myCard2"                    fromDict:relativeCoords];
    
    self.playerCards1               = [self getRelativeRectForKey:@"playerCards1"               fromDict:relativeCoords];
    self.playerCards2               = [self getRelativeRectForKey:@"playerCards2"               fromDict:relativeCoords];
    self.playerCards3               = [self getRelativeRectForKey:@"playerCards3"               fromDict:relativeCoords];
    self.playerCards4               = [self getRelativeRectForKey:@"playerCards4"               fromDict:relativeCoords];
    self.playerCards5               = [self getRelativeRectForKey:@"playerCards5"               fromDict:relativeCoords];
    self.playerCards6               = [self getRelativeRectForKey:@"playerCards6"               fromDict:relativeCoords];
    self.playerCards7               = [self getRelativeRectForKey:@"playerCards7"               fromDict:relativeCoords];
    self.playerCards8               = [self getRelativeRectForKey:@"playerCards8"               fromDict:relativeCoords];
    self.playerCards9               = [self getRelativeRectForKey:@"playerCards9"               fromDict:relativeCoords];
    
    //self.tableBlindsSize            = [self getRelativeRectForKey:@"tableBlindsSize"            fromDict:relativeCoords];
    self.tablePotMain               = [self getRelativeRectForKey:@"tablePotMain"               fromDict:relativeCoords];
    
    NSLog(@"finished loading coordinates relative to chip");
    self.isCalibrated               = true;

}

- (NSRect)getRelativeRectForKey:(NSString*)key fromDict:(NSDictionary*)dict{
    NSRect rect = [CoordinatesManager getRectForKey:key fromDict:dict];
    rect.origin = [CVHelper addPoint:self.chipLocation.origin toPoint:rect.origin];
    return rect;
}




















- (NSImage*)getChipImage{
    if (![self haveChipLocation]) return nil;
    return [self.windowImage getSubImageWithRect:self.chipLocation];
}
- (NSImage*)getPlayerCard1Image{return [self.windowImage getBWSubImageWithRect:self.myCard1]; }
- (NSImage*)getPlayerCard2Image{return [self.windowImage getBWSubImageWithRect:self.myCard2]; }

// get chip from current screenshot, via last known location, and store/return a hash
- (int)getChipHash{
    if (![self haveChipLocation]) return false;
    return self.chipHash = [[self getChipImage] getHash];
}
// NSRect retrieval methods, return NSRect from NSImage
// get location of poker chip from image/screenshot, and store coordinate.
- (BOOL)getChipLocationFromImage:(NSImage*)image error:(NSError**)error{
    NSRect chipLoc;
    //NSError *error;
    BOOL success = [CVSearchHelper isImage:self.chipImage withinImage:image retLocation:&chipLoc error:error];
    
    if(success){
        NSLog(@"getChipLocationFromImage - loc: %@",NSStringFromRect(chipLoc));
        self.chipLocation = chipLoc;
        
        [self getChipHash];
        [self calibrateCoordinatesFromTableMap];
        
    }else{
        self.chipLocation = NSMakeRect(0, 0, 0, 0);
        NSLog(@"failed to get chip loc, error: %@",*error);
    }
    return success;
}

- (BOOL)getChipLocationWithError:(NSError**)error{
    return [self getChipLocationFromImage:self.windowImage error:error];
}
- (BOOL)haveChipLocation{
    return self.chipLocation.origin.x != 0;
}
- (BOOL)hasChipMoved{
    int chipHash = [[self getChipImage] getHash];
    
    return chipHash != self.chipHash;
}

- (bool)getNewTablePlayButton:(NSRect*)resultRect{
    BOOL result = false;

    NSImage *newTablePlayImage = [CVHelper NSImageFromBundle:kImageNewTablePlay];
    NSError *error;
    result = [CVSearchHelper isImage:newTablePlayImage withinImage:self.windowImage retLocation:resultRect error:&error];
    
    return result;
}


- (ButtonType)getTopLeft{
    [self.buttonActionTopLeft getImageFromScreenshot:self.windowImage];
    return [self.buttonActionTopLeft getButton];
}
- (ButtonType)getTopRight{
    [self.buttonActionTopRight getImageFromScreenshot:self.windowImage];
    return [self.buttonActionTopRight getButton];
}
- (ButtonType)getBottomLeft{
    [self.buttonActionBottomLeft getImageFromScreenshot:self.windowImage];
    return [self.buttonActionBottomLeft getButton];
}

- (BOOL)isOnTable{
    
    [self.buttonNewTable getImageFromScreenshot:self.windowImage];
    ButtonType type = [self.buttonNewTable getButton];

    if(type == kButtonTypeNewTable) return true;
    return false;
}
- (BOOL)isSeated{
    [self.buttonStandUp getImageFromScreenshot:self.windowImage];
    ButtonType type = [self.buttonStandUp getButton];
    
    if(type == kButtonTypeStandUp) return true;
    return false;
}
- (BOOL)isNewRound{
    return [self hasSectionMoved:self.dealerChip];
}

- (BOOL)isPlayerTurn{
    if([self getTopRight] == kButtonTypeFold) return true;
    return false;
}

- (unsigned long long)getCallAmount{
    //NSLog(@"reading call button");//CALL $292.00K
    NSString *string = [[PokerTable tessAPI] getStringFromImage:self.buttonActionTopLeft.image];
    
    NSLog(@"######## call button text: %@ - extracted: %@",string, [string extractValue]);
    
    unsigned long long callValue = [[string extractValue] ULongLong];
    
    NSLog(@"######## call button value: %llu",callValue);
    
    // read call button for how much the call is
    return callValue;
}
- (PokerChoice *)getAvailableChoicesForTable:(PokerTable*)table{
    NSLog(@"######## getAvailableChoices");
    NSLog(@"######### getAvailableChoices:totalBets: %llu", table.totalBets);
    NSLog(@"######### getAvailableChoices:totalPots: %llu", table.totalPots);
    // read all buttons currently available to user
    
    ButtonType topLeft = [self getTopLeft];
    //ButtonType topRight = [self getTopRight];
    ButtonType raise = [self getBottomLeft];

    //[PokerTable.IMIndex dbgOutputButtonType:topLeft context:@"topLeft"];
    //[PokerTable.IMIndex dbgOutputButtonType:topRight context:@"topRight"];
    //[PokerTable.IMIndex dbgOutputButtonType:raise context:@"bottomLeft"];
    
    BOOL canCheck = topLeft == kButtonTypeCheck;
    BOOL needToCall = topLeft == kButtonTypeCall;
    BOOL canRaise = raise == kButtonTypeRaise;
    
    NSLog(@"######## canCheck: %hhd",canCheck);
    NSLog(@"######## canRaise: %hhd",canRaise);

    long long callAmount = 0;
    long long raiseAmount = 0;
    if(needToCall){
        callAmount = [self getCallAmount];
    }
    if(canRaise){
        raiseAmount = [self getCurrentRaiseAmount];
    }
    NSLog(@"######## needToCall: %hhd (%lld)",needToCall, callAmount);


    PokerChoice *decision = [[PokerChoice alloc] init];
    decision.gameState = table.gameState;
    decision.winningOdds = table.myPlayer.odds.win;
    
    decision.canCheck = topLeft == kButtonTypeCheck;
    decision.canRaise = raise == kButtonTypeRaise;
    decision.isCallRequired = topLeft == kButtonTypeCall;
    
    decision.callAmount = callAmount;
    decision.raiseAmount = raiseAmount;
    decision.bigBlindSize = table.blindBig;
    decision.playerCount = table.numberPlayersWithCards;
    decision.totalPot = table.totalPots;
    decision.totalBets = table.totalBets;
    decision.handStrength = table.myPlayer.handStrength;
    decision.pokerTable = table;// maybe a bad design...it'll do for now just to get it running
    
    //[decision makeDecision];
    
    // we're not really handling decisions here, clicking is handled by the parent.
    //[self triggerAction:decision.nextAction decision:decision];
    
    return decision;
}
- (long long)getCurrentRaiseAmount{
    NSImage *raiseField = [self.raiseAmount getImageFromScreenshot:self.windowImage];
    NSString *raiseAmountStr = [[PokerTable tessAPI] getStringFromImage:raiseField];
    long long result = [[raiseAmountStr extractValue] ULongLong];
    
    NSLog(@"raiseAmount: %llu", result);

    return result;
}

- (void)triggerAction:(NextAction)nextAction decision:(PokerChoice*)decision{
    NSString *action = nil;
    switch(nextAction){
        case kActionCheck:
            action = @"check";
            break;
            
        case kActionCall:
            action = @"call";
            break;
            
        case kActionAllIn:
            action = @"allIn";
            break;
            
        case kActionFold:
            action = @"fold";
            break;
            
        case kActionRaise:
            action = [@"raise " stringByAppendingString:[NSString stringWithFormat:@"%llu", decision.raiseAmount]];
            break;
            
        case kActionWait:
            NSLog(@"waiting, possible read error");
            break;
            
        case kActionUnknown:
            NSLog(@"warning, unhandled action!!");
            break;
    }
    
    NSLog(@"triggering action: %@",action);
}

//#error this isn't accruate enough
- (BOOL)isImageSectionVisible:(ImageSection*)section{
    BOOL result = false;
    if(section.imageHash == 0 || self.recognitionFailCount > 2){
        //NSLog(@"searching for table button with CV");
        NSError *error;
        NSRect resultRect;
        result = [CVSearchHelper isImage:section.image
                             withinImage:self.windowImage
                             retLocation:&resultRect
                                   error:&error];
        if(!result){
            //NSLog(@"couldn't find new table button: %@",error);
            self.recognitionFailCount++;// if this reaches a higher value, screen might be blocked by something
        }else{
            self.recognitionFailCount = 0;
            [section updateRect:resultRect];
            [section updateHashFromImage:[self.windowImage getSubImageWithRect:resultRect]];
            //NSLog(@"got it");
        }
    }else{
        result = [section doesImageMatch:[self.windowImage getSubImageWithRect:section.rect]];
        
        // if there are too many fails, run search logic again, in case it moved or changed weirdly.
        if(!result) self.recognitionFailCount++;
    }
    
    return result;
}

- (BOOL)hasSectionMoved:(ImageSection*)section{
    BOOL result = false;
    if(section.imageHash == 0){
        NSLog(@"hasSectionMoved: hash not yet saved, adding hash");
        result = ![self isImageSectionVisible:section];
    }
    
    result = ![section doesImageMatch:[self.windowImage getSubImageWithRect:section.rect]];

    if(result){
        // get current coordinate
        NSError *error;
        NSRect resultRect;
        BOOL matchFound = [CVSearchHelper isImage:section.image
                                      withinImage:self.windowImage
                                      retLocation:&resultRect
                                            error:&error];
        
        if(!matchFound){
            self.recognitionFailCount++;
        }else{
            [section updateRect:resultRect];
            [section updateHashFromImage:[self.windowImage getSubImageWithRect:resultRect]];

        }
    }
    //NSLog(@"hasSectionMoved result: %hhd",result);
    return result;
}








// class methods
+ (NSRect)adjustCoordsForRect:(NSRect)src relativeToRect:(NSRect)reference{
    src.origin = [CVHelper addPoint:reference.origin toPoint:src.origin];
    return src;
}

+ (NSRect)getAdjustedRectForKey:(NSString*)key fromDict:(NSDictionary*)dict relativeToRect:(NSRect)reference{
    NSRect rect = [CoordinatesManager getRectForKey:key fromDict:dict];
    rect.origin = [CVHelper addPoint:reference.origin toPoint:rect.origin];
    return rect;
}
+ (NSRect)getRectForKey:(NSString*)key fromDict:(NSDictionary*)dict{
    NSRect position = NSMakeRect([self getValue:@"x" fromDict:dict forKey:key forType:@"position"],
                                 [self getValue:@"y" fromDict:dict forKey:key forType:@"position"],
                                 [self getValue:@"x" fromDict:dict forKey:key forType:@"size"],
                                 [self getValue:@"y" fromDict:dict forKey:key forType:@"size"]);
    NSLog(@"%@|location: %@",key,NSStringFromPoint(position.origin));
    return position;
}
+ (float)getValue:(NSString*)value fromDict:(NSDictionary*)dict forKey:(NSString*)key forType:(NSString*)type{
    return [dict[key][type][value] floatValue];
}



@end
