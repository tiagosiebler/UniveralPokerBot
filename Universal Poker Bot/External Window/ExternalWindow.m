//
//  WindowHelper.m
//  ImageExperiments
//
//  Created by Siebler, Tiago on 06/03/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "ExternalWindow.h"
#import <Cocoa/Cocoa.h>
#import "NSScreen+PointConversion.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Carbon/Carbon.h>


@implementation ExternalWindow
NSRunningApplication *myApp;
NSScreen *screen;

static BOOL isClickQueued = false;
static NSPoint clickLocation;
static CGPoint previousMousePosition;
static NSRunningApplication *activeApp;
static int queuedPid = 0;
static int previousPid = 0;
static NSDictionary *previousWindow;

- (id)init{
    if (self = [super init]) {
        // initialization here
        self.haveWindow = false;
        
        /*
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(activeAppDidChange:)
                                                                   name:NSWorkspaceDidActivateApplicationNotification
                                                                 object:[NSWorkspace sharedWorkspace]];//*/
    }
    return self;
}
- (void)activeAppDidChange:(NSNotification*)notification{
    //NSLog(@"notification: %@",notification);
    //NSLog(@"activeAppDidChange userinfo: %@", [notification userInfo]);
    
//    NSWorkspace *ws = [notification object];
    //NSLog(@"active app changed to: %@",ws.frontmostApplication);
    
    [self checkForQueuedClick];
    //dbgLogC("active app changed to: %s",[ws.frontmostApplication.localizedName UTF8String]);
    
}
- (NSDictionary*)getCurrentActiveWindow{
    NSArray *windows = [self.class getWindowList];
    NSDictionary *resultWindow = nil;
    
    for (NSDictionary *window in windows) {
        if(window[(__bridge NSString *)kCGWindowIsOnscreen]){
            //NSLog(@"window: %@",window);
            resultWindow = window;
            break;
        }
    }
    
    //NSLog(@"windows: %@",windows);
    return resultWindow;
}
- (BOOL)getWindowWithID:(NSNumber*)windowID{
    NSArray *windows = [self.class getWindowList];
    
    for (NSDictionary *window in windows) {
        if(window[(__bridge NSString *)kCGWindowNumber] == windowID){
            [self setCurrentWindow:window];
            break;
        }
    }
    
    return self.windowID != nil;
}
- (BOOL)getWindowWithName:(NSString*)windowName{
    NSArray *windows = [self.class getWindowList];
    
    for (NSDictionary *window in windows) {
        if ([(NSString *)window[(__bridge NSString *)kCGWindowName] isEqualToString:windowName]) {
            [self setCurrentWindow:window];
            break;
        }
    }
    
    return self.windowID != nil;
}
- (BOOL)getWindowWithOwnerName:(NSString*)windowName{
    NSArray *windows = [self.class getWindowList];
    
    for (NSDictionary *window in windows) {
        if ([(NSString *)window[(__bridge NSString *)kCGWindowOwnerName] isEqualToString:windowName]) {
            [self setCurrentWindow:window];
            break;
        }
    }
    
    return self.windowID != nil;
}
- (BOOL)getWindowWithTitleContaining:(NSString*)title{
    NSArray *windows = [self.class getWindowList];
    
    for (NSDictionary *window in windows) {
        if ([(NSString *)window[(__bridge NSString *)kCGWindowName] containsString:title]) {
            [self setCurrentWindow:window];
            NSLog(@"got window: %@",window);
            break;
        }
    }
    
    return self.windowID != nil;
}
- (BOOL)setCurrentWindow:(NSDictionary*)window{
    //NSLog(@"window: %@",window);
    
    self.windowID = window[(__bridge NSString *)kCGWindowNumber];
    self.windowDict = window;
    self.windowBounds = [self.class getRectFromWindow:window];
    
    return self.windowID != nil;
}

- (NSRect)getRect{
    self.windowBounds = NSMakeRect([self.windowDict[(__bridge NSString *)kCGWindowBounds][@"X"] floatValue],
                                   [self.windowDict[(__bridge NSString *)kCGWindowBounds][@"Y"] floatValue],
                                   [self.windowDict[(__bridge NSString *)kCGWindowBounds][@"Width"] floatValue],
                                   [self.windowDict[(__bridge NSString *)kCGWindowBounds][@"Height"] floatValue]);
    return self.windowBounds;
}

