//
//  CVSearchHelper.m
//  SearchWithImage
//
//  Created by Siebler, Tiago on 28/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "CVSearchHelper.hpp"

#include <algorithm>

//#include <opencv2/imgproc.hpp>

@implementation CVSearchHelper
+ (bool)searchForSingleImage:(NSImage*)subImage
         withinParentImage:(NSImage*)parentImage
              resultPoints:(vector<cv::Point>*)foundPoints
         resultConfidences:(vector<double>*)foundConfidences
                     error:(NSError**)returnedError{
    
    
    
    return false;
}

+ (NSError*)makeErrorForReason:(NSString*)details domain:(NSString*)domain code:(int)code{
    NSMutableDictionary* detailsDict = [NSMutableDictionary dictionary];
    [detailsDict setValue:details forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:detailsDict];
    
    return error;
}

// default method, calls below method with max of 3, and brute forces until a result is found or not found
+ (BOOL)isImage:(NSImage*)subImage
    withinImage:(NSImage*)image
    retLocation:(NSRect*)retLocation
          error:(NSError * __autoreleasing *)outError{
    
    BOOL result = false;
    
    result = [self isImage:subImage
               withinImage:image
               maxDownPyrs:3
               retLocation:retLocation
                     error:outError];
    return result;
    
}

// brute forces shrinking attempts, reducing downPyrs each run until a result is found or no calls are a success
+ (BOOL)isImage:(NSImage*)subImage
    withinImage:(NSImage*)image
    maxDownPyrs:(int)maxDownPyrs
    retLocation:(NSRect*)retLocation
          error:(NSError * __autoreleasing *)outError{
    
    BOOL result = false;
    int searchAlgorithm = CV_TM_CCOEFF_NORMED;//0.067 average 0.047
    //searchAlgorithm = CV_TM_SQDIFF_NORMED;//0.069 average 0.043
    //searchAlgorithm = CV_TM_CCORR_NORMED;//0.068 average 0.046
    
    // <2, 0.282 average 0.194
    // <3, 0.283 average 0.372

    for(int i = maxDownPyrs; i >= 0; i--){
        //NSLog(@"-- looking with down pyrs: %d from max %d",i, maxDownPyrs);
        //NSDate *methodStart = [NSDate date];
        result = [self isImage:subImage
                   withinImage:image
                   numDownPyrs:i
               searchExpansion:15
               searchAlgorithm:searchAlgorithm
                   retLocation:retLocation
                         error:outError];
        
        /*
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"-- searchTook = %f", executionTime);
        //*/
        
        if(result){
            //NSLog(@"found");
            break;
        }
    }
    return result;
    
}

// method allowing complete control over parameters used to templateMatch
+ (BOOL)isImage:(NSImage*)subImage
    withinImage:(NSImage*)image
    numDownPyrs:(int)numDownPyrs
searchExpansion:(int)searchExpansion
searchAlgorithm:(int)searchAlgorithm
    retLocation:(NSRect*)retLocation
          error:(NSError * __autoreleasing *)outError{
    
    // initialise return value
    BOOL success = false;
    // check params needed for this
    if(image == nil){
        NSLog(@"warning, nil image parameter passed!");
        *outError = [self.class makeErrorForReason:@"image is nil" domain:@"PATemplateMatch" code:-1];
        return success;
    }
    if(subImage == nil){
        NSLog(@"warning, nil subimage parameter passed!");
        *outError = [self.class makeErrorForReason:@"subimage is nil" domain:@"PATemplateMatch" code:-1];
        return success;
    }
    
    // get matrix for each image:
    Mat mainImageMat    = [CVHelper cvMatGrayFromNSImage:image];
    Mat originalMat     = [CVHelper cvMatFromNSImage:image];
    
    //NSLog(@"subImage: %@",subImage);
    // we're looking for this template, in the above image
    Mat templateMat     = [CVHelper cvMatGrayFromNSImage:subImage];
    
    // apply white thresholds to increase recognition ease
    mainImageMat        = [CVHelper applyThresholdClearWhite:mainImageMat];
    templateMat         = [CVHelper applyThresholdClearWhite:templateMat];
    
    // debug methods to display what's currently being processed
    //[CVHelper displayCVMat:mainImageMat label:"mainImageMat"];
    //[CVHelper displayCVMat:templateMat label:"templateMat"];
    
    // perform the match
    vector<double> confidencesList;
    vector<cv::Point> foundPointsList;
    [self.class fastFindMatchesOfTarget:templateMat
                               inSource:mainImageMat
                        foundPointsList:&foundPointsList
                        confidencesList:&confidencesList
                        matchPercentage:80
                    findMultipleTargets:FALSE
                              numMaxima:1
                            numDownPyrs:numDownPyrs
                        searchExpansion:searchExpansion
                    withSearchAlgorithm:searchAlgorithm];
    
    //[self.class DrawFoundTargets:&originalMat size:templateMat.size() pointsList:foundPointsList confidencesList:confidencesList red:0 green:255 blue:0];
    //[CVHelper displayCVMat:originalMat label:"seats found"];
    
    // get centre point of result
    const cv::Point& point = (foundPointsList)[0];
    
    //NSLog(@"size: %lu",foundPointsList.size());
    if(foundPointsList.size() == 0){
        //NSLog(@"image not found");
        *outError = [self.class makeErrorForReason:@"unable to find image within sub image with required confidence" domain:@"PATemplateMatch" code:-1];
        return success;
    }
    
    // get top left corner, and the size of the original template
    *retLocation = NSMakeRect(point.x - templateMat.size().width / 2,
                              point.y - templateMat.size().height / 2,
                              templateMat.size().width,
                              templateMat.size().height);
    success = true;
    
    return success;
}

