//
//  ImageRecognition.m
//  CardRecognition
//
//  Created by Siebler, Tiago on 04/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "ImageIndex.h"
#import "constants.h"
#import "NSImage+subImage.h"
#import "NSData+Adler32.h"

#warning shouldn't be linking a object class into the image class like this, need a better way of accessing the tesseract API singleton
#import "PokerTable.h"
#import "NSString+cleaning.h"

@implementation ImageIndex
static NSTimer *imageIndexTimer;

- (id)init
{
    return [self initWithRootPath:kPathImageRoot];
}
- (id)initWithRootPath:(NSString*)rootPath{
    self = [super init];
    if(self) {
        //NSLog(@"initWithRootPath: %@ - %@",rootPath, self);
        self.rootImagesPath = rootPath;
        self.knownImagesCount = 0;
        self.unknownImagesCount = 0;
        
        if(![imageIndexTimer isValid])
            imageIndexTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reloadIndex) userInfo:nil repeats: YES];

        [self reloadIndex];
    }
    return self;
}

static NSDate *methodStart;
- (void)perfStart{
    methodStart = [NSDate date];
}
- (void)perfCheck{
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"##### IMIndex executionTime = %f seconds", executionTime);
}
- (void)perfCheck:(NSString*)event{
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"## %@ - executionTime = %f seconds", event, executionTime);
}

/* 
    some helper methods for various subPaths that images are read from or saved to
*/
// all images that we have classified
- (NSString*)knownImagesPath{
    return [NSString stringWithFormat:@"%@/%@/",self.rootImagesPath,kPathKnown];
}
// all images that we haven't classified / that are unknown
- (NSString*)unknownImagesPath{
    return [NSString stringWithFormat:@"%@/%@/",self.rootImagesPath,kPathUnknown];;
}

// all cards that we know of

- (NSString*)knownNoisePath{
    return [NSString stringWithFormat:@"%@/%@/%@/",     self.rootImagesPath,kPathKnown,kPathNoise];
}
- (NSString*)knownTablePath{
    return [NSString stringWithFormat:@"%@/%@/%@/",  self.rootImagesPath,kPathKnown,kPathTable];
}
- (NSString*)knownPlayerHandsPath{
    return [NSString stringWithFormat:@"%@/%@/%@/",     self.rootImagesPath,kPathKnown,kPathPlayerHands];;
}
- (NSString*)knownCardsPath{
    return [NSString stringWithFormat:@"%@/%@/%@/",     self.rootImagesPath,kPathKnown,kPathCards];
}
- (NSString*)knownButtonsPath{
    return [NSString stringWithFormat:@"%@/%@/%@/",     self.rootImagesPath,kPathKnown,kPathButtons];
}

/*
    helper methods for loading known hashes into sets
 */

- (void)reloadIndex{
    @autoreleasepool {
        [self loadKnownImages];
        [self loadUnknownImages];
        
        [self updateKnownImagesCount];
    }
}
- (void)loadKnownImages{
    // fill allKnownImagesSet with all images from knownImagesPath
    // takes roughly 70% of the overall execution time, the main loading call. Should be done at intervals or once per manual call
    self.allKnownImagesSet = [self setFromFilesInRecursivePath:[self knownImagesPath]];
    
    // call helper methods to full sub-sets - knownNoiseSet, knownTableSet, player hands, cards
    self.knownNoiseSet = [self setFromContentsOfPath:[self knownNoisePath]];
    self.knownTableSet = [self setFromContentsOfPath:[self knownTablePath]];
    self.knownPlayerHandsSet = [self setFromContentsOfPath:[self knownPlayerHandsPath]];
    
    // load up known cards from subdirs cards
    // set is used to very quickly recognise that it's a card, while array is used to check which card (after we know it's definitely a card)
    NSMutableSet *tempSet;
    self.knownCardsArray = [self cardsFromPath:[self knownCardsPath] forSet:&tempSet];
    self.knownCardsSet = tempSet;
    
    // load up known buttons
    NSMutableSet *tempSet2;
    self.knownButtonsArray = [self cardsFromPath:[self knownButtonsPath] forSet:&tempSet2];
    self.knownButtonsSet = tempSet2;

}
- (void)loadUnknownImages{
    // call helper methods to fill unknownCardsSet and unknownPlayerHandsSet
    self.allUnknownImagesSet = [self setFromFilesInRecursivePath:[self unknownImagesPath]];
    // don't need unknownPlayerHands set, just have one set for recognition of unknown images
}

