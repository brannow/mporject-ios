//
//  SearchViewController.m
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 28.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(close:)];
    [self.navigationItem setRightBarButtonItem:searchItem animated:YES];
    
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)detailTest:(id)sender {
    DetailViewController* detailController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
