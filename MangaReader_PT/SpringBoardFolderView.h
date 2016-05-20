//
//  SpringBoardFolderView.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchGestureRecognizerDelegate.h"

@protocol SpringBoardFolderViewDelegate;

@class SpringBoardItemView;

@interface SpringBoardFolderView : UIScrollView <UIScrollViewDelegate, TouchGestureRecognizerDelegate>

@property (nonatomic, weak) id <SpringBoardFolderViewDelegate> springBoardFolderDelegate;

@property (nonatomic , strong) NSString *name;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL unlocked;

- (id) init;
- (id) initWithName:(NSString*)name;
- (void) reset;
- (void) reload;

- (SpringBoardItemView*) obtainRecycledSpringBoardItem;

@end
