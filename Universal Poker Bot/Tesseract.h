//
//  Tesseract.h
//  TesseractOCRTest
//
//  Created by Siebler, Tiago on 12/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tesseract : NSObject

@property (strong) NSImage* targetImage;

- (id)initWithNSImage:(NSImage*)image;
- (NSString*)getString;
- (NSString*)getStringFromImage:(NSImage*)image;
- (NSString*)getCurrencyValueFromImage:(NSImage*)image;
- (void)setPageSegmentationRaw;
- (void)setPageSegmentationDefault;
@end
