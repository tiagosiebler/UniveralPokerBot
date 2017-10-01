//
//  AppDelegate.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 02/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "AppDelegate.h"
#import "Deps/NSData/NSData+Adler32.h"
#import "PATemplateMatch.hpp"
#import "NSImage+subImage.h"
#import "CVHelper.hpp"
#import "CVSearchHelper.hpp"
#import "StateMonitoringWindow.h"

using namespace std;
using namespace cv;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
int action = 0;
NSString *path;
NSData *data;
NSImage *mainImage;

NSString *imageStore;



static NSDate *methodStart;
- (void)startCount{
    methodStart = [NSDate date];
}
- (void)checkTimeTaken{
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"####### app delegate executionTime = %f seconds", executionTime);
    printf("\n\n\n");
}
- (void)checkTimeTaken:(NSString*)event{
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"## %@ - executionTime = %f seconds", event, executionTime);
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application


    // open zynga poker in chrome instance, so it can be minimised. Possible?
    // https://apps.facebook.com/texas_holdem/
    // http://www.poker-ai.org/phpbb/viewtopic.php?f=26&t=2424
    
    // keep reference of poker window, and make screenshots of it to read from it
    
    // simulate clicks and drags on this window to trigger actions on it
    
    //[self tableMapTest];
    //[self screenshotTest];
    
    self.stateWindowCtrl = [[StateMonitoringWindow alloc] initWithWindowNibName:@"StateMonitoringWindow"];
    [self.stateWindowCtrl showWindow:nil];
    [self.stateWindowCtrl.window makeKeyAndOrderFront:nil];
    [self.stateWindowCtrl.window setLevel:NSStatusWindowLevel];
    NSString *zyngaImages = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/Zynga/";
    NSString *testTable = @"testImages/tableSeated.png";
    
    mainImage = [CVHelper NSImageFromPath:[zyngaImages stringByAppendingString:testTable]];
    [self.mainImageView setImage:mainImage];
    
    /*
    self.coordManager = [[CoordinatesManager alloc] init];
    self.coordManager.pathToTableMap = [[NSBundle mainBundle] pathForResource:@"relativeZyngaDict" ofType:@"plist"];//*/

    //[self.stateWindowCtrl setChipLocation:self.coordManager.chipLocation];
    //NSLog(@"self-didFinish: %@",self);
    
    //[self gatherCoordinatesRelativeToChip];
    
}
- (IBAction)logSelf:(id)sender {
    NSLog(@"self-IBaction: %@",self);
}
- (IBAction)findPokerWindow:(id)sender {
    
}
- (IBAction)takeScreenshot:(id)sender {
//    [self screenshotTest];

}

/*
- (NSDictionary*)adjustCoordsRelativeToRect:(NSRect)referenceRect forDict:(NSDictionary*)coordinates{
    for (NSString *coordinateName in coordinates) {
        //NSDictionary *coordinate = coordinates[coordinateName];
        NSRect subRect = [self getRectForKey:coordinateName fromDict:coordinates];
        subRect.origin = [CVHelper addPoint:self.coordManager.chipLocation.origin toPoint:subRect.origin];
        
        NSImage *subImage = [mainImage getSubImageWithRect:subRect];
        [subImage saveAsPNGWithName:[NSString stringWithFormat:@"/Users/tsiebler/Desktop/pkr/images/Zynga/%@.png", coordinateName]];
        [self.processingImageView setImage:subImage];
        
    }
}//*/

