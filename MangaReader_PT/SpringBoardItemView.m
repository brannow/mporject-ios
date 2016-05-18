//
//  SpringBoardItemView.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SpringBoardItemView.h"

@implementation SpringBoardItemView


- (id) init
{
    self = [super init];
    if(self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void) setImage:(UIImage*)image
{
    self.imageView.image = image;
    self.imageView.frame = self.bounds;
}

- (void) reset
{
    self.imageView.image = nil;
}

- (void) renderView
{
    self.imageView.frame = self.bounds;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5f;
    
}

@end