- (NSArray*)arrayFromContentsOfPath:(NSString*)folderPath{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
}
- (NSSet*)setFromContentsOfPath:(NSString*)folderPath{
    return [NSSet setWithArray:[self arrayFromContentsOfPath:folderPath]];
}
- (NSMutableSet*)setFromFilesInRecursivePath:(NSString*)path{
    
    NSURL *directoryURL = [NSURL URLWithString:path]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                         errorHandler:nil];
    
    NSMutableSet *targetSet = [NSMutableSet set];
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            // No error and it’s not a directory; do something with the file
            NSString *fullPath  = [[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            if(![fullPath containsString:kPathTable]){
                [targetSet addObject:[fullPath lastPathComponent]];
                //NSLog(@"found file: %@",fullPath);
            }else{
                //NSLog(@"table: %@", fullPath);
            }
        }
    }
    
    return targetSet;

}
- (NSArray*)cardsFromPath:(NSString*)path forSet:(NSMutableSet**)targetSet{
    if(*targetSet) [*targetSet removeAllObjects];
    *targetSet = [NSMutableSet set];
    
    NSURL *directoryURL = [NSURL URLWithString:path]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            // No error and it’s not a directory; do something with the file
            NSString *fullPath  = [[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            //NSLog(@"found file: %@, last component: %@",fullPath, [[fullPath lastPathComponent] stringByDeletingPathExtension]);
            if(![fullPath containsString:kPathTable]){
                //NSLog(@"found card: %@, last component: %@",fullPath, [[fullPath lastPathComponent] stringByDeletingPathExtension]);
                [returnArray addObject:fullPath];
                [*targetSet addObject:[fullPath lastPathComponent]];
            }else{
                //NSLog(@"table: %@", fullPath);
            }
        }
    }
    
    return returnArray;
}

/*
        end of file reading methods
 */

- (void)updateKnownImagesCount{
    int newKnCnt = (unsigned long)self.allKnownImagesSet.count;
    int newUnknCnt = (unsigned long)self.allUnknownImagesSet.count;
    if(newKnCnt == self.knownImagesCount && newUnknCnt == self.unknownImagesCount) return;
    
    // kinda pointless, no? for now the unknown property is being used by KVO to update the interface when the percentage changes. I guess I should monitor the percentage instead?
    self.knownImagesCount   = newKnCnt;
    self.unknownImagesCount = newUnknCnt;
    
    // percentage known from total
    self.percentageKnown    = ((float)self.knownImagesCount / (float)(self.unknownImagesCount + self.knownImagesCount)) * 100;
    
    //NSLog(@"percentage: %0.2f, totalKnown: %d, totalUnknown: %d",self.percentageKnown, self.knownImagesCount, self.unknownImagesCount);
}


/*
        recognition methods
 */
- (BOOL)isKnownChecksum:(NSString*)checksum __attribute__((deprecated("use getImageType instead, this method is slower and 2 calls instead of 1")))
{
    NSString *fileName = [checksum stringByAppendingString:@".png"];
    
    if([self.allKnownImagesSet containsObject:fileName] ||
       [self.allUnknownImagesSet containsObject:fileName])
        return true;
    
    return false;
//    return [self.allKnownImagesSet containsObject:fileName];
}
- (BOOL)isPlayerCard:(NSImage*)playerCard{
    int cardHash = [playerCard getHash];
    ImageType imageType = [self getImageType:[NSString stringWithFormat:@"%d",cardHash]];
    if(imageType == kImageTypePlayerHand) return true;
    else if(imageType == kImageTypeCard) return true;
    else if(imageType == kImageTypeUnknown) [self handleUnknownImage:playerCard ofType:kPathPlayerHands andHash:cardHash];
    return false;
}
- (BOOL)playerHasAHand:(NSImage*)playerCard outInt:(int*)outInt{
    
    // if a player has cards, then do this:
    if([self isPlayerCard:(NSImage*)playerCard]){
        *outInt += 1;
        return true;
    }
    return false;
}