NSMutableDictionary *coordinatesDict;
// get coordinates relative to image corner. Image corner is 22x110 from red topleft corner below chip
/*
- (void)gatherCoordinatesRelativeToChip{
    NSString *zyngaImages = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/Zynga/";
    NSString *testTable = @"testImages/tableSeated.png";
    
    NSImage *testTableImage = [CVHelper NSImageFromPath:[zyngaImages stringByAppendingString:testTable]];
    [self.mainImageView setImage:testTableImage];
    NSImage *subImage;
    
    //// now that we have the chip location, crack on with getting everything relative to chip position
    NSString *plistFile = @"/Users/tsiebler/Desktop/pkr/images/relativeZyngaDict.plist";
    NSMutableDictionary *coordinates = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
    NSLog(@"coordinates: %@",coordinates);

    for (NSString *coordinateName in coordinates) {
        NSRect subRect = [self getRectForKey:coordinateName fromDict:coordinates];
        subRect.origin = [CVHelper addPoint:self.coordManager.chipLocation.origin toPoint:subRect.origin];
        
        subImage = [testTableImage getSubImageWithRect:subRect];
        [subImage saveAsPNGWithName:[NSString stringWithFormat:@"/Users/tsiebler/Desktop/pkr/images/Zynga/%@.png", coordinateName]];
        [self.processingImageView setImage:subImage];
    }
}//*/
/*
- (void)gatherCoordinates{
    //path = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/mainTestImage.png";
    NSString *plistFile = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/zyngaTable.plist";
    NSString *zyngaImages = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/Zynga/";
    NSString *testTable = @"testImages/tableSeated.png";
    
    NSImage *testTableImage = [CVHelper NSImageFromPath:[zyngaImages stringByAppendingString:testTable]];
    // means all reference points need to be stored relative to origin....hmm
    
    
    //testTableImage = [CVHelper drawRect:chipLoc onImage:testTableImage];
    
    // draw results in view
    [self.mainImageView setImage:testTableImage];
    
    NSImage *subImage;// = [testTableImage getSubImageWithRect:chipLoc];//xpoint, ypoint, width, height
    //[self.processingImageView setImage:subImage];
    
    NSMutableDictionary *coordinates = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];
    //NSLog(@"coordinates: %@",coordinates);
    coordinates = [coordinates[@"coordinates"] mutableCopy];
    coordinatesDict = [NSMutableDictionary dictionary];

   // NSLog(@"coordinates: %@",coordinates);
    for (NSString *coordinateName in coordinates) {
        //NSDictionary *coordinate = coordinates[coordinateName];
        subImage = [self getImageForKey:coordinateName fromDict:coordinates fromImage:testTableImage];
        [subImage saveAsPNGWithName:[NSString stringWithFormat:@"/Users/tsiebler/Desktop/pkr/images/Zynga/%@.png", coordinateName]];
        [self.processingImageView setImage:subImage];

    }


    //subImage = [testTableImage getSubImageWithRect:NSMakeRect(114, 59, 226, 27)];
 
    
    //NSLog(@"finalDict: %@",coordinatesDict);
    
    // in future, get coordinate of chip and then read this file to get positions relative to chip
    [coordinatesDict writeToFile:@"/Users/tsiebler/Desktop/pkr/images/relativeZyngaDict.plist" atomically:YES];
}
//*/

