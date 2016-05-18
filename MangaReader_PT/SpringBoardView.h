//
//  SpringBoardView.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpringBoardFolderView;

@protocol SpringBoardViewDelegate, SpringBoardFolderViewDelegate;

@interface SpringBoardView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet id <SpringBoardViewDelegate, SpringBoardFolderViewDelegate> springBoardDelegate;

- (void) reload;
- (SpringBoardFolderView*) obtainRecycledSpringBoardFolder;
- (NSInteger) currentIndex;

@end
