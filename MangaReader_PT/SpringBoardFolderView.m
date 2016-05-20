//
//  SpringBoardFolderView.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import "SpringBoardFolderView.h"
#import "SpringBoardItemView.h"
#import "SpringBoardFolderViewDelegate.h"
#import "TouchGestureRecognizer.h"

@interface SpringBoardFolderView ()

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) NSInteger hLimit;
@property (nonatomic, assign) CGRect itemTemplate;
@property (nonatomic, assign) CGSize nativeItemSize;
@property (nonatomic, assign) NSInteger maxItems;

@property (nonatomic, strong) NSMutableArray *recycleItems;
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic) NSRange cacheRange;
@property (nonatomic) CGFloat cacheOffset;
@property (nonatomic) CGFloat viewSize;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) NSInteger specialStartEndIndex;

@property (nonatomic, weak) SpringBoardItemView *selectedItem;
@end

CGFloat const cacheOffsetFolderLimit = 50.0f;
NSUInteger const pageRowRenderOffset = 1;

@implementation SpringBoardFolderView

- (id) init
{
    self = [super init];
    if (self) {
        [self folderDidLoad];
    }
    return self;
}

- (id) initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        [self folderDidLoad];
        self.name = name;
    }
    return self; 
}

- (void) folderDidLoad
{
    self.unlocked = NO;
    self.specialStartEndIndex = 0;
    self.cacheOffset = 0;
    self.cacheRange = NSMakeRange(0, 0);
    [self setDelegate:self];
    self.contentInset=UIEdgeInsetsMake(60.0,0.0,0.0,0.0);
    self.scrollIndicatorInsets = UIEdgeInsetsMake(63.0,0.0,0.0,0.0);
    self.recycleItems = [NSMutableArray array];
    
    TouchGestureRecognizer *singleTap = [[TouchGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
}

- (void)singleTapGestureCaptured:(TouchGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:self];
    id subView = [self hitTest:touchPoint withEvent:nil];
    if(subView && [subView isKindOfClass:[SpringBoardItemView class]] && [self.items containsObject:subView]) {
        SpringBoardItemView *item = (SpringBoardItemView*)subView;
        if (self.selectedItem != nil) {
            [self.selectedItem unselect];
        }
        [self performSelector:@selector(delegateSpringBoardItemSelected:) withObject:item afterDelay:0.15f];
    }
}

- (void) touchGestureRecognizer:(TouchGestureRecognizer *)gesture
             foundPossibleTouch:(UITouch *)touch
                      withEvent:(UIEvent *)event
{
    CGPoint touchPoint=[gesture locationInView:self];
    id subView = [self hitTest:touchPoint withEvent:nil];
    if(subView && [subView isKindOfClass:[SpringBoardItemView class]] && [self.items containsObject:subView]) {
        SpringBoardItemView *item = (SpringBoardItemView*)subView;
        if (self.selectedItem != nil) {
            [self.selectedItem unselect];
        }
        self.selectedItem = item;
        [self.selectedItem select];
    }
}

- (void) touchGestureRecognizer:(TouchGestureRecognizer *)gesture
            cancelPossibleTouch:(UITouch *)touch
                      withEvent:(UIEvent *)event
{
    if (self.selectedItem != nil) {
        [self.selectedItem unselect];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y > self.cacheOffset+cacheOffsetFolderLimit ||
       scrollView.contentOffset.y < self.cacheOffset-cacheOffsetFolderLimit) {
        self.cacheOffset = scrollView.contentOffset.y;
        [self renderFolderItems];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y > self.cacheOffset+cacheOffsetFolderLimit ||
       scrollView.contentOffset.y < self.cacheOffset-cacheOffsetFolderLimit) {
        self.cacheOffset = scrollView.contentOffset.y;
        [self renderFolderItems];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate) {
        if(scrollView.contentOffset.y > self.cacheOffset+cacheOffsetFolderLimit ||
           scrollView.contentOffset.y < self.cacheOffset-cacheOffsetFolderLimit) {
            self.cacheOffset = scrollView.contentOffset.y;
            [self renderFolderItems];
        }
    }
}

- (void) reset
{
    self.specialStartEndIndex = 0;
    self.cacheOffset = 0;
    self.cacheRange = NSMakeRange(0, 0);
    self.springBoardFolderDelegate = nil;
}

- (void) reload
{
    [self removeAllItems];
    [self initSpringBoardFolder];
}

- (void) initSpringBoardFolder
{
    if(self.items == nil) {
        self.items = [NSMutableArray array];
    }

    self.specialStartEndIndex = 0;
    self.maxItems = [self delegateNumberOfItem];
    self.cacheOffset = 0;
    self.cacheRange = NSMakeRange(0, 0);
    
    self.itemTemplate = CGRectMake(0, 0, 100, 157);
    self.offset = 10.0f;
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxContentWidth = (self.itemTemplate.size.width + (self.offset * 2));
    self.hLimit = floor(maxWidth / maxContentWidth);
    if (self.hLimit <= 1) {
        self.hLimit = 1;
    } else {
        self.offset += floor((maxWidth-(maxContentWidth * self.hLimit)) / (self.hLimit * 2));
    }
    self.nativeItemSize = CGSizeMake(self.itemTemplate.size.width + (self.offset*2), self.itemTemplate.size.height + (self.offset*2));
    self.viewSize = self.bounds.size.height + self.nativeItemSize.height;
    NSInteger vMax = floor((self.maxItems - 1) / self.hLimit) + 1;
    self.viewSize = self.bounds.size.height + self.nativeItemSize.height;
    CGFloat contentHeight = ((self.itemTemplate.size.height + self.offset) * vMax) + (self.offset * (vMax+1)) - self.offset;
    [self setContentSize:CGSizeMake(1, contentHeight)];
    self.maxY = self.contentSize.height - self.bounds.size.height;
    if(contentHeight < self.bounds.size.height) {
        self.scrollEnabled = NO;
    } else {
        self.scrollEnabled = YES;
    }
    
    self.unlocked = YES;
    [self renderFolderItems];
}

- (void) renderFolderItems
{
    if(self.maxItems <= 0 || !self.unlocked) {
        return;
    }
    
    NSRange range = [self rangeOfItemsInViewPort];
    if(range.length != self.cacheRange.length ||
       range.location != self.cacheRange.location ||
       self.maxItems == 1) {
        NSRange addRange, removeRange;
        
        // check if cache range not empty ... overwise init new element plain
        if(self.cacheRange.location != 0 || self.cacheRange.length != 0) {
            if(range.location >= self.cacheRange.location &&
               range.length >= self.cacheRange.length)
            {
                NSUInteger addStart = self.cacheRange.length + 1;
                if(self.cacheRange.length == 0) {
                    addStart = 0;
                }
                
                NSUInteger removeEnd = 0;
                if(range.location != 0) {
                    removeEnd = range.location - 1;
                }
                
                // scroll down
                addRange = NSMakeRange(addStart, range.length);
                removeRange = NSMakeRange(self.cacheRange.location, removeEnd);
            } else {
                
                NSUInteger addEnd = self.cacheRange.location - 1;
                if(self.cacheRange.location == 0) {
                    addEnd = 0;
                }
                NSUInteger removeStart = range.length + 1;
                if(removeStart > self.cacheRange.length) {
                    removeStart = self.cacheRange.length;
                }
                
                // scroll up
                removeRange = NSMakeRange(removeStart, self.cacheRange.length);
                addRange = NSMakeRange(range.location, addEnd);
            }
        } else {
            removeRange = NSMakeRange(0, 0);
            addRange = range;
        }
        
        [self removeItemsWithRange:removeRange];
        [self addItemsWithRange:addRange];

        self.cacheRange = range;
    }
}

-(NSRange) rangeOfItemsInViewPort
{
    if(self.maxItems <= 1) {
        return NSMakeRange(0, 0);
    }
    
    CGFloat sOffset = self.contentOffset.y + self.contentInset.top;
    if(self.maxY < sOffset) {
        sOffset = self.maxY - self.offset;
    }
    
    CGFloat viewOffset = sOffset - self.nativeItemSize.height;
    
    
    if(viewOffset < 0) {
        viewOffset = 0;
    }
    
    NSInteger startIndex = 0, endIndex = 0;
    
    startIndex = (NSInteger) floor(viewOffset / self.nativeItemSize.height) * self.hLimit;
    if(startIndex >= self.maxItems) {
        // count index difference
        // index start at 0; count at 1
        startIndex = self.maxItems-1;
    }

    // self.viewSize contains the viewPortheight include the preload offset
    // viewOffset + self.viewSize = the maximal Y point for the viewport include preload offset
    endIndex = (NSInteger) (ceil((sOffset + self.viewSize) / self.nativeItemSize.height) * self.hLimit) - 1;
    
    if(self.specialStartEndIndex == 0) {
        self.specialStartEndIndex = endIndex + (self.hLimit * 2);
    }
    
    if(endIndex < self.specialStartEndIndex) {
        endIndex = self.specialStartEndIndex;
    }
    
    if(endIndex >= self.maxItems) {
        // count index difference
        // index start at 0; count at 1
        endIndex = self.maxItems-1;
    }
    
    return NSMakeRange(startIndex, endIndex);
}

- (void) addItemsWithRange:(NSRange)range
{
    for(NSUInteger i = range.location; i <= range.length; ++i) {
        [self renderItemAtIndex:i];
    }
}

- (void) removeItemsWithRange:(NSRange)range
{
    if(range.location != range.length) {
        NSMutableArray *disposeItems = [NSMutableArray array];
        for(SpringBoardItemView *item in self.items) {
            if(item.index >= range.location && item.index <= range.length)
            {
                [disposeItems addObject:item];
            }
        }
        
        for(SpringBoardItemView *item in disposeItems) {
            [self removeItemFromView:item];
        }
    }
}

- (void) removeItemFromView:(SpringBoardItemView*)item
{
    [self.items removeObject:item];
    item.hidden = YES;
    // if recycle folder not init
    if(self.recycleItems == nil) {
        self.recycleItems = [NSMutableArray array];
    }
    
    [self.recycleItems addObject:item];
}

- (void) renderItemAtIndex:(NSUInteger)index
{
    if(index < self.maxItems && ![self containsItemWithIndex:index]) {
        SpringBoardItemView *item = [self delegateSpringBoardItemAtIndex:index];
        
        if(item) {
            NSUInteger hIndex = index % self.hLimit;
            // todo:
            // maybe pre-calculated dictionary with index = vIndex
            NSUInteger vIndex = (NSUInteger) floor(index / self.hLimit);
            
            CGRect frame = self.itemTemplate;
            frame.origin.x = (self.nativeItemSize.width * hIndex) + self.offset;
            frame.origin.y = (self.nativeItemSize.height * vIndex) + self.offset;
            item.index = index;
            item.frame = frame;
            [self.items addObject:item];
            if([self.subviews containsObject:item]) {
                item.hidden = NO;
            } else {
                [self addSubview:item];
            }
            [item renderView];
        }
    }
}

- (BOOL) containsItemWithIndex:(NSInteger) index
{
    for(SpringBoardItemView *item in self.items) {
        if(item.index == index) {
            return YES;
        }
    }
    return NO;
}

- (void) removeAllItems
{
    if(self.items && [self.items count] > 0) {
        NSMutableArray *disposeItems = [NSMutableArray arrayWithArray:self.items];
        for(SpringBoardItemView *item in disposeItems) {
            [self removeItemFromView:item];
        }
    }
}

- (NSInteger) delegateNumberOfItem
{
    if ([self.springBoardFolderDelegate respondsToSelector:@selector(numberOfItemInSpringBoardFolder:atIndex:)]) {
        return [self.springBoardFolderDelegate numberOfItemInSpringBoardFolder:self atIndex:self.index];
    }
    return 0;
}

- (void) delegateSpringBoardItemSelected:(SpringBoardItemView*)item
{
    if ([self.springBoardFolderDelegate respondsToSelector:@selector(springBoardFolder:itemSeleced:atIndex:)]) {
        [self.springBoardFolderDelegate springBoardFolder:self itemSeleced:item atIndex:item.index];
    }
}

- (SpringBoardItemView*) delegateSpringBoardItemAtIndex:(NSUInteger)index
{
    if ([self.springBoardFolderDelegate respondsToSelector:@selector(springBoardItem:atIndex:)]) {
        return [self.springBoardFolderDelegate springBoardItem:self atIndex:index];
    }
    return nil;
}

- (SpringBoardItemView*) obtainRecycledSpringBoardItem
{
    if(self.recycleItems == nil) {
        self.recycleItems = [NSMutableArray array];
    }
    if([self.recycleItems count] > 0) {
        SpringBoardItemView *item = [self.recycleItems lastObject];
        [self.recycleItems removeObject:item];
        [item reset];
        return item;
    }
    return nil;
}

@end
