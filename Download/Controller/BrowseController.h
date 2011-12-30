//
//  BrowseController.h
//  Download
//
//  Created by  on 11-11-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

@interface BrowseController : PPViewController

- (IBAction)clickBrowse:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *browseTextField;
@property (retain, nonatomic) IBOutlet UIView *wordsView;
@property (retain, nonatomic) IBOutlet UIButton *browseButton;
@property (retain, nonatomic) IBOutlet UILabel *commonlyUsedWordsLabel;
@property (retain, nonatomic) IBOutlet UIImageView *innerBackgroundView;

@end