- (NSRect)getRectForKey:(NSString*)key fromDict:(NSDictionary*)dict{
    NSRect position = NSMakeRect([self getValue:@"x" fromDict:dict forKey:key forType:@"position"],
                                 [self getValue:@"y" fromDict:dict forKey:key forType:@"position"],
                                 [self getValue:@"x" fromDict:dict forKey:key forType:@"size"],
                                 [self getValue:@"y" fromDict:dict forKey:key forType:@"size"]);
    NSLog(@"%@|location: %@",key,NSStringFromPoint(position.origin));
    /*

    CGPoint truePoint = [CVHelper subtractPoint:self.self.coordManager.chipLocation fromParentPoint:position.origin];
    NSLog(@"%@|position relative to self.self.coordManager.chipLocation(%@): %@",key, NSStringFromPoint(self.self.coordManager.chipLocation), NSStringFromPoint(truePoint));
    //    CGPoint originalPoint = [CVHelper addPoint:self.self.coordManager.chipLocation toPoint:truePoint];
    //    NSLog(@"%@|testMath back to original: %@",key, NSStringFromPoint(originalPoint));
    
    NSDictionary *relativePosition = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%f",truePoint.x], @"x",
                                        [NSString stringWithFormat:@"%f",truePoint.y], @"y",
                                        nil];
    NSDictionary *size = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%f",position.size.width], @"x",
                          [NSString stringWithFormat:@"%f",position.size.height], @"y",
                          nil];
    
    NSDictionary *relativeCoordinate = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        relativePosition, @"position",
                                        size, @"size",
                                        nil];
    
    [coordinatesDict setObject:relativeCoordinate forKey:key];
    //*/
    return position;
}
/*
- (NSRect)getRectAndSaveForKey:(NSString*)key fromDict:(NSDictionary*)dict{
    NSRect position = NSMakeRect([self getValue:@"x" fromDict:dict forKey:key forType:@"position"],
                                 [self getValue:@"y" fromDict:dict forKey:key forType:@"position"],
                                 [self getValue:@"x" fromDict:dict forKey:key forType:@"size"],
                                 [self getValue:@"y" fromDict:dict forKey:key forType:@"size"]);
    NSLog(@"%@|location: %@",key,NSStringFromPoint(position.origin));
    
     
     CGPoint truePoint = [CVHelper subtractPoint:self.coordManager.chipLocation.origin fromParentPoint:position.origin];
     NSLog(@"%@|position relative to self.self.coordManager.chipLocation(%@): %@",key, NSStringFromPoint(self.coordManager.chipLocation.origin), NSStringFromPoint(truePoint));
     //    CGPoint originalPoint = [CVHelper addPoint:self.self.coordManager.chipLocation toPoint:truePoint];
     //    NSLog(@"%@|testMath back to original: %@",key, NSStringFromPoint(originalPoint));
     
     NSDictionary *relativePosition = [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSString stringWithFormat:@"%f",truePoint.x], @"x",
     [NSString stringWithFormat:@"%f",truePoint.y], @"y",
     nil];
     NSDictionary *size = [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSString stringWithFormat:@"%f",position.size.width], @"x",
     [NSString stringWithFormat:@"%f",position.size.height], @"y",
     nil];
     
     NSDictionary *relativeCoordinate = [[NSDictionary alloc] initWithObjectsAndKeys:
     relativePosition, @"position",
     size, @"size",
     nil];
     
     [coordinatesDict setObject:relativeCoordinate forKey:key];
    return position;
}//*/
/*
- (NSImage*)getImageForKey:(NSString*)key fromDict:(NSDictionary*)dict fromImage:(NSImage*)testTableImage{
    NSRect position = [self getRectAndSaveForKey:key fromDict:dict];
    NSImage* subImage = [testTableImage getSubImageWithRect:position];
    //self.self.coordManager.chipLocation
    NSLog(@"%@|checksum: %u",key,[subImage getHash]);

    //NSLog(@"test: %f",[self getValue:@"y" fromDict:dict forKey:key forType:@"size"]);
    //[self logCoordinatesForElement:key fromDict:dict];
    return subImage;
}//*/
- (void)logCoordinatesForElement:(NSString*)element fromDict:(NSDictionary*)dict{
    NSDictionary *position = dict[element][@"position"];
    NSDictionary *size = dict[element][@"size"];
    NSLog(@"%@|position: %@",element, position);
    NSLog(@"%@|size: %@",element, size);
}
- (float)getValue:(NSString*)value fromDict:(NSDictionary*)dict forKey:(NSString*)key forType:(NSString*)type{
    return [dict[key][type][value] floatValue];
}
- (void)screenshotTest{

    // get window using owner name. Can also use window title
    ExternalWindow *pokerWindow = [[ExternalWindow alloc] init];
    if(![pokerWindow getWindowWithOwnerName:@"pokerth"]){
        NSLog(@"couldn't get window");
    }else{
        NSLog(@"got window: %@",[pokerWindow windowDict]);
    }
    
    // try making screenshot of window, doesn't have to be in front.
    //NSImage *testImage = [ExternalWindow screenshotFromRect:[pokerWindow getRect] forWindow:[pokerWindow windowID]];
    NSImage *testImage = [pokerWindow screenshot];
    /*
    // table cards
    testImage = [CVHelper drawRect:NSMakeRect(792, 386, 31, 99) onImage:testImage];
    testImage = [CVHelper drawRect:NSMakeRect(902, 386, 31, 99) onImage:testImage];
    testImage = [CVHelper drawRect:NSMakeRect(1012, 386, 31, 99) onImage:testImage];
    testImage = [CVHelper drawRect:NSMakeRect(1122, 386, 31, 99) onImage:testImage];
    testImage = [CVHelper drawRect:NSMakeRect(1232, 386, 31, 99) onImage:testImage];//*/
    [self.mainImageView setImage:testImage];

    
    //[testImage drawRect:NSMakeRect(792, 386, 31, 99)];
    //[testImage drawRect:NSMakeRect(792, 486, 31, 99)];
    //[testImage drawRect:NSMakeRect(892, 486, 31, 99)];
    //[testImage drawRect:NSMakeRect(992, 486, 31, 99)];
    
    //use CV drawing instead, this is slow and coordinates are flipped
    //if too crap, try to use the subImage method and use UIViews in a window to test with
    //
    
    // save to file for own testing
    [testImage saveAsPNGWithName:@"/Users/tsiebler/Desktop/pkr/images/mainScreen.png"];
    //
    [self.mainImageView setImage:testImage];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)imageSplittingLogic{
    // main folder containing all images
    imageStore = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/Chopped/";
    
    /*
     NSSet *set = [NSSet setWithObjects:@"String 1", @"String 2", @"String 3", nil];
     BOOL containsString2 = [set containsObject:@"String 2"];
     */
    
    //NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:[self unknownImagesPath]];
    //NSFileManager* fileManager = [[NSFileManager alloc] init];
    //NSError *error;
    
    //NSArray *unknownImagesArray = [fileManager contentsOfDirectoryAtPath:[self unknownImagesPath] error:&error];
    //unknownImages = [NSSet setWithArray:unknownImagesArray];
    
    //NSArray *knownLogosArray = [fileManager contentsOfDirectoryAtPath:[self knownLogosPath] error:&error];
    //knownLogos = [NSSet setWithArray:knownLogosArray];
    //NSLog(@"knownLogos: %@",knownLogos);
    
    /*
     NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey,
     NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];
     
     NSArray *array = [[NSFileManager defaultManager]
     contentsOfDirectoryAtURL:[NSURL URLWithString:[self knownImagesPath]]
     includingPropertiesForKeys:properties
     options:(NSDirectoryEnumerationSkipsHiddenFiles)
     error:&error];
     
     
     
     NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:[self knownImagesPath]];
     NSString *file = nil;
     NSData *fileContents = [NSData data];
     while ((file = [dirEnum nextObject]))
     {
     NSLog(@"file name: %@",file); // This will give your filename
     // Now for getting file path follow below.
     // here we are adding path to filename.
     NSString *fileNamePath = [[self knownImagesPath] stringByAppendingPathComponent:file];
     //NSLog(@"fileNamePath: %@",fileNamePath); // This will give your filename path
     
     NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fileNamePath error:nil];
     
     
     //        fileContents = [NSData dataWithContentsOfFile:fileNamePath]; // This will store file contents in form of bytes
     
     }//*/
    
    //NSLog(@"unknown images: %@",unknownImagesArray);
    //NSLog(@"unknown images set: %@",unknownImages);
    
    //NSLog(@"known checksum: %hhd",[self isKnownChecksum:@"989531115"]);
    
    /*
     path = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/mainTestImage.png";
     data = [[NSFileManager defaultManager] contentsAtPath:path];
     
     mainImage = [[NSImage alloc] initWithData:data];
     [self.mainImageView setImage:mainImage];
     [self chopImage:mainImage];//*/
}