- (ImageType)getImageType:(NSString*)checksum{
    NSString *fileName = [checksum stringByAppendingString:@".png"];

    ImageType result = kImageTypeUnknown;
    
    // listed in order of priority. Things we read more often shold be in the top
    if([self.knownNoiseSet containsObject:fileName]) result = kImageTypeNoise;
    else if([self.knownTableSet containsObject:fileName]) result = kImageTypeTable;
    else if([self.knownButtonsSet containsObject:fileName]) result = kImageTypeButton;
    else if([self.knownPlayerHandsSet containsObject:fileName]) result = kImageTypePlayerHand;
    else if([self.knownCardsSet containsObject:fileName]) result = kImageTypeCard;
   
    return result;
}

/*
        Retrieval methods
 */
- (NSString*)getCardStringWithImage:(NSImage*)image{
    float height = image.size.height;
    if(height > 42)
        height = 42;
    NSImage *smallerImage = [image getSubImageWithRect:NSMakeRect(0, 0, image.size.width, height)];
    
    int hash = [smallerImage getHash];
    NSString *checksum = [NSString stringWithFormat:@"%d",hash];
    //NSLog(@"imageHash: %@",checksum);
    
    NSString *suit, *value;
    ImageType type = [self getCardWithChecksum:checksum toSuit:&suit toValue:&value];
    switch(type){
        case kImageTypeUnknown:
            [self handleUnknownImage:image ofType:kCardTypeCard andHash:hash];
            break;
            
        case kImageTypeCard:
            return [value stringByAppendingString:suit];
            break;
            
        case kImageTypeTable:
            return kCardTypeTable;
            break;
            
        case kImageTypeNoise:
            return kCardTypeNoise;
            break;
            
        case kImageTypeButton:
            return @"button";
            break;
            
        case kImageTypePlayerHand:
            return @"playerHand";
            break;
    }
    return nil;
}
- (ButtonType)getButtonTypeWithTypeString:(NSString*)typeString{
    ButtonType type = kButtonTypeUnknown;
    if([typeString isEqualToString:kButtonStringFold])          type = kButtonTypeFold;
    else if([typeString isEqualToString:kButtonStringInactive]) type = kButtonTypeInactive;
    else if([typeString isEqualToString:kButtonStringCall])     type = kButtonTypeCall;
    else if([typeString isEqualToString:kButtonStringCheck])    type = kButtonTypeCheck;
    else if([typeString isEqualToString:kButtonStringRaise])    type = kButtonTypeRaise;
    else if([typeString isEqualToString:kButtonStringAllIn])    type = kButtonTypeAllIn;
    else if([typeString isEqualToString:kButtonStringNewTable]) type = kButtonTypeNewTable;
    else if([typeString isEqualToString:kButtonStringStandUp])  type = kButtonTypeStandUp;
    else NSLog(@"unhandled button type: %@",typeString);
    
    return type;
}
- (ButtonType)getButtonTypeWithChecksum:(NSString*)checksum{
    ButtonType type = kButtonTypeUnknown;
    
    for(NSString *currentButton in self.knownButtonsArray){
        if([currentButton containsString:checksum]){
            NSArray *pathComps = [currentButton pathComponents];
            //NSString *first = [pathComps objectAtIndex:([pathComps count] - 3)];//folder containing folder containing file
            NSString *buttonTypeString = [pathComps objectAtIndex:([pathComps count] - 2)];//folder containing file
            
            //NSLog(@"type: %@, all: %@",buttonTypeString, pathComps);
            type = [self getButtonTypeWithTypeString:buttonTypeString];
            return type;
        }
    }
    return type;
}
- (bool)isActiveFoldButton:(NSImage*)image{
    float r, g, b;
    NSColor *avColor = [image averageColor];
    
    r = avColor.redComponent;
    g = avColor.greenComponent;
    b = avColor.blueComponent;
    
    NSLog(@"==== Unknown image has average color of: %f %f %f", r, g, b);
    if(r == 1 && g == 1 && b == 1) return true;
    return false;
}
- (ButtonType)getButtonWithTypeImage:(NSImage*)image{
    //NSLog(@"ImageIndex:getButtonWithTypeImage called for Image: %@",image);

    ButtonType buttonType = kButtonTypeUnknown;

    
    int checksumInt = [image getHash];
    if(checksumInt == 0){
        NSLog(@"failed to get checksum for button %d",checksumInt);
        return buttonType;
    }
    NSString *checksum = [NSString stringWithFormat:@"%d",checksumInt];
    
    ImageType type = [self getImageType:checksum];
    switch(type){
        case kImageTypeUnknown:
            NSLog(@"unknown button type: %@, checksum %@",kPathUnknownButtons,checksum);
            buttonType = [self getButtonByReadingImage:image];
            
            if(buttonType != kButtonTypeUnknown){
                // button type was recognised with text, mark it so it's remembered for future cycles, then move on
                [self saveImage:image asButton:buttonType withChecksum:checksum];
            }else if([self isActiveFoldButton:image]){
                NSLog(@"=== saving auto-recognised fold button image");
                [self saveImage:image asButton:kButtonTypeFold withChecksum:checksum];
            }else
                [self handleUnknownImage:image ofType:kPathUnknownButtons andHash:checksumInt];
            break;
            
        case kImageTypeNoise:
            //NSLog(@"kImageTypeNoise");
            break;
            
        case kImageTypeButton:
            //NSLog(@"button detected");
            buttonType = [self getButtonTypeWithChecksum:checksum];
            break;
            
        default:
            NSLog(@"unhandled type returned in getButtonWithImage");
            break;
    }
    //[self dbgOutputImageType:type];
    //[self dbgOutputButtonType:buttonType];
    
    return buttonType;
}
- (ButtonType)getButtonByReadingImage:(NSImage*)image{
    ButtonType buttonType = kButtonTypeUnknown;
    
    NSString * imageStr = [[PokerTable tessAPI] getStringFromImage:image];
    imageStr = [imageStr clean];
    NSLog(@"getButtonByReadingImage: %@",imageStr);
    
    // deliberately not doing fold, since we're using the fold button to ID if it's the player turn or not
    if([[imageStr lowercaseString] containsString:@"call"]){
        // ignore "call any" shortcut
        if([[imageStr lowercaseString] containsString:@"any"]){
            buttonType = kButtonTypeInactive;
        }else
            buttonType = kButtonTypeCall;
    }else if([[imageStr lowercaseString] containsString:@"raise"]){
        buttonType = kButtonTypeRaise;
    }else if([[imageStr lowercaseString] containsString:@"bet"]){
        buttonType = kButtonTypeRaise;
    }else if([[imageStr lowercaseString] containsString:@"check"]){
        buttonType = kButtonTypeCheck;
    }else if([[imageStr lowercaseString] containsString:@"newtable"]){
        buttonType = kButtonTypeNewTable;
    }else if([[imageStr lowercaseString] containsString:@"standup"]){
        buttonType = kButtonTypeStandUp;
    }
    
    [self dbgOutputButtonType:buttonType];
    
    /*
        - use tesseract to scrape text from image
        - check if text contains known identifiers (raise, bet, check, call)
        - if it does, mark that otherwise unknown image as that type (move it to the known folder)
        - return that as the image type. 
     
     This should decrease the error ratio.
     */
    
    return buttonType;
}
- (void)saveImage:(NSImage*)image asButton:(ButtonType)type withChecksum:(NSString*)checksum{
    NSString *targetPath;
    NSString *button;
    
    switch (type) {
        case kButtonTypeCall:
            button = @"Call";
            break;
            
        case kButtonTypeRaise:
            button = @"Raise";
            break;
            
        case kButtonTypeCheck:
            button = @"Check";
            break;
            
        case kButtonTypeFold:
            button = @"Fold";
            break;
            
        case kButtonTypeInactive:
            button = @"Inactive";
            break;
            
        case kButtonTypeAllIn:
            button = @"AllIn";
            break;
            
        case kButtonTypeNewTable:
            button = @"NewTable";
            break;
            
        case kButtonTypeStandUp:
            button = @"StandUp";
            break;
            
        case kButtonTypeUnknown:
            NSLog(@"handleButtonOfType: kButtonTypeUnknown");
            return;
            break;
    }
    
    targetPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@.png",kPathImageRoot,kPathKnown,kPathButtons,button,checksum];

    NSLog(@"saving auto-recognized button (%@) with checksum (%@) to path: %@",button, checksum, targetPath);
    [image saveAsPNGWithName:targetPath];
}
- (NSString*)getStringForType:(ImageType)type{
    NSString *string;
    
    switch(type){
        case kImageTypeNoise:
            string = @"noise";
            break;
            
        case kImageTypeTable:
            string = @"table";
            break;
            
        case kImageTypePlayerHand:
            string = @"playerhand";
            break;
            
        case kImageTypeCard:
            string = @"card";
            break;
            
        case kImageTypeButton:
            return @"button";
            break;
            
        case kImageTypeUnknown:
            string = @"unkn";
            break;
    }
    
    return string;
}