/*
 This attempts to search first for matches after shrinking both images, to speed up the search.
 Next it takes the inaccurate results from the shrunken area to narrow down the search to more specific regions in the larger, original image. This means the search can be sped up rather than searching a bigger image in one go.
    - numDownPyrs is how much we shrink the image
    - searchExpansion dictates how close two matches might be to one another. If multiple targets are further away, the search expansion value should be increased to speed up the search logic
    - the search is done with a matchTemplate call. This takes a hardcoded CV_TM_CCOEFF_NORMED value as the search types, other methods are available and can bring different results. These should definitely be tried for speed
 
 */
+(bool)fastFindMatchesOfTarget:(const cv::Mat&)       target
                      inSource:(const cv::Mat&)       source
               foundPointsList:(vector<cv::Point>*)   foundPointsList
               confidencesList:(vector<double>*)      confidencesList
               matchPercentage:(int)                  matchPercentage
           findMultipleTargets:(bool)                 findMultipleTargets
                     numMaxima:(int)                  maxResults
                   numDownPyrs:(int)                  numDownPyrs
               searchExpansion:(int)                  searchExpansion
{
    return [self fastFindMatchesOfTarget:target
                                inSource:source
            
                         foundPointsList:foundPointsList
                         confidencesList:confidencesList
            
                         matchPercentage:matchPercentage
            
                     findMultipleTargets:findMultipleTargets
                               numMaxima:maxResults
            
                             numDownPyrs:numDownPyrs
                         searchExpansion:searchExpansion
            
                     withSearchAlgorithm:CV_TM_CCOEFF_NORMED];
}

