//
//  CVSearchHelper.h
//  SearchWithImage
//
//  Created by Siebler, Tiago on 28/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "CVHelper.hpp"
#import <Foundation/Foundation.h>

@interface CVSearchHelper : NSObject
+ (NSError*)makeErrorForReason:(NSString*)details domain:(NSString*)domain code:(int)code;

+ (bool)searchForSingleImage:(NSImage*)subImage
           withinParentImage:(NSImage*)parentImage
                resultPoints:(vector<cv::Point>*)foundPoints
           resultConfidences:(vector<double>*)foundConfidences
                       error:(NSError**)returnedError;

/*=============================================================================
 Optimized single-match versions of the fastFindMatchesOfTargets
 Returns: true on success, false on failure
 
 */
+ (BOOL)isImage:(NSImage*)subImage
    withinImage:(NSImage*)image
    retLocation:(NSRect*)retLocation
          error:(NSError * __autoreleasing *)outError;

+ (BOOL)isImage:(NSImage*)subImage
    withinImage:(NSImage*)image
    maxDownPyrs:(int)maxDownPyrs
    retLocation:(NSRect*)retLocation
          error:(NSError * __autoreleasing *)outError;

+ (BOOL)isImage:(NSImage*)subImage
    withinImage:(NSImage*)image
    numDownPyrs:(int)numDownPyrs
searchExpansion:(int)searchExpansion
searchAlgorithm:(int)searchAlgorithm
    retLocation:(NSRect*)retLocation
          error:(NSError * __autoreleasing *)outError;

/*=============================================================================
 fastFindMatchesOfTarget
 Performs a fast match template, returning multiple results. Used by the above single-image methods
 Returns: true on success, false on failure
 Parameters:
    source - source image (where we are searching)
    target - target image (what we are searching for)
    foundPointsList - contains a list of the points where the target was found
    confidencesList - contains a list of the confidence value (0-100) for each
    found target
    matchPercentage - the minimum required match score to consider the target found
    findMultipleTargets - if set to true, the function will attempt to find a
    maximum of numMaxima targets
    numMaxima - the maximum number of search locations to try before exiting (i.e. when image is down-sampled and searched, we collect the best numMaxima locations - those with the highest confidence - and search the original image at these locations)
    numDownPyrs - the number of times to down-sample the image (only increase this number if your images are really large) searchExpansion - The original source image is searched at the top locations with +/- searchExpansion pixels in both the x and y directions
 */
+(bool)fastFindMatchesOfTarget:(const cv::Mat&)       target
                      inSource:(const cv::Mat&)       source
               foundPointsList:(vector<cv::Point>*)   foundPointsList
               confidencesList:(vector<double>*)      confidencesList
               matchPercentage:(int)                  matchPercentage
           findMultipleTargets:(bool)                 findMultipleTargets
                     numMaxima:(int)                  maxResults
                   numDownPyrs:(int)                  numDownPyrs
               searchExpansion:(int)                  searchExpansion;

+(bool)fastFindMatchesOfTarget:(const cv::Mat&)       target
                      inSource:(const cv::Mat&)       source
               foundPointsList:(vector<cv::Point>*)   foundPointsList
               confidencesList:(vector<double>*)      confidencesList
               matchPercentage:(int)                  matchPercentage
           findMultipleTargets:(bool)                 findMultipleTargets
                     numMaxima:(int)                  maxResults
                   numDownPyrs:(int)                  numDownPyrs//how much to shrink image, the lower the faster but the higher the error margin
               searchExpansion:(int)                  searchExpansion
           withSearchAlgorithm:(int)                  searchAlgorithm;

/*=============================================================================
 DrawFoundTargets
 Draws a rectangle of dimension size, at the given positions in the list,
 in the given RGB color space
 Parameters:
    image - a color image to draw on
    size - the size of the rectangle to draw
    pointsList - a list of points where a rectangle should be drawn
    confidencesList - a list of the confidences associated with the points
    red - the red value (0-255)
    green - the green value (0-255)
    blue - the blue value (0-255)
 */
+(void)drawFoundTargetsOnMat:(cv::Mat*)image
                        size:(const cv::Size&)size
                  pointsList:(const vector<cv::Point>&)pointsList
             confidencesList:(const vector<double>&)confidencesList
                         red:(int)red
                       green:(int)green
                        blue:(int)blue;

// recognition
/*=============================================================================
 findSeatsInImage
 Uses a template to find all occurances of that template in an image (max 10). Results in an ordered clockwise list of coordinates/seats.
 Parameters:
 tableImage - screenshot of the current table
 templateImage - screenshot of something that identifies an open seat on above table
 result - output vector containing ordered list of points, clockwise, with top left being first point in list.
 
 */
+ (void)findSeatsInImage:(NSImage*)tableImage usingTemplate:(NSImage*)templateImage result:(vector<cv::Point>*)foundPointsList __attribute__((deprecated("need to move this into a Poker-specific class, as the rest of this isn't poker specific and just image recognition.")));



@end
