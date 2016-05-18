//
//  MainViewController.h
//  MangaReader_PT
//
//  Created by Benjamin Rannow on 07.10.15.
//  Copyright © 2015 Benjamin Rannow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpringBoardViewDelegate.h"
#import "SpringBoardFolderViewDelegate.h"

@class SpringBoardView;

@interface MainViewController : UIViewController <SpringBoardViewDelegate, SpringBoardFolderViewDelegate>

@property (weak, nonatomic) IBOutlet SpringBoardView *springBoard;

@end
