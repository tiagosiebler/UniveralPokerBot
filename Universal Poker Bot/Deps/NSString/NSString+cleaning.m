//
//  NSString+cleaning.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 13/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "NSString+cleaning.h"

@implementation NSString (Cleaning)

-(NSString*) clean{
    NSLog(@"clean string called: %@", self);
    NSString *string = self;
    if(string == nil) return nil;
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"K 5" withString:@"K/$"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@":ard" withString:@"card"];
    string = [string stringByReplacingOccurrencesOfString:@"ds:5" withString:@"ds:$"];
    string = [string stringByReplacingOccurrencesOfString:@"/5" withString:@"/$"];
    string = [string stringByReplacingOccurrencesOfString:@"/sso" withString:@"/$80"];
    string = [string stringByReplacingOccurrencesOfString:@"ol<" withString:@"0K"];
    string = [string stringByReplacingOccurrencesOfString:@"l<" withString:@"K"];
    string = [string stringByReplacingOccurrencesOfString:@"b|ind" withString:@"blind"];
    string = [string stringByReplacingOccurrencesOfString:@"blindSI" withString:@"inds:"];
    string = [string stringByReplacingOccurrencesOfString:@"bl" withString:@"bl"];
    string = [string stringByReplacingOccurrencesOfString:@"ind52" withString:@"inds:"];
    string = [string stringByReplacingOccurrencesOfString:@"blmds:5100f" withString:@"blinds:$100/"];
    string = [string stringByReplacingOccurrencesOfString:@"011005:5" withString:@"blinds:$"];
    string = [string stringByReplacingOccurrencesOfString:@"$500!" withString:@"$500/"];
    string = [string stringByReplacingOccurrencesOfString:@"$50051K" withString:@"$500/1K"];
    
    if([string isEqualToString:@""]) return nil;
    if(![string containsString:@"$"]){
        if([string hasPrefix:@"5"]) {
            @try {
                string = [string stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"$"];
            }
            @catch (NSException *exception) {
                NSLog(@"clean: exception = %@",exception.description);
                return nil;
            }
            @finally {
                
            }
            NSLog(@"== fixed missing dollar in string: %@", string);
        }
        else{
            NSLog(@"#######== couldn't fix missing dollar: %@", string);
        }
    }

    
    
    //NSLog(@"clean: reached end: %@", string);
    return string;
}
-(NSString*) cleanCurrencyIfPresent{
    //NSLog(@"cleanCurrencyIfPresent");
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"EN_US"];

    NSString *string = self;
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"," withString:@""];

    NSMutableCharacterSet *excludeSet = [[NSCharacterSet characterSetWithCharactersInString:@"$0123456789"] mutableCopy];
    [excludeSet addCharactersInString:[locale objectForKey:NSLocaleCurrencySymbol]];
    
    excludeSet = [[excludeSet invertedSet] mutableCopy];


    // [excludeSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    
    
    string = [string stringByTrimmingCharactersInSet:excludeSet];
    if([string isEqualToString:@""] || string == nil) return nil;

    //NSLog(@"trimmed to: %@",string);
    if(![string containsString:@"$"]){
        
        if([string hasPrefix:@"5"]) {
            NSLog(@"== cleanCurrencyIfPresent: length: %lu - str(%@)",(unsigned long)string.length, string);
            
            @try {
                string = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"$"];
            }
            @catch (NSException *exception) {
                NSLog(@"== cleanCurrencyIfPresent: exception = %@",exception.description);
                return nil;
            }
            @finally {
                
            }
            NSLog(@"== cleanCurrencyIfPresent: fixed missing dollar in string: %@", string);
        }
        else{
            NSLog(@"== cleanCurrencyIfPresent: couldn't fix missing dollar: %@", string);
            return nil;
        }
    }
    return string;
}
-(NSString*) extractValue{
    NSString *string = self;
    long long multiplier = 1;
    //NSLog(@"extractValue: begin: %@, %@", self, string);

    NSString *separator = nil;
    string = [[string clean] lowercaseString];
    string = [string stringByReplacingOccurrencesOfString:@"call" withString:@""];
    
    if([string containsString:@"."]){
        NSArray* components = [string componentsSeparatedByString:@"."];
        //NSLog(@"extractValue: split value into: %@",components);
        string = [components objectAtIndex:0];
        separator = [components objectAtIndex:1];
    }
    string = [string stringByReplacingOccurrencesOfString:@"," withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"$" withString:@""];

    string = [string stringByReplacingOccurrencesOfString:@"k" withString:@"000"];
    string = [string stringByReplacingOccurrencesOfString:@"m" withString:@"000000"];
    string = [string stringByReplacingOccurrencesOfString:@"b" withString:@"000000000"];
    
    unsigned long long mainValue = [string ULongLong];

    if(separator != nil){
        if([separator containsString:@"k"]) multiplier = 1000;
        else if([separator containsString:@"m"]) multiplier = 1000000;
        else if([separator containsString:@"b"]) multiplier = 1000000000;
    }
    
    //NSLog(@"separator: %@",separator);
    
    separator = [separator extractNumbers];
    //NSLog(@"separator: %@",separator);

    unsigned long long decimalPart = [separator ULongLong];
    if(decimalPart != 0){
        //NSLog(@"decimalPart: %llu", decimalPart);
        while(decimalPart > 99) decimalPart = decimalPart / 10;//only want 2 digit decimals, or this math doesn't work
        
        //NSLog(@"decimalPart: %llu", decimalPart);
        decimalPart = (multiplier / 100) * decimalPart;
        //NSLog(@"decimalPart: %llu", decimalPart);
    }
    
    mainValue = (mainValue * multiplier) + decimalPart;
    //NSLog(@"extractValue finished with: %llu",mainValue);
    return [NSString stringWithFormat:@"%llu",mainValue];
}
- (NSString*) extractNumbers{
    NSString *string = self;
    
    NSMutableCharacterSet *excludeSet = [[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet] mutableCopy];
    [excludeSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    
    string = [string stringByTrimmingCharactersInSet:excludeSet];

    return string;
}
- (unsigned long long) betValue:(NSString*)dbgStr{
    NSString *string = self;
    
    
    NSLog(@"---- getting betValue for string (%@): %@", dbgStr, string);
    
    if(string == nil) return 0;
    if(![string containsString:@"$"]) return 0;
    
    string = [string extractValue];
    
    unsigned long long betValue = [string ULongLong];
    
    NSLog(@"---- betValue (%@): %llu", dbgStr, betValue);
    return betValue;
}
- (unsigned long long) betValue{
    NSString *string = self;

    
    NSLog(@"---- getting betValue for string: %@",string);

    if(string == nil) return 0;
    if(![string containsString:@"$"]) return 0;
    
    string = [string extractValue];
    
    unsigned long long betValue = [string ULongLong];
    
    NSLog(@"---- betValue: %llu", betValue);
    return betValue;
}
- (unsigned long long) ULongLong{
    return strtoull([self UTF8String], NULL, 0);
}

+ (NSString*)formatPercentageFromFloat:(float)floatValue{
    return [NSString stringWithFormat:@"%0.2f%@",floatValue * (float)100,@"%"];
}
@end
