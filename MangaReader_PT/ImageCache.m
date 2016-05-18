//
//  ImageCache.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 18.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import "ImageCache.h"
#import <UIKit/UIImage.h>

NSUInteger const imageCacheMaxLimit = 600;

@interface ImageCache ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation ImageCache

- (id) init
{
    self = [super init];
    if(self != nil) {
        self.cache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (UIImage *) imageNamed:(NSString*)name
{
    UIImage *image = nil;
    id _image = [self.cache objectForKey:name];
    
    if(_image) {
        image = (UIImage*)_image;
    } else {
        image = [UIImage imageNamed:name];
        if([self.cache count] < imageCacheMaxLimit) {
            [self.cache setObject:image forKey:name];
        }
    }
    
    return image;
}

- (void) clearCache
{
    [self.cache removeAllObjects];
}

@end