/*
- (void)chopImage:(NSImage*)image{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        //   NSRect myNewRect
//        myNewRect = NSMakeRect(100, 100, 50, 50);
        
        [self startCount];
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSLog(@"image pixels high: %ld", (long)rep.pixelsHigh);//2400
        NSLog(@"image pixels wide: %ld", (long)rep.pixelsWide);//3840
        
        //CGPoint sliceSize = CGPointMake(50, 50);
        //NSRect sliceSize = NSMakeRect(0, 0, 50, 50);
        NSSize sliceSize = NSMakeSize(50, 50);

        CGPoint cells = CGPointMake(rep.pixelsHigh/sliceSize.height, rep.pixelsWide/sliceSize.width);
        
        NSLog(@"%f many slices fit into image, with each slice at height %f",cells.x -1   ,sliceSize.height);
        NSLog(@"%f many slices fit into image, with each slice at width  %f",cells.y -1  ,sliceSize.width);
        
        NSLog(@"total slices: %f",cells.x * cells.y);
        [self checkTimeTaken];
        
        #define MAX_NUMBER_OF_POINTS 1
        //CGPoint coordinates[MAX_NUMBER_OF_POINTS];
        
        NSLog(@"calculating slices");
        int totalSlices = 0;
        for (int x=0; x<rep.pixelsWide; x+=sliceSize.width) {
            for(int y=0; y<rep.pixelsHigh; y+=sliceSize.height) {
                totalSlices++;//154
            }
        }
        NSLog(@"slices will be: %d",totalSlices);
        [self checkTimeTaken];

        CGPoint coordinates[totalSlices];
        CGImageSourceRef originalImage = NULL;//loadRef
        
        originalImage = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
        
        CGImageRef originalImageRef =  CGImageSourceCreateImageAtIndex(originalImage, 0, NULL);
        CGPoint maxSize = CGPointMake(rep.pixelsWide, rep.pixelsHigh);
        
        int sliceNum = 0;
        for (int x=0; x<rep.pixelsWide; x+=sliceSize.width) {
            for(int y=0; y<rep.pixelsHigh; y+=sliceSize.height) {
                //NSLog(@"x(%d - %f), y(%d - %f), max h(%f) w(%f)", x, x + sliceSize.width, y, y + sliceSize.height,maxSize.x, maxSize.y);
                //2017-03-02 18:17:33.589190 ImageExperiments[43897:12269917] x(50 - 100.000000), y(2400 - 2450.000000), max h(2400) w(3840)

                // y == height
                // x == width
                
                int nextSliceWidth  = sliceSize.width + x;
                int nextSliceHeight = sliceSize.height + y;
                
                int maxSizeWidth    = (int)maxSize.x;
                int maxSizeHeight   = (int)maxSize.y;
                int overflowX = 0;
                int overflowY = 0;
                
                if(nextSliceWidth > maxSizeWidth){
                    overflowX = sliceSize.width + x - maxSize.x;
                    //NSLog(@"warning, attempting outside bounds width! Attempted (%f), max(%f) - trying to readjust with %d",sliceSize.width + x, maxSize.x, overflowX);
                
                    //NSLog(@"readjusted (%f), max(%f)",sliceSize.width + x - overflowX, maxSize.x);
                }
                if(nextSliceHeight > maxSizeHeight){
                    overflowY = sliceSize.height + y - maxSize.y;
                    //NSLog(@"warning, attempting outside bounds height! Attempted (%f), max(%f) - trying to readjust with %d",sliceSize.height + y, maxSize.y, overflowY);
                    
                    //NSLog(@"readjusted (%f), max(%f)",sliceSize.height + y - overflowY, maxSize.y);
                }
                
                // slice image from main image
                CGImageRef croppedCGImage = CGImageCreateWithImageInRect(originalImageRef, CGRectMake(x, y, sliceSize.width - overflowX, sliceSize.height - overflowY));
                if(croppedCGImage == NULL){
                    NSLog(@"failed to crop");
                }
                
                NSImage *croppedNSImage = [[NSImage alloc] initWithCGImage:croppedCGImage size:NSMakeSize(sliceSize.width - overflowX, sliceSize.height - overflowY)];

                NSString *imageChecksum = [self getChecksum:croppedNSImage];
                //NSLog(@"checksum: %@",imageChecksum);

                NSString *type = [self getKnownImageType:imageChecksum];
                if(![type isEqualToString:@"unknown"]){
                    // handle kind of known image - is it a logo that we need the coordinates of, or what? get the coordinates on-screen and store them for later retrievable
                    if([type isEqualToString:@"not yet registered"]){
                        
                    }else{
                        NSLog(@"known image found, with coordinates: x/w(%d), y/h(%d) - %@ - checksum: %@", x, y, type, imageChecksum);
                        //NSLog(@"known");
                    }
                    
                }else{
                    // prepare to save
                    // this is a massive slowdown
                    NSString *savePath = [[self unknownImagesPath] stringByAppendingString:[NSString stringWithFormat:@"%@.png",imageChecksum]];
                    CFURLRef saveUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:[savePath stringByExpandingTildeInPath]];
                    
                    //NSLog(@"prep save path");
                    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(saveUrl, kUTTypePNG, 1, NULL);
                    //NSLog(@"save to file");
                    CGImageDestinationAddImage(destination, croppedCGImage, nil);
                    
                    if (!CGImageDestinationFinalize(destination)) {
                        NSLog(@"Failed to write image to %@", saveUrl);
                    }else{
                        NSLog(@"saved sliced image %d to %@",sliceNum,[NSString stringWithFormat:@"%@.png",imageChecksum]);
                    }
                }
                
                // maybe store these in a file: checksum xcoord ycoord
                // files are saved as checksum.png in chopped images folder
                // at runtime, screenshot of screen is sliced by pixel size, and we look for matching checksums
                coordinates[sliceNum].x = x;
                coordinates[sliceNum].y = y;
                //NSLog(@"slice coordinates x(%f to %f) y(%f to %f)",coordinates[sliceNum].x, coordinates[sliceNum].x + sliceSize.height - overflowY, coordinates[sliceNum].y, coordinates[sliceNum].y + sliceSize.width - overflowX);

                sliceNum++;
                
                //CFRelease(saveUrl);
                CGImageRelease(croppedCGImage);

                //CFRelease(croppedCGImage);
                //CFRelease(destination);
                //NSLog(@"------ next slice ------");

            }
        }
        NSLog(@"reached end of loop");
        //CFRelease(originalImage);
        //CFRelease(originalImageRef);
        //CGImageRelease(originalImageRef);
        
        NSLog(@"got this many parts: %d",sliceNum);
        [self checkTimeTaken];
    });
}*/

