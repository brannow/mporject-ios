//
//  SpringBoardItemView.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpringBoardItemView : UIView

@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) UIImageView *imageView;

- (id) init;
- (id) initWithCoder:(NSCoder *)aDecoder;
- (id) initWithFrame:(CGRect)frame;
- (void) reset;
- (void) setImage:(UIImage*)image;

- (void) select;
- (void) unselect;

- (void) renderView;

@end
