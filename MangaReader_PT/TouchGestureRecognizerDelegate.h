//
//  TouchGestureRecognizerDelegate.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 20.05.16.
//  Copyright © 2016 Benjamin Rannow. All rights reserved.
//

@class TouchGestureRecognizer;

@protocol TouchGestureRecognizerDelegate <UIGestureRecognizerDelegate>
@optional
- (bool) touchGestureRecognizerPreventBegan:(TouchGestureRecognizer *)gestureRecognizer withEvent:(UIEvent *)event;

- (void) touchGestureRecognizer:(TouchGestureRecognizer *)gestureRecognizer foundPossibleTouch:(UITouch *)touch withEvent:(UIEvent *)event;

- (void) touchGestureRecognizer:(TouchGestureRecognizer *)gestureRecognizer cancelPossibleTouch:(UITouch *)touch withEvent:(UIEvent *)event;

@end