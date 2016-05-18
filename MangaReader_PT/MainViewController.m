//
//  MainViewController.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "SpringBoardView.h"
#import "SpringBoardFolderView.h"
#import "SpringBoardItemView.h"
#import "ImageCache.h"

#import "SearchViewController.h"
#import "DetailViewController.h"
#import "NavigationViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) ImageCache *imageCache;
@property (nonatomic) BOOL hasUpdates;


@property (weak, nonatomic) IBOutlet UIVisualEffectView *editBottomBarView;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hasUpdates = YES;
        self.imageCache = [[ImageCache alloc] init];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self enterSpringboardDefaultMode];
}

- (void) enterSpringboardDefaultMode
{
    [self hideEditBottomBar];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                target:self
                                                                                action:@selector(searchButtonItemClicked:)];
    [self.navigationItem setRightBarButtonItem:searchItem animated:YES];
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(editButtonItemClicked:)];
    [self.navigationItem setLeftBarButtonItem:edit animated:YES];
}

- (void) enterSpringBoardEditMode
{
    [self showEditBottomBar];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(searchButtonItemClicked:)];
    [self.navigationItem setRightBarButtonItem:searchItem animated:YES];
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(doneButtonItemClicked:)];
    [self.navigationItem setLeftBarButtonItem:edit animated:YES];
}

- (void) showEditBottomBar
{
    self.editBottomBarView.hidden = NO;
}

- (void) hideEditBottomBar
{
    self.editBottomBarView.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.hasUpdates) {
        self.hasUpdates = NO;
        [self.springBoard reload];
    }
}

- (void) searchButtonItemClicked:(UIBarButtonItem*)item
{
    SearchViewController *searchController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    searchController.delegate = self;
    searchController.title = @"Search";
    NavigationViewController *searchNaviController = [[NavigationViewController alloc] initWithRootViewController:searchController];
    searchNaviController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:searchNaviController animated:YES completion:^{}];
}

- (void) editButtonItemClicked:(UIBarButtonItem*)item
{
    [self enterSpringBoardEditMode];
}

- (void) doneButtonItemClicked:(UIBarButtonItem*)item
{
    [self enterSpringboardDefaultMode];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if(self.springBoard != nil) {
        [self.springBoard reload];
    }
    if(self.imageCache != nil) {
        [self.imageCache clearCache];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma SpringBoard MainView

- (NSInteger) numberOfFolderInSpringBoard:(SpringBoardView*)master
{
    return 10;
}

- (SpringBoardFolderView*) springBoardFolder:(SpringBoardView*)master withIndex:(NSInteger)index
{
    SpringBoardFolderView *folder = [master obtainRecycledSpringBoardFolder];
    if(folder == nil) {
        folder = [[SpringBoardFolderView alloc] init];
    }
    
    [folder setName:[NSString stringWithFormat:@"Name %lu", (long)index]];
    
    return folder;
}

- (void) activeSpringBoardFolder:(SpringBoardFolderView*)folder
{
    self.navigationItem.title = folder.name;
}

#pragma SpringBoard FolderView

- (NSInteger) numberOfItemInSpringBoardFolder:(SpringBoardFolderView*)folder
                                      atIndex:(NSInteger)index
{
    return 100;
}

- (SpringBoardItemView*) springBoardItem:(SpringBoardFolderView*)folder
                                 atIndex:(NSUInteger)index;
{
    SpringBoardItemView *item = [folder obtainRecycledSpringBoardItem];
    if(item == nil) {
        item = [[SpringBoardItemView alloc] init];
    }
    
    //[item setBackgroundColor:[UIColor blueColor]];
    NSString *name = [NSString stringWithFormat:@"cover_%lu", (long)index%8];
    [item setImage:[self.imageCache imageNamed:name]];
    return item;
}

- (void) springBoardFolder:(SpringBoardFolderView*)folder
               itemSeleced:(SpringBoardItemView*)item
                   atIndex:(NSInteger)index
{
    DetailViewController* detailController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    detailController.title = [NSString stringWithFormat:@"Item %lu", index];
    [self.navigationController pushViewController:detailController animated:YES];
    /*CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:8];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([item center].x - 5.0f, [item center].y - 5.0f)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([item center].x + 5.0f, [item center].y + 5.0f)]];
    [[item layer] addAnimation:animation forKey:@"position"];*/
}

@end
