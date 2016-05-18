//
//  SearchViewController.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 28.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) UIViewController *delegate;

@end
