//
//  NumbersHelper.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 09/05/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "NumbersHelper.h"

@implementation NumbersHelper
+ (long long int)getNumberFromFormattedString:(NSString*)string{
    string = [string stringByReplacingOccurrencesOfString:@"$" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"K" withString:@"000"];
    string = [string stringByReplacingOccurrencesOfString:@"M" withString:@"000000"];
    string = [string stringByReplacingOccurrencesOfString:@"B" withString:@"000000000"];
    
    unsigned long long ullvalue = strtoull([string UTF8String], NULL, 0);
    
    return ullvalue;
}
+ (NSString*)formatMoneyAsString:(long long int)theNumber{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.maximumFractionDigits = 0;
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithLongLong:theNumber]];
    
    return [NSString stringWithFormat:@"%@",formatted];
}
+ (NSString*)numberToCurrencyString:(int)number{
    // Set currency format to USD
    NSLocale *usd = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    // Convert to currency format
    NSNumber *dn = [NSNumber numberWithInt:number];
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:usd];
    [currencyFormatter setMaximumFractionDigits:0];
    NSString *str=[currencyFormatter stringFromNumber:dn];
    
    // For some reason I get the number wrapped in brackets if it's a negative, this'll sort it out.
    str = [str stringByReplacingOccurrencesOfString:@"(" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@")" withString:@""];
    return str;
}
@end
