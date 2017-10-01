//
//  NSImage+subImage.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (SubImage)

// NSImage* sub = [someImage getSubImageWithRect:NSMakeRect(0, 100, 500, 50)];//xpoint, ypoint, width, height
- (NSImage*)getSubImageWithRect:(NSRect)subrect;
- (NSImage*)getBWSubImageWithRect:(NSRect)subRect;
- (void)saveToFile:(NSURL *)fileURL;
- (void)saveAsPNGWithName:(NSString*) fileName;
- (int)getHash;
- (NSColor*)averageColor;
@end
