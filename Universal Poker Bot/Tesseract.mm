//
//  Tesseract.m
//  TesseractOCRTest
//
//  Created by Siebler, Tiago on 12/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <TesseractFramework/TesseractFramework.h>
#import "Tesseract.h"
#import "NSString+cleaning.h"

@implementation Tesseract

static tesseract::TessBaseAPI* api;
- (id)init{
    return [self initWithNSImage:nil];
}
- (id)initWithNSImage:(NSImage*)image{
    if (self = [super init]) {
        // initialization here
        if(image != nil)
            self.targetImage = image;
        
        // Define the location of the training folder
        NSString* dataPathDirectory = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/"];
        const char* dataPathDirectoryCString = [dataPathDirectory cStringUsingEncoding:NSUTF8StringEncoding];
        setenv("TESSDATA_PREFIX", dataPathDirectoryCString, 1);
        setenv("matcher_debug_level", "0", 1);
        setenv("matcher_debug_flags", "0", 1);
       // INT_MEMBER("matcher_debug_level", 0, "Matcher Debug Level", 0);
       // INT_MEMBER("matcher_debug_flags", 0, "Matcher Debug Flags", 0);

        // Initialize tesseract-ocr with English
        api = new tesseract::TessBaseAPI();
        if (api->Init(NULL, "eng")) {
            fprintf(stderr, "Could not initialize tesseract.\n");
            
            [NSException raise:@"IntializeException" format:@"TessBaseAPI initialize failed."];
        }else{
            //api->SetVariable("debug_file", "tesseract.log");
            api->SetVariable("debug_file", "/dev/null");
            api->SetVariable("debug", "0");
            //api->SetDebugVariable("matcher_debug_level", "0");
            //api->SetDebugVariable("matcher_debug_flags", "0");
        }


    }
    return self;
}

- (NSString*)getString{
    return [self getStringFromImage:self.targetImage];
}
- (NSString*)getStringFromImage:(NSImage*)image{
    NSString *result;
    
    NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    
    unsigned char* imageData = [bitmapRep bitmapData];
    char *text;
    NSSize imageSize = NSMakeSize([bitmapRep pixelsWide],[bitmapRep pixelsHigh]);
    int bytes_per_line = (int)[bitmapRep bytesPerRow];
    int bitsPerPixel = (int)[bitmapRep bitsPerPixel];
    
    text = api->TesseractRect((const unsigned char*)imageData, bitsPerPixel/8,
                              bytes_per_line, 0, 0,
                              imageSize.width, imageSize.height);
    if(text != nil){
        result = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
    }else{
        result = nil;
    }
    delete [] text;

    if (result == nil || [result length] < 4 || [result containsString:@"Total count=0"]) return nil;
    
    NSLog(@"getStringFromImage result: %@, %lu",result, (unsigned long)result.length);

    return result;
}
- (NSString*)getCurrencyValueFromImage:(NSImage*)image{
    NSString *string = [self getStringFromImage:image];
    
    string = [string cleanCurrencyIfPresent];
    return string;
}
- (void)setPageSegmentationRaw{
    api->SetPageSegMode(tesseract::PSM_RAW_LINE);
}
- (void)setPageSegmentationDefault{
    api->SetPageSegMode(tesseract::PSM_SINGLE_LINE);
}

@end