+ (NSRect)getRectFromWindow:(NSDictionary*)window{
    NSRect windowBounds = NSMakeRect([window[(__bridge NSString *)kCGWindowBounds][@"X"] floatValue],
                                     [window[(__bridge NSString *)kCGWindowBounds][@"Y"] floatValue],
                                     [window[(__bridge NSString *)kCGWindowBounds][@"Width"] floatValue],
                                     [window[(__bridge NSString *)kCGWindowBounds][@"Height"] floatValue]);
    return windowBounds;
}

- (NSImage*)screenshot{
    self.windowImage = [self.class screenshotFromRect:[self getRect] forWindow:[self windowID]];

    return self.windowImage;
}
- (NSImage*)screenshotFromRect:(NSRect)theRect{
    self.windowImage = [self.class screenshotFromRect:theRect forWindow:[self windowID]];

    return self.windowImage;
}

- (NSEvent*)mouseDown:(NSPoint)point{
    NSEvent *customEvent = [NSEvent mouseEventWithType: NSEventTypeLeftMouseDown
                                              location: point
                                         modifierFlags: 0 | NSEventModifierFlagCommand
                                             timestamp:[NSDate timeIntervalSinceReferenceDate]
                                          windowNumber:[self.windowID intValue]
                                               context: nil
                                           eventNumber: 0
                                            clickCount: 1
                                              pressure: 0];
    return customEvent;
}
- (NSEvent*)mouseUp:(NSPoint)point{
    NSEvent *customEvent = [NSEvent mouseEventWithType: NSEventTypeLeftMouseUp
                                              location: point
                                         modifierFlags: 0 | NSEventModifierFlagCommand
                                             timestamp:[NSDate timeIntervalSinceReferenceDate]
                                          windowNumber:[self.windowID intValue]
                                               context: nil
                                           eventNumber: 0
                                            clickCount: 1
                                              pressure: 0];
    return customEvent;
}
- (NSEvent*)mouseMoved:(NSPoint)point{
    NSEvent *customEvent = [NSEvent mouseEventWithType: NSEventTypeMouseMoved
                                              location: point
                                         modifierFlags: 0 | NSEventModifierFlagCommand
                                             timestamp:[NSDate timeIntervalSinceReferenceDate]
                                          windowNumber:[self.windowID intValue]
                                               context: nil
                                           eventNumber: 0
                                            clickCount: 1
                                              pressure: 0];
    return customEvent;
}
- (CGEventRef)eventOfType:(NSEventType)type forPoint:(NSPoint)point{
    NSEvent *customEvent = [NSEvent mouseEventWithType: type
                                              location: point
                                         modifierFlags: 0 | NSEventModifierFlagCommand
                                             timestamp:[NSDate timeIntervalSinceReferenceDate]
                                          windowNumber: 0//[self.windowID intValue]
                                               context: nil
                                           eventNumber: 0
                                            clickCount: 1
                                              pressure: 0];
    
    CGEventRef CGEvent;
    CGEvent = [customEvent CGEvent];
    
    return CGEvent;
}
void PostMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point)
{
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    
    CFRelease(theEvent);

}

