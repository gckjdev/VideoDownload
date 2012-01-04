//
//  DownloadAppDelegate.m
//  Download
//
//  Created by  on 11-11-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DownloadAppDelegate.h"
#import "UIUtils.h"
#import "ReviewRequest.h"
#import "DeviceDetection.h"
#import "UINavigationBarExt.h"

#import "BrowseController.h"
#import "DownloadManageController.h"
#import "TopDownloadController.h"
#import "ResourceCategoryController.h"
#import "AboutController.h"
#import "VideoPlayController.h"
#import "BookController.h"
#import "WallpaperController.h"
#import "MusicPlayController.h"
#import "DownloadService.h"
#import "ResourceService.h"

#import "DownloadResource.h"

#define MUSICPLAYER_TAB 4
#define WALLPAPER_TAB 4
#define VIDEOPLAYER_TAB 4
#define BOOK_TAB 4

NSString* GlobalGetServerURL()
{
    //   return @"http://192.168.1.101:8000/api/i?";
    
    return @"http://www.dipan100.com/api/i?";
    
    
//    return @"http://192.168.1.188:8000/api/i?";
    
}

enum TAB_INDEX {
    TAB_TOP = 0,
    TAB_SITE,
    TAB_BROWSE
    };

@implementation DownloadAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize dataManager;
@synthesize reviewRequest;

- (NSString *)appKey
{
    return kMobClickKey;
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (void)initTabViewControllers
{
    
    if ([DeviceDetection isOS5]){
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"tu_17.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else{
        GlobalSetNavBarBackground(@"tu_17.png");        
    }
    
    self.tabBarController = [[[PPTabBarController alloc] init] autorelease];
    
    self.tabBarController.delegate = self;
    [self.tabBarController setBarBackground:TABBAR_BACKGROUND];
    [self.tabBarController setTextColor:BAR_BUTTON_TEXT_NORMAL_COLOR
                        selectTextColor:BAR_BUTTON_TEXT_COLOR];
    self.tabBarController.buttonStyle = TAB_BUTTON_STYLE_ICON;    
    self.tabBarController.selectedIndex = 0;
    
    self.tabBarController.animation = CubeTabBarControllerAnimationOutside;
    self.tabBarController.backgroundColor = [UIColor blackColor];
    
    
	NSMutableArray* controllers = [[NSMutableArray alloc] init];
    
	[UIUtils addViewController:[TopDownloadController alloc]
					 viewTitle:NSLS(@"kFirstViewTitle")
					 viewImage:TOP_ICON
			  hasNavController:YES			
			   viewControllers:controllers];	
    
	[UIUtils addViewController:[ResourceCategoryController alloc]
					 viewTitle:NSLS(@"kSecondViewTitle")
					 viewImage:RESOURCE_ICON
			  hasNavController:YES			
			   viewControllers:controllers];	
    
	[UIUtils addViewController:[BrowseController alloc]
                     viewTitle:NSLS(@"kThirdViewTitle")				 
                     viewImage:BROWSE_ICON
              hasNavController:YES			
               viewControllers:controllers];

	[UIUtils addViewController:[DownloadManageController alloc]
					 viewTitle:NSLS(@"kFourthViewTitle")				 
					 viewImage:DOWNLOAD_ICON
			  hasNavController:YES			
			   viewControllers:controllers];
	
    [UIUtils addViewController:[VideoPlayController alloc]
					 viewTitle:NSLS(@"kVideo")				 
					 viewImage:DOWNLOAD_ICON
			  hasNavController:YES			
			   viewControllers:controllers];
	    
//    [UIUtils addViewController:[AboutController alloc]
//                     viewTitle:NSLS(@"Settings")
//                     viewImage:ABOUT_ICON
//              hasNavController:YES			
//               viewControllers:controllers];	        
    
    [self.tabBarController setSelectedImageArray:[NSArray arrayWithObjects:
                                                  TOP_PRESS_ICON, 
                                                  RESOURCE_PRESS_ICON, 
                                                  BROWSE_PRESS_ICON, 
                                                  DOWNLOAD_PRESS_ICON,
                                                  DOWNLOAD_PRESS_ICON,
//                                                  ABOUT_PRESS_ICON, 
                                                  nil]];
    	
	self.tabBarController.viewControllers = controllers;	
    self.tabBarController.selectedIndex = TAB_BROWSE;
	[controllers release];
}

- (void)initMobClick
{
    [MobClick setDelegate:self reportPolicy:BATCH];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[WebViewTouchWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self initTabViewControllers];
    
    self.dataManager = [[CoreDataManager alloc] initWithDBName:kDbFileName dataModelName:nil];
//    workingQueue = dispatch_queue_create("main working queue", NULL);    
    
    // init service
    [DownloadService defaultService];   
    [ResourceService defaultService];
	[self initMobClick];
    
    // test

    // Ask For Review
	self.reviewRequest = [ReviewRequest startReviewRequest:kAppId appName:GlobalGetAppName() isTest:NO];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // init iCloud
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        NSLog(@"AppDelegate: iCloud access!");
//        [self loadDocument];
    } else {
        NSLog(@"AppDelegate: No iCloud access (either you are using simulator or, if you are on your phone, you should check settings");
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [MobClick appTerminated];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [[NSUserDefaults standardUserDefaults] synchronize];
//	[self releaseResourceForAllViewControllers];	
    
    
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DownloadService defaultService] pauseAllDownloadItem];
            if (UIBackgroundTaskInvalid != backgroundTask) {
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    NSLog(@"Background Task Remaining Time = %f", [application backgroundTimeRemaining]);
    if (UIBackgroundTaskInvalid != backgroundTask) {
    }		

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [MobClick appLaunched];
    [[DownloadService defaultService] resumeAllDownloadItem];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [MobClick appTerminated];
}


// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
//    if ([viewController isMemberOfClass:[VideoPlayController class]]) {
//    }
    
}


/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void) setSeletedTabbarIndex:(NSInteger)index
{
    UIButton *button = [_tabBarController.buttons objectAtIndex:index];
    [_tabBarController selectedTab:button];
}

// for Music
- (BOOL)hasMusicPlayerTab
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFHasMusicPlayerTab"]boolValue];
}

- (void) gotoMusicPlayerTab
{
    [self setSeletedTabbarIndex:MUSICPLAYER_TAB];
}

- (MusicPlayController*) getMusicPlayerTab
{
    return (MusicPlayController*)([[self.tabBarController.viewControllers objectAtIndex:MUSICPLAYER_TAB] topViewController]);
}
// for Wallpaper
- (BOOL)hasWallpaperTab
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFHasWallpaperTab"]boolValue];
}

- (void) gotoWallpaperTab
{
    [self setSeletedTabbarIndex:WALLPAPER_TAB];
}

- (WallpaperController*) getWallpaperTab
{
    return (WallpaperController*)([[self.tabBarController.viewControllers objectAtIndex:WALLPAPER_TAB] topViewController]);
} 

// for Video
- (BOOL)hasVideoPlayerTab
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFHasVideoPlayerTab"]boolValue];
}

- (void) gotoVideoPlayerTab
{
    [self setSeletedTabbarIndex:VIDEOPLAYER_TAB];
}

- (VideoPlayController*) getVideoPlayerTab
{
    return (VideoPlayController*)([[self.tabBarController.viewControllers objectAtIndex:VIDEOPLAYER_TAB] topViewController]);
}

// for Book

- (BOOL)hasBookTab
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFHasBookTab"]boolValue];
}

- (void) gotoBookTab
{
    [self setSeletedTabbarIndex:BOOK_TAB];
}

- (BookController*) getBookTab
{
    return (BookController*)([[self.tabBarController.viewControllers objectAtIndex:BOOK_TAB] topViewController]);
}




@end
