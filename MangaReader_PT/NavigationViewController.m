//
//  NavigationViewController.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 18.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import "NavigationViewController.h"

@implementation NavigationViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
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

@end
