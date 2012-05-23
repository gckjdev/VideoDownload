//
//  BrowseController.m
//  Download
//
//  Created by  on 11-11-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BrowseController.h"
#import "DownloadWebViewController.h"
#import "UIViewUtils.h"
#import "LocaleUtils.h"
#import "StringUtil.h"
#import "DownloadResource.h"
#import "UIViewController+DownloadViewControllerAddition.h"
#import "DownloadAd.h"
#import "GADBannerView.h"

@implementation BrowseController
@synthesize browseTextField;
@synthesize wordsView;
@synthesize browseButton;
@synthesize commonlyUsedWordsLabel;
@synthesize innerBackgroundView;
@synthesize bannerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (NSArray*)getKeywords
{
    if ([LocaleUtils isChina]){
        return [NSArray arrayWithObjects:NSLS(@"www."), NSLS(@".com"), 
                NSLS(@"mp3"), NSLS(@"视频"), NSLS(@"电子书"), NSLS(@"下载"), 
                NSLS(@"音乐"), NSLS(@"相声"), nil];                
    }
    else{
        return [NSArray arrayWithObjects:NSLS(@"www."), NSLS(@".com"), 
         NSLS(@"mp3"), NSLS(@"video"), NSLS(@"download"), nil];        
    }
}

- (NSString*)getSearchEngine
{
    if ([LocaleUtils isChina])
        return @"http://www.baidu.com/s?wd=";
    else
        return @"http://www.google.com/search?q=";
}

- (NSString*)getDefaultSite
{
    if ([LocaleUtils isChina])
        return @"http://www.baidu.com";
    else
        return @"http://www.google.com";
    
}

- (void)viewDidLoad
{    
    [self setDownloadNavigationTitle:NSLS(@"kThirdViewTitle")];
    [self setDownloadRightBarButton:NSLS(@"kGotoWebView") selector:@selector(clickGotoWebView:)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    NSArray* keywords = [self getKeywords];
    
    UIButton* keywordTemplateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [keywordTemplateButton.titleLabel setFont:[UIFont systemFontOfSize:KEYWORD_FONT_SIZE]];
    [keywordTemplateButton setTitleColor:KEYWORD_UICOLOR forState:UIControlStateNormal];    
    
    [wordsView createButtonsInView:keywords templateButton:keywordTemplateButton target:self action:@selector(clickKeyword:)];
    [wordsView setBackgroundColor:[UIColor clearColor]];
    
    [self.browseTextField setBackground:BROSWER_TEXTFIELD_BG_IMAGE];
    //add indentation
    UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 31)] autorelease];
    self.browseTextField.leftView = paddingView;
    self.browseTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.innerBackgroundView setImage:BROSWER_INNER_BG_IMAGE];
    
    [self.view setBackgroundImageView:BROWSER_BG];
    
    [self.browseButton setTitle:NSLS(@"kBrowseButtonTitle") forState:UIControlStateNormal];
    [self.browseButton setBackgroundImage:BROSWER_VISIT_BG_IMAGE forState:UIControlStateNormal];
    [self.browseButton setBackgroundImage:BROSWER_VISITED_BG_IMAGE forState:UIControlStateSelected];
    
    [self.commonlyUsedWordsLabel setText:NSLS(@"kCommonlyUsedWordsLabel")];    
    
    self.browseTextField.text = [self getDefaultSite];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (bannerView == nil){  
        bannerView = [DownloadAd allocAdMobView:self];
    }
    
    [self addBlankView:70 currentResponder:browseTextField];    
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setBrowseTextField:nil];
    [self setBrowseButton:nil];
    [self setCommonlyUsedWordsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickBrowse:(id)sender
{
    [self.view endEditing:YES];
    
    NSString* searchEngineURL = [self getSearchEngine];    
    NSString* text = browseTextField.text;
    if ([text rangeOfString:@"."].location != NSNotFound){
        if ([text hasPrefix:@"http://"] == NO){
            text = [@"http://" stringByAppendingString:text];
        }
    }
    else{
        text = [searchEngineURL stringByAppendingString:text];
    }
    
    [DownloadWebViewController show:self url:text];
    
}

- (IBAction)clickGotoWebView:(id)sender
{
    [DownloadWebViewController show:self url:nil];    
}

- (void)clickKeyword:(id)sender
{
    NSString* text = [((UIButton*)sender) currentTitle];
    
    if (browseTextField.text == nil){
        browseTextField.text = text;
    }
    else{
        browseTextField.text = [browseTextField.text stringByAppendingString:text];
    }
}

- (void)dealloc {
    [wordsView release];
    [browseTextField release];
    [browseButton release];
    [commonlyUsedWordsLabel release];
    [innerBackgroundView release];
    [bannerView release];
    [super dealloc];
}
@end
