//
//  SpringBoardFolderViewDelegate.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 11.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpringBoardFolderView, SpringBoardItemView;

@protocol SpringBoardFolderViewDelegate <NSObject>

- (NSInteger) numberOfItemInSpringBoardFolder:(SpringBoardFolderView*)folder
                                      atIndex:(NSInteger)index;

- (SpringBoardItemView*) springBoardItem:(SpringBoardFolderView*)folder
                                 atIndex:(NSUInteger)index;

@optional
- (void) springBoardFolder:(SpringBoardFolderView*)folder
               itemSeleced:(SpringBoardItemView*)item
                 atIndex:(NSInteger)index;

@end