- (IBAction)action:(id)sender {
    NSImage *sub;
    
    action++;
    switch(action){
        case 1:
            NSLog(@"action 1");

            //path = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/mainTestImage.png";
            path = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/findButton.png";
            data = [[NSFileManager defaultManager] contentsAtPath:path];
            
            mainImage = [[NSImage alloc] initWithData:data];
            [self.mainImageView setImage:mainImage];
                        
            sub = [mainImage getSubImageWithRect:NSMakeRect(0, 100, 500, 50)];//xpoint, ypoint, width, height
            [self.processingImageView setImage:sub];
            
            break;
            
        case 2:
            NSLog(@"action 2");
            
            //[self chopImage:mainImage];
            

            break;
            
        default:
            NSLog(@"unhandled action %d",action);
            break;
    }
}


- (IBAction)action2:(id)sender {
    path = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/findButton.png";
    data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    mainImage = [[NSImage alloc] initWithData:data];
    [self.mainImageView setImage:mainImage];
    
    NSString *targetButtonPath = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/targetButton3.png";
    NSData *targetButtonData = [[NSFileManager defaultManager] contentsAtPath:targetButtonPath];
    NSImage *targetButtonImage = [[NSImage alloc] initWithData:targetButtonData];

    Mat mainImageMat = [CVHelper cvMatGrayFromNSImage:mainImage];
    Mat subImageMat = [CVHelper cvMatGrayFromNSImage:targetButtonImage];

    [CVHelper displayCVMat:mainImageMat label:"mainImage"];
    [CVHelper displayCVMat:subImageMat label:"target"];

    // perform the match
    vector<cv::Point> foundPointsList;
    vector<double> confidencesList;
    [CVSearchHelper fastFindMatchesOfTarget:subImageMat
                                   inSource:mainImageMat
                            foundPointsList:&foundPointsList
                            confidencesList:&confidencesList
                            matchPercentage:20
                        findMultipleTargets:TRUE
                                  numMaxima:10
                                numDownPyrs:0
                            searchExpansion:15];
    
    [CVSearchHelper drawFoundTargetsOnMat:&mainImageMat size:subImageMat.size() pointsList:foundPointsList confidencesList:confidencesList red:0 green:255 blue:0];
    [CVHelper displayCVMat:mainImageMat label:"matches found"];
}