- (BOOL)recogniseImage:(NSImage*)image forCard:(PlayingCard**)card{
    BOOL result = false;
    
    float height = image.size.height;
    if(height > 42)
        height = 42;
    NSImage *smallerImage = [image getSubImageWithRect:NSMakeRect(0, 0, image.size.width, height)];
    
    int hash = [smallerImage getHash];
    NSString *checksum = [NSString stringWithFormat:@"%d",hash];
    //NSLog(@"imageHash: %@",checksum);
    
    NSString *suit, *value;
    ImageType type = [self getCardWithChecksum:checksum toSuit:&suit toValue:&value];
    
    (*card).dbgValue = [self getStringForType:type];
    if(type == kImageTypeUnknown){
        [self handleUnknownImage:image ofType:kCardTypeCard andHash:hash];

    }else if(type == kImageTypeCard){
        [*card setWithSuit:suit andValue:value];
        result = true;
    }
    
    return result;
}
- (PlayingCard*)getCardWithImage:(NSImage*)image{///recognizedCardFromImage
    float height = image.size.height;
    if(height > 42)
        height = 42;
    NSImage *smallerImage = [image getSubImageWithRect:NSMakeRect(0, 0, image.size.width, height)];
    
    int hash = [smallerImage getHash];
    NSString *checksum = [NSString stringWithFormat:@"%d",hash];
    //NSLog(@"imageHash: %@",checksum);
    
    NSString *suit, *value;
    ImageType type = [self getCardWithChecksum:checksum toSuit:&suit toValue:&value];
    if(type == kImageTypeUnknown){
        [self handleUnknownImage:image ofType:kCardTypeCard andHash:hash];
        return nil;
    }else if(type == kImageTypeCard){
        PlayingCard *card = [[PlayingCard alloc] init];
        [card setWithSuit:suit andValue:value];
        return card;
    }
    return nil;
}
- (PlayingCard*)getCardWithImage:(NSImage*)image error:(NSError**)error{
    float height = image.size.height;
    if(height > 42)
        height = 42;
    NSImage *smallerImage = [image getSubImageWithRect:NSMakeRect(0, 0, image.size.width, height)];
    
    int hash = [smallerImage getHash];
    NSString *checksum = [NSString stringWithFormat:@"%d",hash];
    //NSLog(@"imageHash: %@",checksum);
    
    NSString *suit, *value;
    ImageType type = [self getCardWithChecksum:checksum toSuit:&suit toValue:&value];
    if(type == kImageTypeUnknown){
        [self handleUnknownImage:image ofType:kCardTypeCard andHash:hash];
        return nil;
    }else if(type == kImageTypeCard){
        PlayingCard *card = [[PlayingCard alloc] init];
        [card setWithSuit:suit andValue:value];
        return card;
    }
    return nil;
}
- (PlayingCard*)getCardWithChecksum:(NSString*)checksum{
    NSString *suit, *value;
    PlayingCard *resultCard;
    BOOL result = [self getCardWithChecksum:checksum toSuit:&suit toValue:&value];
    if(result){
        if(resultCard == nil) resultCard = [[PlayingCard alloc] init];
        
        [resultCard setWithSuit:suit andValue:value];
    }
    return resultCard;
}
- (ImageType)getCardWithImage:(NSImage*)image toSuit:(NSString**)theSuit toValue:(NSString**)theValue{
    float height = image.size.height;
    if(height > 42)
        height = 42;
    NSImage *smallerImage = [image getSubImageWithRect:NSMakeRect(0, 0, image.size.width, height)];
    
    NSLog(@"new recognizedCardFromImage");
    
    int hash = [smallerImage getHash];
    NSString *checksum = [NSString stringWithFormat:@"%d",hash];
    return [self getCardWithChecksum:checksum toSuit:theSuit toValue:theValue];
}
- (ImageType)getCardWithChecksum:(NSString*)checksum toSuit:(NSString**)theSuit toValue:(NSString**)theValue{
    ImageType type = kImageTypeUnknown;
    type = [self getImageType:checksum];
    if(type == kImageTypeCard){
        for(NSString *currentCardPath in self.knownCardsArray){
            if([currentCardPath containsString:checksum]){
                NSArray *pathComps = [currentCardPath pathComponents];
                *theSuit = [pathComps objectAtIndex:([pathComps count] - 3)];
                *theValue = [pathComps objectAtIndex:([pathComps count] - 2)];
                //NSLog(@"card %@, suit: %@", *theValue, *theSuit);
                return type;
            }
        }
    }
    

    /*
     maybe faster:
        // For string kind of values:
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", checksum];
        NSArray *results = [self.knownCardsArray filteredArrayUsingPredicate:predicate];

     or use NSDictionary and objectForKey if more speed is needed
     */
    return type;
}
- (ImageType)getTypeWithImage:(NSImage*)image{
    int checksumInt = [image getHash];
    //NSLog(@"getTypeWithImage");
    
    NSString *checksum = [NSString stringWithFormat:@"%d",checksumInt];

    return [self getImageType:checksum];
}





