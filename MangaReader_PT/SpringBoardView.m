//
//  SpringBoardView.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import "SpringBoardView.h"
#import "SpringBoardFolderView.h"
#import "SpringBoardViewDelegate.h"
#import "SpringBoardFolderViewDelegate.h"
#import "SpringBoardCache.h"

@interface SpringBoardView ()

@property (nonatomic, assign) NSInteger maxItems;
@property (nonatomic, strong) NSMutableArray *recycleFolders;
@property (nonatomic, strong) NSMutableArray *folders;

@property (nonatomic) CGFloat cacheOffset;
@property (nonatomic) CGFloat cacheStepLimit;
@property (nonatomic) NSRange cacheRange;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) CGFloat halfWidth;

@property (nonatomic, strong) NSMutableDictionary *folderOffsetStorage;

@end

CGFloat const heuristicOffset = 40.0f;
NSUInteger const pageRenderOffset = 1;

@implementation SpringBoardView

-(void) awakeFromNib
{
    [self setDelegate:self];
    self.maxItems = 0;
    self.cacheRange = NSMakeRange(0, 0);
    self.cacheStepLimit = 10;
    self.halfWidth = self.bounds.size.width / 2;
    
    self.recycleFolders = [NSMutableArray array];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.x > self.cacheOffset+self.cacheStepLimit ||
       scrollView.contentOffset.x < self.cacheOffset-self.cacheStepLimit) {
        self.cacheOffset = scrollView.contentOffset.x;
        [self renderFolder];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.cacheOffset = scrollView.contentOffset.x;
    [self renderFolder];
}

- (NSRange) rangeOfItemsInViewPort {
    
    if(self.maxItems <= 1) {
        self.currentIndex = 0;
        return NSMakeRange(0, 0);
    }
    
    if(self.contentOffset.x < self.halfWidth) {
        // fast return for appstart ...save some assembler code ;)
        self.currentIndex = 0;
        // preinit page 3 ... prevent startup lag
        if(self.maxItems > 2) {
            return NSMakeRange(0, pageRenderOffset + 1);
        }
        return NSMakeRange(0, pageRenderOffset);
    }
    
    
    self.currentIndex = (NSInteger)floor(self.contentOffset.x / self.bounds.size.width);
    CGFloat midX = (self.currentIndex * self.bounds.size.width) + self.halfWidth;
    if(midX <= self.contentOffset.x) {
        self.currentIndex = self.currentIndex + 1;
    }
    
    NSInteger endIndex = self.currentIndex + pageRenderOffset;
    NSInteger startIndex = self.currentIndex - pageRenderOffset;
    if(endIndex >= self.maxItems) {
        endIndex = self.maxItems - 1;
    }
    
    if(startIndex < 0) {
        startIndex = 0;
    }

    return NSMakeRange(startIndex, endIndex);
}

- (void) reload
{
    [self removeAllFolder];
    [self initSpringBoard];
}

- (void) initSpringBoard
{
    if(self.folders == nil) {
        self.folders = [NSMutableArray array];
    }
    
    self.halfWidth = self.bounds.size.width / 2;
    self.cacheRange = NSMakeRange(0, 0);
    self.maxItems = [self delegateNumberOfFolder];
    self.folderOffsetStorage = [NSMutableDictionary dictionary];
    if(self.maxItems > 1) {
        [self setContentSize:CGSizeMake(self.bounds.size.width * self.maxItems, 1)];
        self.scrollEnabled = YES;
    } else {
        [self setContentSize:CGSizeMake(1, 1)];
        self.scrollEnabled = NO;
    }
    
    [self renderFolder];
    [self delegateActiveSpringBoardFolder:[self folderWithIndex:self.currentIndex]];
}

- (void) renderFolder
{
    if(self.maxItems <= 0) {
        return;
    }
    
    NSInteger oldIndex = self.currentIndex;
    NSRange range = [self rangeOfItemsInViewPort];
    
    // maxItems == 1 special case if only 1 item exist
    if(range.length != self.cacheRange.length ||
       range.location != self.cacheRange.location ||
       self.maxItems == 1) {
        
        // dirty means not in viewport
        [self removeDirtyFolder:range];
        [self addFolderWithRange:range];
        
        self.cacheRange = range;
    }
    
    if(oldIndex != self.currentIndex) {
        [self delegateActiveSpringBoardFolder:[self folderWithIndex:self.currentIndex]];
    }
}

- (SpringBoardFolderView*) folderWithIndex:(NSInteger)index
{
    for(SpringBoardFolderView *folder in self.folders) {
        if(folder.index == index) {
            return folder;
        }
    }
    return nil;
}

- (void) addFolderWithRange:(NSRange)range
{
    for (NSUInteger i = range.location; i <= range.length; ++i) {
        [self addFolderWithIndex:i];
    }
}