- (IBAction)findSeats:(id)sender {
    [self startCount];

    path = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/seating.png";
    data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSImage *seatingPlan = [[NSImage alloc] initWithData:data];
    [self.mainImageView setImage:seatingPlan];
    
    [self checkTimeTaken];
    NSString *targetButtonPath = @"/Users/tsiebler/Documents/Projects/Mac/Poker-tool/ImageExperiments/ImageExperiments/Images/sitArrow.png";
    NSData *targetButtonData = [[NSFileManager defaultManager] contentsAtPath:targetButtonPath];
    NSImage *targetButtonImage = [[NSImage alloc] initWithData:targetButtonData];
    
    vector<cv::Point> seats;
    [CVSearchHelper findSeatsInImage:seatingPlan usingTemplate:targetButtonImage result:&seats];
    NSLog(@"found %lu matches", seats.size());

    [self checkTimeTaken];
    
    /*
        idea
     - get location of:
        = seats (done)
        = poker chip on top left
        = space where total money would therefore be (math)
        = D (dealer button - at the end of every round?)
        = to lobby button
        = new table button
        = chat mute button
        = current table blind size (bottom right)(math, using chat mute button?)
        = please take a seat, text
        = check, fold, bet:, check/fold buttons, while player isn't yet seated. Buttons will be here during gameplay.
        = space where game cards would be (math)
        = space where player cards would be (math)(depends on seat).
     
     */
}
















