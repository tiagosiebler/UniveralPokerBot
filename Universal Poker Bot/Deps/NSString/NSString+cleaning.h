//
//  NSString+cleaning.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 13/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (Cleaning)

-(NSString*) clean;
-(NSString*) cleanCurrencyIfPresent;
-(NSString*) extractValue;//calls clean automatically
- (unsigned long long) betValue:(NSString*)dbgStr;
- (unsigned long long) betValue;
- (unsigned long long) ULongLong;

+ (NSString*)formatPercentageFromFloat:(float)floatValue;
@end
