//
//  ImageCache.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 18.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface ImageCache : NSObject

- (UIImage *) imageNamed:(NSString*)name;
- (void) clearCache;

@end