int threshold_value = 0;
int threshold_type = 3;
int const max_value = 255;
int const max_type = 4;
int const max_BINARY_value = 255;
Mat src, src_gray, dst;
const char* window_name = "Threshold Demo";
const char* trackbar_type = "Type: \n 0: Binary \n 1: Binary Inverted \n 2: Truncate \n 3: To Zero \n 4: To Zero Inverted";
const char* trackbar_value = "Value";
void Threshold_Demo( int, void* );
void Threshold_Demo( int, void* )
{
    /* 0: Binary
     1: Binary Inverted
     2: Threshold Truncated
     3: Threshold to Zero
     4: Threshold to Zero Inverted
     */
    NSLog(@"threshold value(%d), maxValue (%d), type (%d)",threshold_value, max_BINARY_value, threshold_type);
    
    threshold( src_gray, dst, threshold_value, max_BINARY_value,threshold_type );
    imshow( window_name, dst );
}
// shows image with sliders to experiment with thresholds
- (IBAction)thresholds:(id)sender {
    NSString *imagePath = @"/Users/tsiebler/Desktop/pkr/images/testImages/misread/wrongTotalChips.png";
    imagePath = @"/Users/tsiebler/Screenies/tableJustSat.png";
    imagePath = @"/Users/tsiebler/Screenies/tableSitting.png";
    imagePath = @"/Users/tsiebler/Screenies/moneys.png";

    /*
     
     
     works well if I just sat down, to read my table chips
     2017-05-04 15:16:52.105291 ImageExperiments[28008:17731943] threshold value(89), maxValue (255), type (3)

     works whne sitting too:
     2017-05-04 15:18:08.977650 ImageExperiments[28083:17734524] threshold value(89), maxValue (255), type (3)

     
     for chips:

        -- white with black text, but fuzzy
     2017-04-23 23:40:21.707094 ImageExperiments[82010:6434204] threshold value(3), maxValue (255), type (0)
     2017-04-23 23:43:26.096589 ImageExperiments[82010:6434204] threshold value(12), maxValue (255), type (0)

     for pots:
        -- white with black text, but fuzzy,
     2017-04-24 18:42:07.476918 ImageExperiments[3617:7322263] threshold value(249), maxValue (255), type (1)

     
     
     */
    NSImage *image = [CVHelper NSImageFromPath:imagePath];
    ///*

     image = [image clearForTableChips];
    
    NSLog(@"mainImage: %@",image);
    [self.mainImageView setImage:image];//*/
    
    //*
    
    src_gray = [CVHelper cvMatGrayFromNSImage:image];
    
    [self checkTimeTaken];
    
    namedWindow( window_name, WINDOW_AUTOSIZE ); // Create a window to display results
    createTrackbar( trackbar_type,
                   window_name, &threshold_type,
                   max_type, Threshold_Demo ); // Create Trackbar to choose type of Threshold
    createTrackbar( trackbar_value,
                   window_name, &threshold_value,
                   max_value, Threshold_Demo ); // Create Trackbar to choose Threshold value
    Threshold_Demo( 0, 0 ); // Call the function to initialize
    for(;;)
    {
        char c = (char)waitKey( 20 );
        if( c == 27 )
        { break; }
    }//*/
    
}

