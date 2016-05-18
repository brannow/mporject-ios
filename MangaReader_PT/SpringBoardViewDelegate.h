//
//  SpringBoardViewDelegate.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 11.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpringBoardView, SpringBoardFolderView, SpringBoardItemView;

@protocol SpringBoardViewDelegate <NSObject>

// main delegates
- (NSInteger) numberOfFolderInSpringBoard:(SpringBoardView*)master;
- (SpringBoardFolderView*) springBoardFolder:(SpringBoardView*)master
                                   withIndex:(NSInteger)index;

@optional
- (void) activeSpringBoardFolder:(SpringBoardFolderView*)folder;

@end