+(bool)fastFindMatchesOfTarget:(const cv::Mat&)       target
                      inSource:(const cv::Mat&)       source
               foundPointsList:(vector<cv::Point>*)   foundPointsList
               confidencesList:(vector<double>*)      confidencesList
               matchPercentage:(int)                  matchPercentage
           findMultipleTargets:(bool)                 findMultipleTargets
                     numMaxima:(int)                  maxResults
                   numDownPyrs:(int)                  numDownPyrs//how much to shrink image, the lower the faster but the higher the error margin
               searchExpansion:(int)                  searchExpansion
           withSearchAlgorithm:(int)                  searchAlgorithm __attribute__((deprecated("add NSError to this")))
{
    /*
     NSLog(@"%s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, @"msg");
*/
    // some sanity checks before anything else
    if(source.empty()){
        NSLog(@"%s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, @"Source Matrix is empty() - returning");
        return false;
    }
    if(target.empty()){
        NSLog(@"%s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, @"Target Matrix is empty() - returning");
        return false;
    }
    
    // make sure that the template image is smaller than the source
    if(target.size().width > source.size().width ||
       target.size().height > source.size().height)
    {
        NSLog(@"%s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, @"Source image must be larger than target image.");
        return false;
    }
    
    if(source.depth() != target.depth())
    {
        NSLog(@"%s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, @"Source image and target image must have same depth.");
        return false;
    }
    
    if(source.channels() != target.channels())
    {
        NSLog(@"%s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, @"Source image and target image must have same number of channels.");
        return false;
    }
    
    cv::Size sourceSize = source.size();
    cv::Size targetSize = target.size();
    
    // create copies of the images to modify
    cv::Mat copyOfSource = source.clone();
    cv::Mat copyOfTarget = target.clone();
    
    // down pyramid the images - smaller images are easier to match faster
    for(int ii = 0; ii < numDownPyrs; ii++)
    {
        // start with the source image
        sourceSize.width  = (sourceSize.width  + 1) / 2;
        sourceSize.height = (sourceSize.height + 1) / 2;
        
        cv::Mat smallSource(sourceSize, source.type());
        pyrDown(copyOfSource, smallSource);
        
        // prepare for next loop, if any
        copyOfSource = smallSource.clone();
        
        // next, do the target
        targetSize.width  = (targetSize.width  + 1) / 2;
        targetSize.height = (targetSize.height + 1) / 2;
        
        cv::Mat smallTarget(targetSize, target.type());
        pyrDown(copyOfTarget, smallTarget);
        
        // prepare for next loop, if any
        copyOfTarget = smallTarget.clone();
    }
    
    // perform the match on the shrunken images
    cv::Size smallTargetSize = copyOfTarget.size();
    cv::Size smallSourceSize = copyOfSource.size();
    
    cv::Size resultSize;
    resultSize.width = smallSourceSize.width - smallTargetSize.width + 1;
    resultSize.height = smallSourceSize.height - smallTargetSize.height + 1;
    
    cv::Mat result(resultSize, CV_32FC1);
    matchTemplate(copyOfSource, copyOfTarget, result, searchAlgorithm);
    
    // find the top match locations
    cv::Point* locations = NULL;
    [self findTopMatchLocationsFromResultMat:result toLocations:&locations maxResults:maxResults];
    
    // search the large images at the returned locations
    sourceSize = source.size();
    targetSize = target.size();
    
    // create a copy of the source in order to adjust its ROI for searching
    for(int currMax = 0; currMax < maxResults; currMax++)
    {
        // transform the point to its corresponding point in the larger image
        locations[currMax].x *= (int)pow(2.0f, numDownPyrs);
        locations[currMax].y *= (int)pow(2.0f, numDownPyrs);
        locations[currMax].x += targetSize.width / 2;
        locations[currMax].y += targetSize.height / 2;
        
        const cv::Point& searchPoint = locations[currMax];
        
        // if we are searching for multiple targets and we have found a target or
        //  multiple targets, we don't want to search in the same location(s) again
        if(findMultipleTargets && !foundPointsList->empty())
        {
            bool thisTargetFound = false;
            
            unsigned long numPoints = foundPointsList->size();
            for(int currPoint = 0; currPoint < numPoints; currPoint++)
            {
                const cv::Point& foundPoint = (*foundPointsList)[currPoint];
                if(abs(searchPoint.x - foundPoint.x) <= searchExpansion * 2 &&
                   abs(searchPoint.y - foundPoint.y) <= searchExpansion * 2)
                {
                    thisTargetFound = true;
                    break;
                }
            }
            
            // if the current target has been found, continue onto the next point
            if(thisTargetFound)
            {
                continue;
            }
        }
        
        // set the source image's ROI to slightly larger than the target image,
        //  centred at the current point
        cv::Rect searchRoi;
        searchRoi.x = searchPoint.x - (target.size().width) / 2 - searchExpansion;
        searchRoi.y = searchPoint.y - (target.size().height) / 2 - searchExpansion;
        searchRoi.width = target.size().width + searchExpansion * 2;
        searchRoi.height = target.size().height + searchExpansion * 2;
        
        // make sure ROI doesn't extend outside of image
        if(searchRoi.x < 0)
        {
            searchRoi.x = 0;
        }
        
        if(searchRoi.y < 0)
        {
            searchRoi.y = 0;
        }
        
        if((searchRoi.x + searchRoi.width) > (sourceSize.width - 1))
        {
            int numPixelsOver
            = (searchRoi.x + searchRoi.width) - (sourceSize.width - 1);
            
            searchRoi.width -= numPixelsOver;
        }
        
        if((searchRoi.y + searchRoi.height) > (sourceSize.height - 1))
        {
            int numPixelsOver
            = (searchRoi.y + searchRoi.height) - (sourceSize.height - 1);
            
            searchRoi.height -= numPixelsOver;
        }
        
        cv::Mat searchImage = cv::Mat(source, searchRoi);
        
        // perform the search on the large images
        resultSize.width = searchRoi.width - target.size().width + 1;
        resultSize.height = searchRoi.height - target.size().height + 1;
        
        result = cv::Mat(resultSize, CV_32FC1);
        matchTemplate(searchImage, target, result, searchAlgorithm);
        
        // find the best match location
        double minValue, maxValue;
        cv::Point minLoc, maxLoc;
        minMaxLoc(result, &minValue, &maxValue, &minLoc, &maxLoc);
        maxValue *= 100;
        
        // transform point back to original image
        maxLoc.x += searchRoi.x + target.size().width / 2;
        maxLoc.y += searchRoi.y + target.size().height / 2;
        
        if(maxValue >= matchPercentage)
        {
            // add the point to the list
            foundPointsList->push_back(maxLoc);
            confidencesList->push_back(maxValue);
            
            // if we are only looking for a single target, we have found it, so we
            //  can return
            if(!findMultipleTargets)
            {
                break;
            }
        }
    }
    
    if(foundPointsList->empty())
    {
        //NSLog(@"%s %d %s %s %@ %d", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__, @"Target was not found to required confidence of ",matchPercentage);
        return false;
    }
    
    delete [] locations;
    return true;
}
+(void) findTopMatchLocationsFromResultMat:(const cv::Mat&)image toLocations:(cv::Point**)locations maxResults:(int)numMaxima
{
    // initialize input variable locations
    *locations = new cv::Point[numMaxima];
    
    // create array for tracking maxima
    float* maxima = new float[numMaxima];
    for(int i = 0; i < numMaxima; i++)
    {
        maxima[i] = 0.0;
    }
    
    cv::Size size = image.size();
    
    // extract the raw data for analysis
    for(int y = 0; y < size.height; y++)
    {
        for(int x = 0; x < size.width; x++)
        {
            float data = image.at<float>(y, x);
            
            // insert the data value into the array if it is greater than any of the
            //  other array values, and bump the other values below it, down
            for(int j = 0; j < numMaxima; j++)
            {
                // require at least 50% confidence on the sub-sampled image
                // in order to make this as fast as possible
                if(data > 0.5 && data > maxima[j])
                {
                    // move the maxima down
                    for(int k = numMaxima - 1; k > j; k--)
                    {
                        maxima[k] = maxima[k-1];
                        (*locations)[k] = ( *locations )[k-1];
                    }
                    
                    // insert the value
                    maxima[j] = data;
                    (*locations)[j].x = x;
                    (*locations)[j].y = y;
                    break;
                }
            }
        }
    }
    
    delete [] maxima;
}

+(void)drawFoundTargetsOnMat:(cv::Mat*)image
                        size:(const cv::Size&)size
                  pointsList:(const vector<cv::Point>&)pointsList
             confidencesList:(const vector<double>&)confidencesList
                         red:(int)red
                       green:(int)green
                        blue:(int)blue
{
    unsigned long numPoints = pointsList.size();
    for(int currPoint = 0; currPoint < numPoints; currPoint++)
    {
        const cv::Point& point = pointsList[currPoint];
        
        // write the confidences to stdout
        printf("\nTarget found at (%d, %d), with confidence = %3.3f %%.\n",point.x,point.y,confidencesList[currPoint]);
        
        // draw a circle at the center
        circle(*image, point, 2, CV_RGB(red, green, blue), 2);
        
        int font = cv::FONT_HERSHEY_SIMPLEX;
        putText(*image,to_string(currPoint + 1),point, font, 2,CV_RGB(red, green, blue),2,CV_AA);
        
        // draw a rectangle around the found target
        cv::Point topLeft;
        topLeft.x = point.x - size.width / 2;
        topLeft.y = point.y - size.height / 2;
        
        cv::Point bottomRight;
        bottomRight.x = point.x + size.width / 2;
        bottomRight.y = point.y + size.height / 2;
        //NSRect rect = NSMakeRect(point.x, point.y, size.width, size.height);
        
        rectangle(*image, topLeft, bottomRight, CV_RGB(red, green, blue), 2);
        
        // [mainDelegate collectPositionCoordinates:NSMakePoint(rect.origin.x, rect.origin.y) total:numPoints];
    }
}


// poker specific:
// find seats
+ (void)findSeatsInImage:(NSImage*)tableImage usingTemplate:(NSImage*)templateImage result:(vector<cv::Point>*)foundPointsList{
    Mat tableMat        = [CVHelper cvMatGrayFromNSImage:tableImage];
    Mat originalMat     = [CVHelper cvMatFromNSImage:tableImage];
    
    // we're looking for this template, in the above image
    Mat templateMat     = [CVHelper cvMatGrayFromNSImage:templateImage];
    
    // apply white thresholds to increase recognition ease
    tableMat            = [CVHelper applyThresholdClearWhite:tableMat];
    templateMat         = [CVHelper applyThresholdClearWhite:templateMat];
    
    // debug methods to display what's currently being processed
    [CVHelper displayCVMat:tableMat label:"tableMat"];
    [CVHelper displayCVMat:templateMat label:"templateMat"];
    
    // perform the match
    vector<double> confidencesList;
    [self.class fastFindMatchesOfTarget:templateMat
                               inSource:tableMat
                        foundPointsList:foundPointsList
                        confidencesList:&confidencesList
                        matchPercentage:80
                    findMultipleTargets:TRUE
                              numMaxima:10
                            numDownPyrs:0
                        searchExpansion:15];
    
    // arrange seats around table so we have an ordered list
    [CVHelper arrangeSeats:foundPointsList];
    
    [CVSearchHelper drawFoundTargetsOnMat:&originalMat size:templateMat.size() pointsList:*foundPointsList confidencesList:confidencesList red:0 green:255 blue:0];
    [CVHelper displayCVMat:originalMat label:"seats found"];
    
    // at this stage we can process each point for whichever logic - the search is finished
}

@end
