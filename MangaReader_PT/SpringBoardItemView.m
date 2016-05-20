//
//  SpringBoardItemView.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SpringBoardItemView.h"

@interface SpringBoardItemView ()

@property (nonatomic) CALayer *grayLayer;
@end

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
    [self unselect];
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

- (void) select
{
    self.grayLayer = [CALayer layer];
    self.grayLayer.frame = self.layer.bounds;
    self.grayLayer.backgroundColor = [[UIColor grayColor] CGColor];
    self.grayLayer.opacity = 0.3f;
    [self.layer addSublayer:self.grayLayer];
}

- (void) unselect
{
    if (self.grayLayer != nil) {
        [self.grayLayer removeFromSuperlayer];
        self.grayLayer = nil;
    }
}

@end
