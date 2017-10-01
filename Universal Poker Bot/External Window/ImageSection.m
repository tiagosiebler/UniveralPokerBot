//
//  ImageSection.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "ImageSection.h"
#import "PokerTable.h"
#import "NSImage+subImage.h"
#import "NSData+Adler32.h"

@implementation ImageSection

static BOOL dbgLog = false;

- (id)init{
    if (self = [super init]) {

        self.isSet = false;
        self.imageHash = 0;
    }
    return self;
}

- (void)updateRect:(NSRect)rect{
    self.rect = rect;
    self.isSet = true;
}
- (void)updateHash{
    self.imageHash = [self.image getHash];
}
- (void)updateHashFromImage:(NSImage*)image{
    self.imageHash = [image getHash];
}

/*
    ImageSection should have a Rect set that lists the position and the size of the location of interest
        - take passed image (should be a screenshot)
        - get subimage using known rect
        - update hash store
        - attempt recognition
 */
- (NSImage*)getImageFromScreenshot:(NSImage*)image{
    if(!self.isSet){
        NSLog(@"ImageSection - Rect undefined!");
        return nil;
    }
    
    if(image == nil){
        NSLog(@"ImageSection:getImageFromScreenshot:image == nil");
        return nil;
    }
    if(dbgLog) NSLog(@"ImageSection - loadImageFromScreenshot, getting sub with rect: %@",NSStringFromRect(self.rect));

    self.image = [image getSubImageWithRect:self.rect];
    
    if(dbgLog) NSLog(@"### subImage retrieved");
    [self updateHash];
    if(dbgLog) NSLog(@"#### hash updated");
    self.type = [PokerTable.IMIndex getTypeWithImage:self.image];
    
    if(dbgLog) [PokerTable.IMIndex dbgOutputImageType:self.type];
    
    return self.image;
}
// no hashing is done on this one, save CPU
- (NSImage*)getPlainImageFromScreenshot:(NSImage*)image{
    self.image = [image getSubImageWithRect:self.rect];
    
    return self.image;
}
- (NSImage*)getBetImageFromScreenshot:(NSImage*)image{
    NSImage *tempImage = [self getImageFromScreenshot:image];
    
    self.image = [tempImage clearForBets];
    return self.image;
}
- (NSImage*)getPotImageFromScreenshot:(NSImage*)image{
    NSImage *tempImage = [self getImageFromScreenshot:image];
    
    self.image = [tempImage clearForPots];
    return self.image;
}

- (NSImage*)getBWImageFromScreenshot:(NSImage*)image{
    if(!self.isSet){
        NSLog(@"ImageSection - Rect undefined!");
        return nil;
    }
    
    if(image == nil){
        NSLog(@"ImageSection:getBWImageFromScreenshot:image == nil");
        return nil;
    }
    if(dbgLog) NSLog(@"ImageSection - loadImageFromScreenshot, getting sub with rect: %@",NSStringFromRect(self.rect));
    
    self.image = [image getBWSubImageWithRect:self.rect];
    
    if(dbgLog) NSLog(@"### subImage retrieved");
    [self updateHash];
    if(dbgLog) NSLog(@"#### hash updated");
    self.type = [PokerTable.IMIndex getTypeWithImage:self.image];
    
    if(dbgLog) [PokerTable.IMIndex dbgOutputImageType:self.type];
    
    return self.image;
}
- (ButtonType)getButton{
    //NSLog(@"ImageSection:getbutton called");
    self.buttonType = [PokerTable.IMIndex getButtonWithTypeImage:self.image];
    
    return self.buttonType;
}
- (ButtonType)getPartialButton{
    NSImage *partialImage = [self.image getSubImageWithRect:NSMakeRect(0, 0, 100, self.image.size.height)];
    self.buttonType = [PokerTable.IMIndex getButtonWithTypeImage:partialImage];

#warning read button value here, e..g if it's call xxxx instead of just check
    return self.buttonType;
}


- (BOOL)doesImageMatch:(NSImage*)image{
    return self.imageHash == [image getHash];
}

- (NSPoint)getClickablePoint{
    return NSMakePoint(self.rect.origin.x + 10, self.rect.origin.y + 10);
}

- (void)dbgLog:(NSString*)context{
    NSLog(@"==ImageSection %@: rect(%@)",context, NSStringFromRect(self.rect));
}
@end