- (NSPoint)correctPointOrigin:(NSPoint)point{
    
    NSDictionary *rectDict = self.windowDict[(__bridge NSString *)kCGWindowBounds];
    NSRect windowRect = NSMakeRect([rectDict[@"X"] floatValue], [rectDict[@"Y"] floatValue], [rectDict[@"Width"] floatValue], [rectDict[@"Height"] floatValue]);
    //NSLog(@"windowRect : %@",NSStringFromRect(windowRect));
    NSLog(@"Y: %f",windowRect.origin.y);
    NSPoint returnPoint = NSMakePoint(windowRect.origin.x - point.x,
                                      windowRect.origin.y - point.y);// + windowRect.origin.y
    
    return returnPoint;
}
- (void)moveMouse:(NSPoint)point{
    
    //PostMouseEvent(0, kCGEventMouseMoved, point);
    NSEvent *customEvent = [self mouseMoved:point];
    CGEventRef CGEvent;
    CGEvent = [customEvent CGEvent];
    CGEventPost(kCGHIDEventTap, CGEvent);
    
    CFRelease(CGEvent);

}
-(void) pressKey:(CGKeyCode)key withModifiers:(CGEventFlags)modifiers forPID:(int)PID{
    // events to press a key
    CGEventRef event1 = CGEventCreateKeyboardEvent(NULL, key, true); // key down
    CGEventRef event2 = CGEventCreateKeyboardEvent(NULL, key, false); // key up
    
    // add modifiers ('command-shift-key') to event
    CGEventSetFlags(event1, modifiers);
    CGEventSetFlags(event2, modifiers);
    
    // send keyboard event to application process (a quartz event)
    CGEventPostToPid(PID, event1);
    CGEventPostToPid(PID, event2);
    
    CFRelease(event1);
    CFRelease(event2);

}

-(void) clickMouse:(CGEventType)mouseDown and:(CGEventType)mouseUp on:(CGMouseButton)mouseButton for:(UInt32)clickCount with:(CGEventFlags)modifiers forPID:(int)PID forPoint:(CGPoint)point{
    
    // current mouse position
    //CGPoint mousePosition = CGEventGetLocation(CGEventCreate(NULL));
    CGPoint mousePosition = point;
    // NSLog(@"x= %f, y = %f", (float)mousePosition.x, (float)mousePosition.y);
    
    CGEventRef event1 = CGEventCreateMouseEvent(NULL, mouseDown, mousePosition, mouseButton);
    CGEventRef event2 = CGEventCreateMouseEvent(NULL, mouseUp,   mousePosition, mouseButton);
    
    // (necessary, but isn't it already set in constructor?)
    CGEventSetType(event1, mouseDown);
    CGEventSetType(event2, mouseUp);
    
    // hold down modifier key while clicking
    CGEventSetFlags(event1, modifiers);
    CGEventSetFlags(event2, modifiers);
    
    // for double-click
    // flaky: maybe better to repeat `CGEventPost`
    CGEventSetIntegerValueField(event1, kCGMouseEventClickState, clickCount);
    CGEventSetIntegerValueField(event2, kCGMouseEventClickState, clickCount);
    
    // kCGHIDEventTap "specifies that an event tap is placed at the point where HID system events enter the window server."
    CGEventPostToPid(PID, event1);
    CGEventPostToPid(PID, event2);
    
    ProcessSerialNumber PSN;
    GetProcessPID(&PSN, &PID);
    CGEventPost(kCGHIDEventTap, event1);
    CGEventPostToPSN(&PSN, event1);
    CGEventPost(kCGHIDEventTap, event2);
    CGEventPostToPSN(&PSN, event2);
    
    CFRelease(event1);
    CFRelease(event2);

    
}
- (CGEventRef)getEventRef:(CGMouseButton)button type:(CGEventType)type point:(const CGPoint)point{
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
    CGEventSetType(theEvent, type);
    
    return theEvent;
}
- (CGEventRef)getKeyEventRef:(CGKeyCode)virtualKey keyDown:(bool)keyDown{
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);

    CGEventRef theEvent = CGEventCreateKeyboardEvent(source, virtualKey, keyDown);

    //CGEventSetFlags(theEvent, kCGEventFlagMaskControl);
    
    return theEvent;
}

