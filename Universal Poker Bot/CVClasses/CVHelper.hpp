//
//  CVHelperMethods.hpp
//  ImageExperiments
//
//  Created by Siebler, Tiago on 04/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Foundation/Foundation.h>

using namespace std;
using namespace cv;

@interface CVHelper : NSObject

// load CVMat through NSImage instance
+ (Mat)cvMatFromNSImage:(NSImage *)image;
+ (Mat)cvMatGrayFromNSImage:(NSImage *)image;// processed for 1 channel, with COLOR_BGR2GRAY applied
+ (Mat)convertToGray:(cv::Mat)rgbMat;

// Getting NSImages
+ (NSImage*)NSImageFromCVMat:(Mat)cvMat;
+ (NSImage*)NSImageFromPath:(NSString*)path;
+ (NSImage*)NSImageFromBundle:(NSString*)imageName;
+ (NSImage*)greyScaleImage:(NSImage*)image;
+ (NSImage*)applyBlindsThresholdImage:(NSImage*)image;
+ (NSImage*)applyPotsThresholdImage:(NSImage*)image;
+ (NSImage*)applyTableChipsThresholdImage:(NSImage*)image;

// show mat in window
+ (void)displayCVMat:(Mat)mat label:(const char*)name;

// draw box on image, using OpenCV
+ (NSImage*)drawRect:(NSRect)rect onImage:(NSImage*)image;

// applies a threshold that makes things a heavy white, bringing clarity through contrast
+ (Mat)applyThresholdClearWhite:(Mat)mat;
+ (Mat)applyThresholdClearBlack:(Mat)mat;


+ (Mat)binaryImage:(Mat)mat;

// sorting
// arranges seating order clockwise
+ (void)arrangeSeats:(vector<cv::Point>*)pointsList;

// helper methods for sorting points
+ (void)sortByYAxis:(vector<cv::Point>*)pointsList;
+ (void)sortByXAxisNegative:(vector<cv::Point>*)pointsList;
+ (void)sortByXAxisPositive:(vector<cv::Point>*)pointsList;

// searching

// debugging
+ (void)loopPoints:(vector<cv::Point>)pointsList;

// math
// difference between two points, to offset when origin is a part of image rather than top left corner of window. We need a reference point
+ (CGPoint)subtractPoint:(CGPoint)child fromParentPoint:(CGPoint)parent;
+ (CGPoint)addPoint:(CGPoint)child toPoint:(CGPoint)parent;
+ (BOOL)point:(CGPoint)pointa isEqualToPoint:(CGPoint)pointb;

@end
