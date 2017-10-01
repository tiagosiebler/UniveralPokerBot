//
//  NumbersHelper.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/05/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumbersHelper : NSObject
+ (long long int)getNumberFromFormattedString:(NSString*)string;
+ (NSString*)formatMoneyAsString:(long long int)theNumber;
+ (NSString*)numberToCurrencyString:(int)number;
@end