#warning NSEvent won't work since flash isn't cocoa, use CGEvent instead rather than NSEvent type
//http://robnapier.net/pandoraboy-082-fixes-flash
- (void)triggerBackgroundClick:(NSPoint)point{
    NSLog(@"triggeringBackgroundClickOnPoint: %@",NSStringFromPoint(point));

    NSString *PIDstr = (NSString*)self.windowDict[(__bridge NSString *)kCGWindowOwnerPID];
    int PID = [PIDstr intValue];
    
    /*//can't get this to work with Zynga poker
    CGEventPostToPid(PID, [self eventOfType:NSEventTypeMouseMoved forPoint:point]);
    CGEventPostToPid(PID, [self eventOfType:NSEventTypeLeftMouseDown forPoint:point]);
    CGEventPostToPid(PID, [self eventOfType:NSEventTypeLeftMouseUp forPoint:point]);
    CGEventPostToPid(PID, [self eventOfType:NSEventTypeLeftMouseDown forPoint:point]);
    CGEventPostToPid(PID, [self eventOfType:NSEventTypeLeftMouseUp forPoint:point]);//*/
    CGEventRef event = [self getEventRef:kCGMouseButtonLeft type:kCGEventMouseMoved point:point];
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
    
    //CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseDown point:point]);
    //CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseUp point:point]);
    sleep(0.5);

    [self clickMouse:kCGEventLeftMouseDown and:kCGEventLeftMouseUp on:kCGMouseButtonLeft for:5 with:kCGEventFlagMaskShift forPID:PID forPoint:point];
    [self clickMouse:kCGEventLeftMouseDown and:kCGEventLeftMouseUp on:kCGMouseButtonLeft for:5 with:kCGEventFlagMaskShift forPID:PID forPoint:point];
    
}
// if mouse actually moves
- (NSPoint)adjustForScreenClick:(NSPoint)point{
    NSScreen *screen = [NSScreen mainScreen];
    CGFloat backingScaleFactor = [screen backingScaleFactor];
    
    // too far right, shift it left
    //point.x -= self.zyngaPokerWindow.windowBounds.origin.x;
    
    // too far down, shift it up
    point.y += self.windowBounds.origin.y;
    
    //point.y += self.zyngaPokerWindow.windowBounds.origin.y * backingScaleFactor;
    point.y += 10;
    return point;
}
- (NSPoint)getPointFromPixels:(NSPoint)point adjustment:(float)adjustment{
    NSScreen *screen = [NSScreen mainScreen];
    CGFloat backingScaleFactor = [screen backingScaleFactor];
    
    point.x = point.x/backingScaleFactor;
    point.y = point.y/backingScaleFactor;
    
    // flip coordinates
    //point = [screen flipPoint:point];//only flips Y coordinate
    
    // too far left, shift slightly to the right based on window position
    point.x += self.windowBounds.origin.x;
    
    // too far up, shift slightly down based on window position
    point.y -= self.windowBounds.origin.y;
    
    // adjustment since we probably can't click on corner of image.
    point.x += adjustment;
    point.y += adjustment;
    
    return point;
}