- (void) addFolderWithIndex:(NSUInteger)index
{
    if(![self containsFolderWithIndex:index]) {
        SpringBoardFolderView *folder = [self delegateSpringBoardFolderWithIndex:index];
        if(folder && ![self.folders containsObject:folder]) {
            CGRect templateRect = self.bounds;
            templateRect.origin.x = index * self.bounds.size.width;
            folder.frame = templateRect;
            folder.index = index;
            [folder setSpringBoardFolderDelegate:self.springBoardDelegate];
            [self.folders addObject:folder];
            if([self.subviews containsObject:folder]) {
                folder.hidden = NO;
            } else {
                [self addSubview:folder];
            }
            
            // prevent dangling scrollview offset from recycled folder view
            [self reinitFolderFromCache:folder];
            
            // init folder
            [folder reload];
        }
    }
}

- (BOOL) containsFolderWithIndex:(NSUInteger) index
{
    for(SpringBoardFolderView *folder in self.folders) {
        if(folder.index == index) {
            return YES;
        }
    }
    return NO;
}

- (void) removeDirtyFolder:(NSRange)usedRange
{
    NSMutableArray *disposeItems = [NSMutableArray array];
    for(SpringBoardFolderView *folder in self.folders) {
        if(folder.index < usedRange.location || folder.index > usedRange.length) {
            [disposeItems addObject:folder];
        }
    }
    
    for(SpringBoardFolderView *folder in disposeItems) {
        [self removeFolderFromView:folder];
    }
}

- (void) removeAllFolder
{
    if(self.folders && [self.folders count] > 0) {
        NSMutableArray *disposeItems = [NSMutableArray arrayWithArray:self.folders];
        for(SpringBoardFolderView *folder in disposeItems) {
            [self removeFolderFromView:folder];
        }
    }
}


- (void) removeFolderFromView:(SpringBoardFolderView*)folder
{
    if([self.folders containsObject:folder]) {
        [self.folders removeObject:folder];
        folder.hidden = YES;
        folder.unlocked = NO;
        // save cache data in folderOffsetStorage to prvent some math fu
        [self initCacheValueForFolder:folder];
        
        // if recycle folder not init
        if(self.recycleFolders == nil) {
            self.recycleFolders = [NSMutableArray array];
        }
        
        [self.recycleFolders addObject:folder];
    }
}

- (void) initCacheValueForFolder:(SpringBoardFolderView*)folder
{
    if(self.folderOffsetStorage == nil) {
        self.folderOffsetStorage = [NSMutableDictionary dictionary];
    }
    SpringBoardCache *cache = [self.folderOffsetStorage objectForKey:[NSString stringWithFormat:@"%ld", (long)folder.index]];
    if(cache == nil) {
        cache = [[SpringBoardCache alloc] init];
    }
    
    cache.offsetPoint = folder.contentOffset;
    [self.folderOffsetStorage setObject:cache forKey:[NSString stringWithFormat:@"%ld", (long)folder.index]];
}

- (void) reinitFolderFromCache:(SpringBoardFolderView*)folder
{
    if(self.folderOffsetStorage) {
        SpringBoardCache *cache = (SpringBoardCache*)[self.folderOffsetStorage objectForKey:[NSString stringWithFormat:@"%ld", (long)folder.index]];
        if(cache) {
            folder.contentOffset = cache.offsetPoint;
        } else {
            folder.contentOffset = CGPointMake(0, -folder.contentInset.top);
        }
    }
}

- (SpringBoardFolderView*) obtainRecycledSpringBoardFolder
{
    if(self.recycleFolders == nil) {
        self.recycleFolders = [NSMutableArray array];
    }
    if([self.recycleFolders count] > 0) {
        SpringBoardFolderView *folder = [self.recycleFolders lastObject];
        [self.recycleFolders removeObject:folder];
        [folder reset];
        return folder;
    }
    return nil;
}

- (NSInteger) currentIndex
{
    return _currentIndex;
}

- (NSInteger) delegateNumberOfFolder
{
    if ([self.springBoardDelegate respondsToSelector:@selector(numberOfFolderInSpringBoard:)]) {
        return [self.springBoardDelegate numberOfFolderInSpringBoard:self];
    }
    return 0;
}

- (SpringBoardFolderView*) delegateSpringBoardFolderWithIndex:(NSInteger)index
{
    if ([self.springBoardDelegate respondsToSelector:@selector(springBoardFolder:withIndex:)]) {
        return [self.springBoardDelegate springBoardFolder:self withIndex:index];
    }
    return nil;
}

- (void) delegateActiveSpringBoardFolder:(SpringBoardFolderView*)folder {
    if (folder && [self.springBoardDelegate respondsToSelector:@selector(activeSpringBoardFolder:)]) {
        return [self.springBoardDelegate activeSpringBoardFolder:folder];
    }
}

@end
