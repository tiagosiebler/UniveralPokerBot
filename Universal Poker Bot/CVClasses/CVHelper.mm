//
//  CVHelperMethods.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 04/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "CVHelper.hpp"

@implementation CVHelper

//Convert NSImage to cvMat
+ (Mat)cvMatFromNSImage:(NSImage *)image
{
    //The following command doesn't work with monochrome images, let's find a way to fix that!!!
    //CGColorSpaceRef colorSpace = CGImageGetColorSpace([image CGImageForProposedRect:NULL context:NULL hints:NULL]);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    //
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), [image CGImageForProposedRect:NULL context:NULL hints:NULL]);
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    return cvMat;
}
//Convert NSImage to cvMat
+ (Mat)cvMatGrayFromNSImage:(NSImage *)image
{
    //The following command doesn't work with monochrome images, let's find a way to fix that!!!
    //CGColorSpaceRef colorSpace = CGImageGetColorSpace([image CGImageForProposedRect:NULL context:NULL hints:NULL]);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), [image CGImageForProposedRect:NULL context:NULL hints:NULL]);
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // make grey
    //cvtColor(cvMat, cvMat, COLOR_BGR2GRAY);
    //COLOR_BGR2RGB table_screen_based pokerbot mac
    
    return [self.class convertToGray:cvMat];
}
+ (Mat)convertToGray:(cv::Mat)rgbMat
{
    Mat grayMat;
    cvtColor(rgbMat, grayMat, COLOR_BGR2GRAY);
    
    return grayMat;
}
+ (NSImage*)greyScaleImage:(NSImage*)image{
    Mat tempMat = [self.class cvMatGrayFromNSImage:image];
    
    return [self.class NSImageFromCVMat:[self.class applyThresholdClearWhite:tempMat]];
}

+ (NSImage *)NSImageFromCVMat:(Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
    [image setCacheMode:NSImageCacheNever];

    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}
+ (NSImage*)NSImageFromPath:(NSString*)path{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile: path];
    [image setCacheMode:NSImageCacheNever];

    // we need the real deal, not size in points but pixels, so get that from the image rep.
    NSImageRep *rep = [[image representations] objectAtIndex:0];
    //NSLog(@"image pixels high: %ld", (long)rep.pixelsHigh);//2400
    //NSLog(@"image pixels wide: %ld", (long)rep.pixelsWide);//3840
    
    // readjust image size based on this
    image.size = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    return image;
}
+ (NSImage*)NSImageFromBundle:(NSString*)imageName{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    NSImage *retImage = [self.class NSImageFromPath:imagePath];
    //NSLog(@"NSImageFromBundle: image%@", retImage);

    return retImage;
}


+ (void)displayCVMat:(Mat)mat label:(const char*)name{
    imshow(name, mat);
}

// image processing
+ (Mat)applyThresholdClearWhite:(Mat)mat{
    //cvtColor( mat, mat, COLOR_BGR2GRAY ); // Convert the image to Gray
    int threshold_value     = 102;
    int max_BINARY_value    = 255;
    int threshold_type      = 1;
    
    threshold( mat, mat, threshold_value, max_BINARY_value,threshold_type );
    return mat;
}

+ (Mat)applyThresholdClearBlack:(Mat)mat{
    //cvtColor( mat, mat, COLOR_BGR2GRAY ); // Convert the image to Gray
    int threshold_value     = 117;
    int max_BINARY_value    = 255;
    int threshold_type      = 3;
    
    threshold( mat, mat, threshold_value, max_BINARY_value,threshold_type );
    return mat;
}
+ (Mat)applyBlindsThreshold:(Mat)mat{
    int threshold_value     = 4;
    int max_BINARY_value    = 255;
    int threshold_type      = 0;
    
    threshold( mat, mat, threshold_value, max_BINARY_value,threshold_type );
    return mat;
}
+ (Mat)applyPotsThreshold:(Mat)mat{
    int threshold_value     = 249;
    int max_BINARY_value    = 255;
    int threshold_type      = 1;
    
    threshold( mat, mat, threshold_value, max_BINARY_value,threshold_type );
    return mat;
}

+ (NSImage*)applyBlindsThresholdImage:(NSImage*)image{
    Mat tempMat = [self.class cvMatGrayFromNSImage:image];
    
    return [self.class NSImageFromCVMat:[self.class applyBlindsThreshold:tempMat]];
}
+ (NSImage*)applyPotsThresholdImage:(NSImage*)image{
    Mat tempMat = [self.class cvMatGrayFromNSImage:image];
    
    return [self.class NSImageFromCVMat:[self.class applyPotsThreshold:tempMat]];
}
+ (NSImage*)applyTableChipsThresholdImage:(NSImage*)image{
    Mat tempMat = [self.class cvMatGrayFromNSImage:image];
    
    int threshold_value     = 89;
    int max_BINARY_value    = 255;
    int threshold_type      = 3;
    
    threshold( tempMat, tempMat, threshold_value, max_BINARY_value,threshold_type );
    
    return [self.class NSImageFromCVMat:tempMat];
}


+ (Mat)binaryImage:(Mat)mat{
    adaptiveThreshold(~mat, mat, 255, CV_ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY, 15, -2);
    return mat;
}