- (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)targetSize
{
    if ([image isValid])
    {
        NSSize imageSize = [image size];
        float width  = imageSize.width;
        float height = imageSize.height;
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        float scaleFactor  = 0.0;
        float scaledWidth  = targetWidth;
        float scaledHeight = targetHeight;
        
        NSPoint thumbnailPoint = NSZeroPoint;
        NSImage *newImage = nil;
        if (!NSEqualSizes(imageSize, targetSize))
        {
            float widthFactor  = targetWidth / width;
            float heightFactor = targetHeight / height;
            
            if (widthFactor < heightFactor)
            {
                scaleFactor = widthFactor;
            }
            else
            {
                scaleFactor = heightFactor;
            }
            
            scaledWidth  = width  * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            }
            
            else if (widthFactor > heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
            
            NSImage *newImage = [[NSImage alloc] initWithSize:targetSize];
            
            [newImage lockFocus];
            
            NSRect thumbnailRect;
            thumbnailRect.origin = thumbnailPoint;
            thumbnailRect.size.width = scaledWidth;
            thumbnailRect.size.height = scaledHeight;
            
            [image drawInRect:thumbnailRect
                     fromRect:NSZeroRect
                    operation:NSCompositingOperationSourceOver
                     fraction:1.0];
            
            [newImage unlockFocus];
        }else{
            NSLog(@"equal sizes thing");
        }
        
        return newImage;
    }else{
        NSLog(@"image not valid");
    }
    return nil;
}

@end

