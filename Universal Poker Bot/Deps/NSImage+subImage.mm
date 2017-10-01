//
//  NSImage+subImage.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "NSImage+subImage.h"
#import "NSData+Adler32.h"

@implementation NSImage (SubImage)
// takes NSImage to get subNSImage using coordinates
- (NSImage*)getSubImageWithRect:(NSRect)subRect{
    //NSLog(@"- getSubImageWithRect");
    CGImageSourceRef originalImage = NULL;//loadRef
 
    const void *keys[] =   { kCGImageSourceShouldCache};
    const void *values[] = { kCFBooleanFalse};
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    NSData *data = [self TIFFRepresentation];
    if(data == nil){
        //NSLog(@"getSubImageWithRect:failed to get tiff representation, getting PNG instead");
        //NSLog(@" failed to get data from image! Options: %@",[self representations]);
        data = [self PNGRepresentationOfImage:self];
        if(data == nil){
            NSLog(@"!!!!!!!!!!!!!!!!!!!! WARNING: Failed to get NSData from image!!!");
        }
        //NSLog(@"data: %@",data);
    }
    
    originalImage = CGImageSourceCreateWithData((__bridge CFDataRef)data, optionsDictionary);
    CGImageRef originalImageRef =  CGImageSourceCreateImageAtIndex(originalImage, 0, NULL);

    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(originalImageRef, subRect);

    if(croppedCGImage == NULL){
        NSLog(@"failed to crop");
        CFRelease(originalImage);
        CFRelease(optionsDictionary);
        CFRelease(originalImageRef);
        return nil;
    }
    
    NSImage *croppedNSImage = [[NSImage alloc] initWithCGImage:croppedCGImage size:NSMakeSize(subRect.size.width, subRect.size.height)];
    
    CFRelease(originalImage);
    CFRelease(optionsDictionary);
    CFRelease(originalImageRef);
    CFRelease(croppedCGImage);
    
    //NSLog(@"- getSubImageWithRect end");
    return croppedNSImage;
}


// might reduce the quality
- (void)saveToFile:(NSURL *)fileURL
{
    
    NSBitmapImageRep *bitmapRep = nil;
    
    for (NSImageRep *imageRep in [self representations])
    {
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]])
        {
            bitmapRep = (NSBitmapImageRep *)imageRep;
            break;
        }
    }
    
    if (!bitmapRep)
    {
        bitmapRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
    }
    
    //NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    NSData *imageData = [bitmapRep representationUsingType:[self fileTypeForFile:[fileURL lastPathComponent]] properties:nil];
    [imageData writeToURL:fileURL atomically:NO];
}
- (void) saveAsPNGWithName:(NSString*) fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
}

- (NSBitmapImageFileType)fileTypeForFile:(NSString *)file
{
    NSString *extension = [[file pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"png"])
    {
        return NSPNGFileType;
    }
    else if ([extension isEqualToString:@"gif"])
    {
        return NSGIFFileType;
    }
    else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
    {
        return NSJPEGFileType;
    }
    else
    {
        return NSTIFFFileType;
    }
}
- (NSData *) PNGRepresentationOfImage:(NSImage *) image {
    // Create a bitmap representation from the current image
    
    [image lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [image unlockFocus];
    
    return [bitmapRep representationUsingType:NSPNGFileType properties:nil];
}
- (int)getHash{
   // NSLog(@"getHash TIFF call");
    
    NSData *data = [self TIFFRepresentation];
    if(data == nil){
        //NSLog(@"getHash:failed to get tiff representation, getting PNG instead");
        data = [self PNGRepresentationOfImage:self];
        if(data == nil){
            NSLog(@"!!!!!!!!!!!!!!!!!!!! WARNING: Failed to get NSData from image!!!");
        }
        //NSLog(@"data: %@",data);
    }
    int hash = [data adler32];
    
    if(hash == 0){
        NSLog(@"failed to getHash:NSImage:");
    }
    
    return hash;
}
- (NSColor*)averageColor{
    CGImageSourceRef originalImage = NULL;//loadRef
    
    const void *keys[] =   { kCGImageSourceShouldCache};
    const void *values[] = { kCFBooleanFalse};
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    NSData *data = [self TIFFRepresentation];
    if(data == nil){
        //NSLog(@"getSubImageWithRect:failed to get tiff representation, getting PNG instead");
        //NSLog(@" failed to get data from image! Options: %@",[self representations]);
        data = [self PNGRepresentationOfImage:self];
        if(data == nil){
            NSLog(@"!!!!!!!!!!!!!!!!!!!! WARNING: Failed to get NSData from image!!!");
        }
        //NSLog(@"data: %@",data);
    }
    
    originalImage = CGImageSourceCreateWithData((__bridge CFDataRef)data, optionsDictionary);
    CGImageRef rawImageRef =  CGImageSourceCreateImageAtIndex(originalImage, 0, NULL);
    
    CFDataRef cgData = CGDataProviderCopyData(CGImageGetDataProvider(rawImageRef));
    const UInt8 *rawPixelData = CFDataGetBytePtr(cgData);
    
    NSUInteger imageHeight = CGImageGetHeight(rawImageRef);
    NSUInteger imageWidth  = CGImageGetWidth(rawImageRef);
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(rawImageRef);
    NSUInteger stride      = CGImageGetBitsPerPixel(rawImageRef) / 8;
    
    // Here I sort the R,G,B, values and get the average over the whole image
    unsigned int red   = 0;
    unsigned int green = 0;
    unsigned int blue  = 0;
    
    for (int row = 0; row < imageHeight; row++) {
        const UInt8 *rowPtr = rawPixelData + bytesPerRow * row;
        for (int column = 0; column < imageWidth; column++) {
            red    += rowPtr[0];
            green  += rowPtr[1];
            blue   += rowPtr[2];
            rowPtr += stride;
            
        }
    }
    
    CFRelease(cgData);
    CFRelease(originalImage);
    CFRelease(optionsDictionary);
    CFRelease(rawImageRef);

    CGFloat f = 1.0f / (255.0f * imageWidth * imageHeight);
    return [NSColor colorWithRed:f * red  green:f * green blue:f * blue alpha:1];
}
@end