+ (NSImage*)drawRect:(NSRect)rect onImage:(NSImage*)image{
    Mat imageMat = [CVHelper cvMatFromNSImage:image];
    
    cv::Rect theRect;
    theRect.x = rect.origin.x;
    theRect.y = rect.origin.y;
    theRect.width = rect.size.width;
    theRect.height = rect.size.height;
    
    rectangle(imageMat, theRect, CV_RGB(0, 255, 0), 4);
    
    return [CVHelper NSImageFromCVMat:imageMat];
    /*
     CV_EXPORTS void rectangle(CV_IN_OUT Mat& img, Rect rec,
     const Scalar& color, int thickness = 1,
     int lineType = LINE_8, int shift = 0);
     */
    //imshow("drawRectTest", imageMat);
    
    //    //        rectangle(*image, topLeft, bottomRight, CV_RGB(red, green, blue), 2);
    
    //rectangle(<#cv::Mat &img#>, <#Rect rec#>, <#const Scalar &color#>)
    //rectangle(imageMat, topLeft, bottomRight, CV_RGB(red, green, blue), 2);
    //return nil;
}


// points sorting
struct sortByYAxisAscending {
    bool operator() (cv::Point pt1, cv::Point pt2) { return (pt1.y < pt2.y);}
} sortByYAxisAscending;

struct sortByYAxisDescending {
    bool operator() (cv::Point pt1, cv::Point pt2) { return (pt1.y < pt2.y);}
} sortByYAxisDescending;

+ (void)sortByYAxis:(vector<cv::Point>*)pointsList{
    std::sort(pointsList->begin(), pointsList->end(), sortByYAxisAscending);
}

struct sortByXAxisNegative {
    bool operator() (cv::Point pt1, cv::Point pt2) { return (pt1.x > pt2.x);}
} sortByXAxisNegative;
+ (void)sortByXAxisNegative:(vector<cv::Point>*)pointsList{
    std::sort(pointsList->begin(), pointsList->end(), sortByXAxisNegative);
}
struct sortByXAxisPositive {
    bool operator() (cv::Point pt1, cv::Point pt2) { return (pt1.x < pt2.x);}
} sortByXAxisPositive;
+ (void)sortByXAxisPositive:(vector<cv::Point>*)pointsList{
    std::sort(pointsList->begin(), pointsList->end(), sortByXAxisPositive);
}
bool sortByYNegative(const cv::Point& lhs, const cv::Point& rhs)
{
    return lhs.y < rhs.y;
}

+ (void)loopPoints:(vector<cv::Point>)pointsList{
    for(int currPoint = 0; currPoint < pointsList.size(); currPoint++){
        const cv::Point& point = (pointsList)[currPoint];
        NSLog(@"point %d is at x(%d) y(%d)",currPoint,point.x,point.y);
    }
}

+ (void)arrangeSeats:(vector<cv::Point>*)pointsList{
    auto mmx = std::minmax_element(pointsList->begin(), pointsList->end(), sortByYNegative);
    int min_y = mmx.first->y;
    int max_y = mmx.second->y;
    int verticalRange = max_y - min_y;
    
    //NSLog(@"min: %d",min_y);//127
    //NSLog(@"max: %d",max_y);//377
    //NSLog(@"vertical range: %d",verticalRange);//250
    
    // loop through, and separate depending on whether y coordinate is > verticalRange/2.
    vector<cv::Point> topHalf;
    vector<cv::Point> bottomHalf;
    
    for(int currPoint = 0; currPoint < pointsList->size(); currPoint++)
    {
        const cv::Point& point = (*pointsList)[currPoint];
        if(point.y < verticalRange){
            topHalf.push_back(point);
            //NSLog(@"top half: x(%d) y(%d) - vertMid(%d)",point.x, point.y, verticalRange);
        }else{
            bottomHalf.push_back(point);
            //NSLog(@"bottom half: x(%d) y(%d) - vertMid(%d)",point.x, point.y, verticalRange);
        }
    }
    
    // sort top half by x axis ascending (left to right)
    std::sort(topHalf.begin(), topHalf.end(), sortByXAxisPositive);
    
    // sort bottom half by x axis descending (right to left)
    std::sort(bottomHalf.begin(), bottomHalf.end(), sortByXAxisNegative);
    
    //NSLog(@"top half: ");
    //[CVHelper loopPoints:topHalf];
    //NSLog(@"bottom half: ");
    //[CVHelper loopPoints:bottomHalf];
    
    // clear original list
    pointsList->clear();
    
    // add ordered top then bottom half to original list
    for(int currPoint = 0; currPoint < topHalf.size(); currPoint++){
        const cv::Point& point = topHalf[currPoint];
        pointsList->push_back(point);
    }
    for(int currPoint = 0; currPoint < bottomHalf.size(); currPoint++){
        const cv::Point& point = bottomHalf[currPoint];
        pointsList->push_back(point);
    }
}

+ (CGPoint)subtractPoint:(CGPoint)child fromParentPoint:(CGPoint)parent{
    CGPoint retPoint = CGPointMake(parent.x - child.x, parent.y - child.y);
    return retPoint;
}
+ (CGPoint)addPoint:(CGPoint)child toPoint:(CGPoint)parent{
    CGPoint retPoint = CGPointMake(parent.x + child.x, parent.y + child.y);
    return retPoint;
}
+ (BOOL)point:(CGPoint)pointa isEqualToPoint:(CGPoint)pointb{
    return (pointa.x == pointb.x && pointa.y == pointb.y);
}
@end
