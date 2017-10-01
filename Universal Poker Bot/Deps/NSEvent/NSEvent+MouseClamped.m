//
//  NSEvent+MouseClamped.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 10/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//


#import "NSEvent+MouseClamped.h"


@implementation NSEvent (MouseClamped)

+ (NSPoint)clampedMouseLocation
{
    // BUG: http://www.openradar.me/11905408 - nasty hack to make sure mouse location is within screen bounds
    
    NSPoint mouseLocation = [self mouseLocation];
    
    // find the screen that contains the mouse location, or the screen that's closest to the location
    float closestScreenDistance = MAXFLOAT;
    NSUInteger closestScreenIndex = 0;
    BOOL screenFound = NO;
    NSUInteger screenIndex = 0;
    for (NSScreen *screen in [NSScreen screens]) {
        NSRect screenFrame = [screen frame];
        if (NSPointInRect(mouseLocation, screenFrame)) {
            screenFound = YES;
            break;
        }
        float xDistance = 0.0;
        if (mouseLocation.x < NSMinX(screenFrame)) {
            xDistance = NSMinX(screenFrame) - mouseLocation.x;
        }
        else if (mouseLocation.x > NSMaxX(screenFrame)) {
            xDistance = mouseLocation.x - NSMaxX(screenFrame);
        }
        float yDistance = 0.0;
        if (mouseLocation.y < NSMinY(screenFrame)) {
            yDistance = NSMinY(screenFrame) - mouseLocation.y;
        }
        else if (mouseLocation.y > NSMaxY(screenFrame)) {
            yDistance = mouseLocation.y - NSMaxY(screenFrame);
        }
        
        float screenDistance = xDistance + yDistance;
        if (screenDistance < closestScreenDistance) {
            closestScreenDistance = screenDistance;
            closestScreenIndex = screenIndex;
        }
        
        screenIndex += 1;
    }
    
    CGFloat backingScaleFactor = 1.0;
    if (screenFound) {
        // get the scaling factor from the screen that was found
        NSScreen *screen = [[NSScreen screens] objectAtIndex:screenIndex];
        backingScaleFactor = [screen backingScaleFactor];
    }
    else {
        // get the scaling factor from the closest screen
        NSScreen *screen = [[NSScreen screens] objectAtIndex:closestScreenIndex];
        backingScaleFactor = [screen backingScaleFactor];
        
        // clamp the mouse location to bounds of that closest screen
        CGFloat inset = 1.0 / backingScaleFactor;
        NSRect screenFrame = [screen frame];
        if (mouseLocation.x > (NSMaxX(screenFrame) - inset)) {
            mouseLocation.x = (NSMaxX(screenFrame) - inset);
        }
        else if (mouseLocation.x < NSMinX(screenFrame)) {
            mouseLocation.x = NSMinX(screenFrame);
        }
        if (mouseLocation.y > (NSMaxY(screenFrame) - inset)) {
            mouseLocation.y = (NSMaxY(screenFrame) - inset);
        }
        else if (mouseLocation.y < NSMinY(screenFrame)) {
            mouseLocation.y = NSMinY(screenFrame);
        }
    }
    
    // make sure the mouse location falls on a pixel boundary (a full screen point on non-Retina, a half-point on Retina)
    mouseLocation.x = floor(mouseLocation.x * backingScaleFactor) / backingScaleFactor;
    mouseLocation.y = floor(mouseLocation.y * backingScaleFactor) / backingScaleFactor;
    
    return mouseLocation;
}

+ (NSPoint)integralMouseLocation
{
    NSPoint mouseLocation = [self clampedMouseLocation];
    
    mouseLocation.x = floor(mouseLocation.x);
    mouseLocation.y = floor(mouseLocation.y);
    
    return mouseLocation;
}

+ (NSPoint)clampedMouseLocationUsingBackingScaleFactor:(CGFloat)backingScaleFactor
{
    // the mouse location is clamped to the screen where the mouse is located
    NSPoint mouseLocation = [self clampedMouseLocation];
    
    // there are cases where you want to clamp the mouse's location to another scale factor (for example, a window that spans multiple screens)
    mouseLocation.x = floor(mouseLocation.x * backingScaleFactor) / backingScaleFactor;
    mouseLocation.y = floor(mouseLocation.y * backingScaleFactor) / backingScaleFactor;
    
    return mouseLocation;
}

@end
