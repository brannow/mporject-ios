//
//  TouchGestureRecognizer.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 19.05.16.
//  Copyright © 2016 Benjamin Rannow. All rights reserved.
//

#import "TouchGestureRecognizer.h"
#import "TouchGestureRecognizerDelegate.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TouchGestureRecognizer ()

@property (nonatomic, strong) UITouch *currentTouch;
@property (nonatomic) CGPoint currentTouchStartPos;
@end

@implementation TouchGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.currentTouch == nil && self.state == UIGestureRecognizerStatePossible && [[event allTouches] count] == 1) {
        self.currentTouch = [touches anyObject];
        self.currentTouchStartPos = [self.currentTouch locationInView:nil];
        if ([self.delegate respondsToSelector:@selector(touchGestureRecognizer:foundPossibleTouch:withEvent:)]) {
            [(id)self.delegate touchGestureRecognizer:self foundPossibleTouch:self.currentTouch withEvent:event];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // TODO: need here a safe move zone from 10pt maybe without cancel call
    self.state = UIGestureRecognizerStateFailed;
    [self cancelTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.currentTouch != nil && [touches containsObject:self.currentTouch]) {
        self.currentTouch = nil;
        self.state = UIGestureRecognizerStateRecognized;
    } else if ([[event allTouches] count] == 1) {
        self.currentTouch = nil;
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateFailed;
    if (self.currentTouch != nil && [touches containsObject:self.currentTouch]) {
        [self cancelTouchEvent:event];
    }
}

- (void) cancelTouchEvent:(UIEvent *)event
{
    if(self.currentTouch) {
        if ([self.delegate respondsToSelector:@selector(touchGestureRecognizer:cancelPossibleTouch:withEvent:)]) {
            [(id)self.delegate touchGestureRecognizer:self cancelPossibleTouch:self.currentTouch withEvent:event];
        }
    }
    self.currentTouch = nil;
}


@end