- (NSPoint)adjustPointForActionClick:(NSPoint)point{
    NSScreen *screen = [NSScreen mainScreen];
    CGFloat backingScaleFactor = [screen backingScaleFactor];
    
    // too far right, shift it left
    //point.x += self.windowBounds.origin.x;
    
    // too far down, shift it up
    //point.y -= self.windowBounds.origin.y * backingScaleFactor;
    point.y += self.windowBounds.origin.y * backingScaleFactor;
    //point.y += self.windowBounds.origin.y * backingScaleFactor;
    
    //point.y += self.zyngaPokerWindow.windowBounds.origin.y * backingScaleFactor;
    return point;
}
- (NSRunningApplication*)getActiveApp{
    for (NSRunningApplication *currApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if ([currApp isActive]) {
            NSLog(@"currentApp: %@", [currApp localizedName]);
            return currApp;
        }
    }
    return nil;
}
- (void)dbgOutputApp{
    NSLog(@"currentApplication: %@",[self getActiveApp]);

}
- (void)checkForQueuedClick{
    //NSLog(@"currentApplication: %@",[self getActiveApp]);

    if(isClickQueued){
        NSLog(@"click is queued, checking for PID match on active app: %d",queuedPid);
        if([[self getActiveApp] processIdentifier] == queuedPid){
            NSLog(@"queued PID found as active app, triggering click");
            [self triggerClickNow:clickLocation];

        }
    }
}
// bring specific window to front
- (void)bringWindowToFrontWithWindowDict:(NSDictionary*)windowDict{
    NSString *PIDstr = (NSString*)windowDict[(__bridge NSString *)kCGWindowOwnerPID];
    NSString *windowName = (NSString*)windowDict[(__bridge NSString *)kCGWindowName];

    NSString *scriptString = [NSString stringWithFormat:@"\
                              tell application \"System Events\"\n\
                              set proc to the first item of (every process whose unix id is %d)\n\
                              tell proc to perform action \"AXRaise\" of window \"%@\"\n\
                              set the frontmost of proc to true\n\
                              end tell", [PIDstr intValue], windowName];
    
    //NSLog(@"script: %@",scriptString);
    
    NSAppleScript* appleScript = [[NSAppleScript alloc] initWithSource:scriptString];
    
    NSDictionary *error = nil;
    [appleScript executeAndReturnError:&error];
    
    //NSLog(@"error: %@",error);
}
- (void)bringApplicationToFrontWithPid:(int)pid{
    [[NSApplication sharedApplication] activateIgnoringOtherApps : NO];
    
    NSString *scriptString = [NSString stringWithFormat:@"\
                              tell application \"System Events\"\n\
                              set frontmost of every process whose unix id is %d to true\n\
                              end tell",pid];
    
    NSAppleScript* appleScript = [[NSAppleScript alloc] initWithSource:scriptString];
    
    NSDictionary *error = nil;
    [appleScript executeAndReturnError:&error];
    
    //NSLog(@"error: %@",error);
}
- (void)triggerClickNow:(NSPoint)point{
    //NSLog(@"triggering queued click");
    CGEventRef event = [self getEventRef:kCGMouseButtonLeft type:kCGEventMouseMoved point:point];
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
    
    event = [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseDown point:point];
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
    
    event = [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseUp point:point];
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
    
    /*

    CGEventPostToPid(queuedPid, [self getEventRef:kCGMouseButtonLeft type:kCGEventMouseMoved point:point]);
    CGEventPostToPid(queuedPid, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseDown point:point]);
    CGEventPostToPid(queuedPid, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseUp point:point]);
    //*/

    //sleep(5);

    isClickQueued = false;
}
- (void)resetToPreviousWindow{
    // move mouse back to where it was
    CGEventRef event = [self getEventRef:kCGMouseButtonLeft type:kCGEventMouseMoved point:previousMousePosition];
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);

    NSLog(@"bringing back old window at delay");
    [activeApp activateWithOptions:NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps];
    [self bringApplicationToFrontWithPid:previousPid];
    //[self bringWindowToFrontWithWindowDict:previousWindow];

}
- (void)sendCMDA:(CGEventSourceRef)source location:(CGEventTapLocation)location{
    CGEventRef event1, event2;
    event1 = CGEventCreateKeyboardEvent (source, kVK_ANSI_A, true); // a
    event2 = CGEventCreateKeyboardEvent (source, kVK_ANSI_A, false); // a

    CGEventSetFlags(event1, (CGEventFlags) kCGEventFlagMaskCommand);
    CGEventSetFlags(event2, (CGEventFlags) kCGEventFlagMaskCommand);
    
    CGEventPost(location, event1);
    CGEventPost(location, event2);
    
    CFRelease(event1);
    CFRelease(event2);

}
- (void)typeStringNow:(NSString*)string{
    
    NSUInteger len = [string length];
    // Do It Right (tm) for accessing letters by making a unichar buffer with
    // the proper letter length
    unichar buffer[len+1];
    [string getCharacters:buffer range:NSMakeRange(0, len)];
    
    CGEventSourceRef source = NULL;//CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventTapLocation location = kCGHIDEventTap;//kCGSessionEventTap
    
    //cmd + A to select all
    [self sendCMDA:source location:location];

    //NSLog(@"code for 5(%d) converted automatically from str: (%d)", kVK_ANSI_5, keyCodeForChar('5'));
    
    for(int i = 0; i < len; i++) {
        //NSLog(@"Letter %d: %C", i, buffer[i]);
        
        CGEventRef keyDownEvent = CGEventCreateKeyboardEvent(source, keyCodeForChar(buffer[i]), true);
        CGEventRef keyUpEvent = CGEventCreateKeyboardEvent(source, keyCodeForChar(buffer[i]), false);

        CGEventPost(location, keyDownEvent);
        usleep(50000);
        CGEventPost(location, keyUpEvent);
        
        CFRelease(keyDownEvent);
        CFRelease(keyUpEvent);

        usleep(50000);
    }
    
    CGEventRef enterDownEvent = CGEventCreateKeyboardEvent(source, kVK_Return, true);
    CGEventRef enterUpEvent = CGEventCreateKeyboardEvent(source, kVK_Return, false);

    CGEventPost(location, enterDownEvent);
    usleep(50000);
    CGEventPost(location, enterUpEvent);
    usleep(50000);

    
    CFRelease(enterDownEvent);
    CFRelease(enterUpEvent);
    
    //CFRelease(source);

    
}
- (void)typeString:(NSString*)string atPoint:(NSPoint)point{
    NSString *PIDstr = (NSString*)self.windowDict[(__bridge NSString *)kCGWindowOwnerPID];
    previousWindow = [self getCurrentActiveWindow];
    
    previousMousePosition = CGEventGetLocation(CGEventCreate(NULL));
    activeApp = [self getActiveApp];
    queuedPid = [PIDstr intValue];
    previousPid = [self getActiveApp].processIdentifier;
    
    // store current state, minimizing user impact
    [NSApp activateIgnoringOtherApps:NO];//yes makes this app frontmost
    [NSApp deactivate];
    
    // BRING TARGET APP TO FRONT
    [self bringApplicationToFrontWithPid:queuedPid];
    [self bringWindowToFrontWithWindowDict:self.windowDict];
    
    NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:queuedPid];
    
    BOOL result = [targetApp activateWithOptions:NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps];
    
    NSLog(@"app active? %hhd",targetApp.active);
    //NSLog(@"currentApplication: %@, active: %hhd",[self getActiveApp], [self getActiveApp].isActive);
    
    //[self performSelector:@selector(dbgOutputApp) withObject:nil afterDelay:2];
    
    if(!targetApp.active){
        NSLog(@"app not active - failing and waiting for queue");
        return;
    }else{
        point = [self getPointFromPixels:point adjustment:5];
        point = [self adjustPointForActionClick:point];
        
        [self triggerClickNow:point];
        usleep(50000);
        [self typeStringNow:string];
        usleep(50000);

        //[self performSelector:@selector(resetToPreviousWindow) withObject:nil afterDelay:2];
    }
    [self resetToPreviousWindow];
}
- (void)triggerClick:(NSPoint)point{//616, 1386
    NSLog(@"triggeringClickOnPoint: %@",NSStringFromPoint(point));
  
    point = [self getPointFromPixels:point adjustment:5];
    NSLog(@"adjusted point: %@",NSStringFromPoint(point));

    point = [self adjustPointForActionClick:point];
    
    NSLog(@"adjusted point: %@",NSStringFromPoint(point));
//    NSScreen *screen = [NSScreen mainScreen];
    //point = [screen convertPointToScreenCoordinates:point];
    //point = [screen flipPoint:point];

//    point = [self correctPointOrigin:point];
//    NSLog(@"correct point to: %@",NSStringFromPoint(point));
    
    NSString *PIDstr = (NSString*)self.windowDict[(__bridge NSString *)kCGWindowOwnerPID];
    previousWindow = [self getCurrentActiveWindow];
    
    previousMousePosition = CGEventGetLocation(CGEventCreate(NULL));
    activeApp = [self getActiveApp];
    queuedPid = [PIDstr intValue];
    previousPid = [self getActiveApp].processIdentifier;
    
//*
    // store current state, minimizing user impact
    [NSApp activateIgnoringOtherApps:NO];//yes makes this app frontmost
    [NSApp deactivate];
    
    // BRING TARGET APP TO FRONT
    [self bringApplicationToFrontWithPid:queuedPid];
    [self bringWindowToFrontWithWindowDict:self.windowDict];
    
    NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:queuedPid];
    //BOOL result = [targetApp activateWithOptions:NSApplicationActivateAllWindows];

    BOOL result = [targetApp activateWithOptions:NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps];

    NSLog(@"app active? %hhd",targetApp.active);
    //NSLog(@"currentApplication: %@, active: %hhd",[self getActiveApp], [self getActiveApp].isActive);

    //[self performSelector:@selector(dbgOutputApp) withObject:nil afterDelay:2];
    
    if(!targetApp.active){
        NSLog(@"app not active - failing and waiting for queue");
        
        isClickQueued = true;
        clickLocation = point;
        return;
    
    }else{//*/
        NSLog(@"==== clicking");
        [self triggerClickNow:point];
        
        //[self performSelector:@selector(resetToPreviousWindow) withObject:nil afterDelay:2];
        [self resetToPreviousWindow];
    }

    
    /*
    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventMouseMoved point:point]);
    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseDown point:point]);
    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseUp point:point]);
    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseDown point:point]);
    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseUp point:point]);//*/
    

    
    //NSLog(@"CLICKS COMPLETE");
    /*
    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventMouseMoved point:point]);    sleep(0.5);

    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseDown point:point]);    sleep(0.5);

    CGEventPostToPid(PID, [self getEventRef:kCGMouseButtonLeft type:kCGEventLeftMouseUp point:point]);//*/

    /*
    customEvent = [self mouseDown:point];
    CGEvent = [customEvent CGEvent];
    CGEventPostToPid(PID, CGEvent);
    
    customEvent = [self mouseUp:point];
    CGEvent = [customEvent CGEvent];
    CGEventPostToPid(PID, CGEvent);//*/
}
- (void)switchAndClick:(NSPoint)point{
    // store current frontmost app
    // switch to target app / window
    // simulate mouse click
    // switch back to current frontmost app
    
    myApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    
    NSLog(@"window: %@ with ID: %@",self.windowDict, self.windowID);
    NSString *PIDstr = (NSString*)self.windowDict[(__bridge NSString *)kCGWindowOwnerPID];
    int PID = [PIDstr intValue];
    
    CGEventRef CGEvent;
    NSEvent *customEvent;
    
    customEvent = [self mouseDown:point];
    CGEvent = [customEvent CGEvent];
    CGEventPostToPid(PID, CGEvent);
    
    customEvent = [self mouseUp:point];
    CGEvent = [customEvent CGEvent];
    CGEventPostToPid(PID, CGEvent);
    
    CFRelease(CGEvent);

}


