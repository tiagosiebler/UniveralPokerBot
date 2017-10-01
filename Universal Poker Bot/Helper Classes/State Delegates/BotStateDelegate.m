//
//  BotStateDelegate.m
//  PokerAPI
//
//  Created by Siebler, Tiago on 08/05/2017.
//  Copyright © 2017 TGS. All rights reserved.
//

#import "BotStateDelegate.h"

@implementation BotState{
    struct {
        unsigned int willStartInitialising:1;
        unsigned int didFinishInitialising:1;

        unsigned int didPauseReading:1;
        unsigned int didResumeReading:1;

        unsigned int didPauseActions:1;
        unsigned int didResumeActions:1;

        unsigned int willFindWindow:1;
        unsigned int didFindWindow:1;
        unsigned int couldNotFindWindow:1;

        unsigned int referencePointDidMove:1;
        unsigned int willFindReferencePoint:1;
        unsigned int didFindReferencePoint:1;
        unsigned int couldNotFindReferencePoint:1;

        unsigned int willStartRecalibrating:1;
        unsigned int didFinishRecalibrating:1;
    } delegateRespondsTo;
}
@synthesize delegate;

- (void)setDelegate:(id <BotStateDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
        
        delegateRespondsTo.willStartInitialising = [delegate respondsToSelector:@selector(willStartInitialising:)];
        delegateRespondsTo.didFinishInitialising = [delegate respondsToSelector:@selector(didFinishInitialising:)];

        delegateRespondsTo.didPauseReading       = [delegate respondsToSelector:@selector(didPauseReading:)];
        delegateRespondsTo.didResumeReading = [delegate respondsToSelector:@selector(didResumeReading:)];

        delegateRespondsTo.didPauseActions = [delegate respondsToSelector:@selector(didPauseActions:)];
        delegateRespondsTo.didResumeActions = [delegate respondsToSelector:@selector(didResumeActions:)];

        delegateRespondsTo.willFindWindow = [delegate respondsToSelector:@selector(willFindWindow:)];
        delegateRespondsTo.didFindWindow = [delegate respondsToSelector:@selector(didFindWindow:)];
        delegateRespondsTo.couldNotFindWindow = [delegate respondsToSelector:@selector(couldNotFindWindow:withError:)];

        delegateRespondsTo.referencePointDidMove = [delegate respondsToSelector:@selector(referencePointDidMove:)];
        delegateRespondsTo.willFindReferencePoint = [delegate respondsToSelector:@selector(willFindReferencePoint:)];
        delegateRespondsTo.didFindReferencePoint = [delegate respondsToSelector:@selector(didFindReferencePoint:)];
        delegateRespondsTo.couldNotFindReferencePoint = [delegate respondsToSelector:@selector(couldNotFindReferencePoint:withError:)];

        delegateRespondsTo.willStartRecalibrating = [delegate respondsToSelector:@selector(willStartRecalibrating:)];
        delegateRespondsTo.didFinishRecalibrating = [delegate respondsToSelector:@selector(didFinishRecalibrating:)];
    }
}

@end
