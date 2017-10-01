//
//  NSEvent+MouseClamped.h
//  ImageExperiments
//
//  Created by Siebler, Tiago on 10/04/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSEvent (MouseClamped)

+ (NSPoint)clampedMouseLocation;
+ (NSPoint)integralMouseLocation;
+ (NSPoint)clampedMouseLocationUsingBackingScaleFactor:(CGFloat)backingScaleFactor;

@end