// static class methods
+ (NSArray*)getWindowList{
    CFArrayRef windowListArray = CGWindowListCreate(kCGWindowListOptionOnScreenOnly|kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    NSArray *windows = CFBridgingRelease(CGWindowListCreateDescriptionFromArray(windowListArray));
    
    
    CFRelease(windowListArray);
    return windows;
}
+ (NSImage*)screenshotFromRect:(NSRect)theRect{
    return [self.class screenshotFromRect:theRect forWindow:kCGNullWindowID];
}
+ (NSImage*)screenshotFromRect:(NSRect)theRect forWindow:(NSNumber*)windowID{
    CGImageRef screenShot;
    if(windowID != kCGNullWindowID){
        // captures only specific window, even if not in front.
        screenShot = CGWindowListCreateImage(theRect, kCGWindowListOptionIncludingWindow, [windowID unsignedIntValue], kCGWindowImageDefault);
    }else{
        // captures frontmost window in that frame
        screenShot = CGWindowListCreateImage(theRect, kCGWindowListOptionOnScreenOnly, [windowID unsignedIntValue], kCGWindowImageDefault);
    }
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:screenShot];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    [image setCacheMode:NSImageCacheNever];

    CGImageRelease(screenShot);
    return image;
}


- (BOOL)getWindowZynga{
    if(![self getWindowWithTitleContaining:@"Texas HoldEm Poker"]){
        NSLog(@"couldn't get window");
        self.haveWindow = false;
    }else{
        NSLog(@"got window: %@",self.windowDict);
        self.haveWindow = true;
    }
    return self.haveWindow;
}

CGKeyCode keyCodeForChar(unichar key)
{
    CGKeyCode code = 0;
    if (key == '0') return kVK_ANSI_0;
    else if (key == '1') return kVK_ANSI_1;
    else if (key == '2') return kVK_ANSI_2;
    else if (key == '3') return kVK_ANSI_3;
    else if (key == '4') return kVK_ANSI_4;
    else if (key == '5') return kVK_ANSI_5;
    else if (key == '6') return kVK_ANSI_6;
    else if (key == '7') return kVK_ANSI_7;
    else if (key == '8') return kVK_ANSI_8;
    else if (key == '9') return kVK_ANSI_9;
    return code;
}


@end