- (void)handleUnknownImage:(NSImage*)image ofType:(NSString*)type andHash:(int)hash{
    if([type isEqualToString:kCardTypeCard]){
        //NSString *cardSuit = [self recognizeSuitFromImage:image ofType:kCardTypeSuit];
        //NSLog(@"card suit for unkn image: %@",cardSuit);
    }
    NSLog(@"handleUnknownImage ofType:%@ and hash %d",type,hash);
    [image saveAsPNGWithName:[NSString stringWithFormat:@"%@/%@/%@/%d.png",self.rootImagesPath,kPathUnknown,type,hash]];
    //[image saveAsPNGWithName:[NSString stringWithFormat:@"/Users/tsiebler/Desktop/pkr/images/%@/%d.png",type,hash]];
}


- (void)dbgOutputImageType:(ImageType)type{
    switch(type){
        case kImageTypeNoise:
            NSLog(@"kImageTypeNoise");
            break;
            
        case kImageTypeTable:
            NSLog(@"kImageTypeTable");
            break;
            
        case kImageTypePlayerHand:
            NSLog(@"kImageTypePlayerHand");
            break;
            
        case kImageTypeCard:
            NSLog(@"kImageTypeCard");
            break;
            
        case kImageTypeUnknown:
            NSLog(@"kImageTypeUnknown");
            break;
            
        case kImageTypeButton:
            NSLog(@"kImageTypeButton");
            break;
    }
}
- (void)dbgOutputButtonType:(ButtonType)type context:(NSString*)context{
    switch(type){
        case kButtonTypeCall:
            NSLog(@"%@ - kButtonTypeCall", context);
            break;
            
        case kButtonTypeRaise:
            NSLog(@"%@ - kButtonTypeRaise", context);
            break;
            
        case kButtonTypeCheck:
            NSLog(@"%@ - kButtonTypeCheck", context);
            break;
            
        case kButtonTypeInactive:
            NSLog(@"%@ - kButtonTypeInactive", context);
            break;
            
        case kButtonTypeFold:
            NSLog(@"%@ - kButtonTypeFold", context);
            break;
            
        case kButtonTypeAllIn:
            NSLog(@"%@ - kButtonTypeAllIn", context);
            break;
            
        case kButtonTypeNewTable:
            NSLog(@"%@ - kButtonTypeNewTable", context);
            break;
            
        case kButtonTypeStandUp:
            NSLog(@"%@ - kButtonTypeStandUp", context);
            break;
            
        case kButtonTypeUnknown:
            NSLog(@"%@ - kButtonTypeUnknown", context);
            break;
    }
}
- (void)dbgOutputButtonType:(ButtonType)type{
    switch(type){
        case kButtonTypeCall:
            NSLog(@"kButtonTypeCall");
            break;
            
        case kButtonTypeRaise:
            NSLog(@"kButtonTypeRaise");
            
        case kButtonTypeCheck:
            NSLog(@"kButtonTypeCheck");
            break;
            
        case kButtonTypeInactive:
            NSLog(@"kButtonTypeInactive");
            break;
            
        case kButtonTypeFold:
            NSLog(@"kButtonTypeFold");
            break;
            
        case kButtonTypeAllIn:
            NSLog(@"kButtonTypeAllIn");
            break;

        case kButtonTypeNewTable:
            NSLog(@"kButtonTypeNewTable");
            break;
            
        case kButtonTypeStandUp:
            NSLog(@"kButtonTypeStandUp");
            break;
            
        case kButtonTypeUnknown:
            NSLog(@"kButtonTypeUnknown");
            break;
    }
}

@end
