//
//  LCHomeNavigationController.m
//  lol
//
//  Created by Di Wu on 6/25/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCHomeNavigationController.h"
#import "LCHomeViewController.h"
#import "LCSearchBar.h"
#import "LCAppDelegate.h"
#import "LCSettingsController.h"
#import "LCSummonerShowController.h"
#import "LCSummonerSearchController.h"
#import "LCGameTabBarController.h"
#import "LCSettingsInfo.h"
#import <REMenu/REMenu.h>

static NSString * const kHideLogoutAlert = @"hideLogoutAlert";

@interface LCHomeNavigationController () <UISearchBarDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) LCSearchBar *searchBar;
@property (nonatomic, strong) REMenu *menu;

- (void)showMenu;
- (void)showSearchBar;
- (void)menuNavigationItemForViewController:(UIViewController *)viewController;
- (void)addBackgroundCoverViewToCurrentViewController;
- (void)removeBackgroundCoverViewFromCurrentViewController;

- (BOOL)shouldResetNavigationBarItemWithViewController:(UIViewController *)viewController;
- (void)logout;
@end

@implementation LCHomeNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)loadView {
  [super loadView];
  self.delegate = self;
  [self menu];
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (REMenu *)menu {
  if (nil == _menu) {
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:NSLocalizedString(@"home", nil) subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item){
      LCAppDelegate *delegate = [UIApplication sharedApplication].delegate;
      [delegate rebuildHomeRootViewController];
    }];

    REMenuItem *settingsItem = [[REMenuItem alloc] initWithTitle:NSLocalizedString(@"settings", nil) subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item) {
      LCSettingsController *settingsController = [[LCSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
      [self pushViewController:settingsController animated:NO];
    }];

    REMenuItem *logOutItem = [[REMenuItem alloc] initWithTitle:NSLocalizedString(@"logout", nil) subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item) {

      BOOL hideLogoutAlert = [[NSUserDefaults standardUserDefaults] boolForKey:kHideLogoutAlert];
      if (hideLogoutAlert) {
        [self logout];
        return ;
      }

      SIAlertView *alterView = [SIAlertView carryuAlertWithTitle:nil message:NSLocalizedString(@"logout_tip", nil)];
      [alterView addButtonWithTitle:NSLocalizedString(@"dont_show_me_again", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:kHideLogoutAlert];
        [userDefaults synchronize];
      }];
      alterView.buttonFont = [UIFont flatFontOfSize:13];
      alterView.willDismissHandler = ^(SIAlertView *alertView) {
        [self logout];
      };
      [alterView show];

    }];

    self.menu = [[REMenu alloc] initWithItems:@[homeItem, settingsItem, logOutItem]];
  }
  return _menu;
}

- (UISearchBar *)searchBar {
  if (nil == _searchBar) {
    self.searchBar = [[LCSearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 32)];
    _searchBar.delegate = self;

    _searchBar.placeholder = NSLocalizedString(@"search_placeholder", nil);
    _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor midnightBlueColor] cornerRadius:0];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:nil forState:UIControlStateNormal];
  }
  return _searchBar;
}

- (void)showMenu {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  if ([appDelegate.stateMachine isInState:@"inGame"]) {
    [[self.menu.items objectAtIndex:0] setTitle:NSLocalizedString(@"in_game", nil)];
  } else {
    [[self.menu.items objectAtIndex:0] setTitle:NSLocalizedString(@"home", nil)];
  }
  if ([self.menu isOpen]) {
    [self.menu close];
  } else {
    [self.menu showFromNavigationController:self];
  }
}

- (void)showSearchBar {
  self.visibleViewController.navigationItem.titleView = self.searchBar;
  self.visibleViewController.navigationItem.leftBarButtonItem = nil;
  self.visibleViewController.navigationItem.rightBarButtonItem = nil;
  [self addBackgroundCoverViewToCurrentViewController];
  [_searchBar setShowsCancelButton:YES];
  [_searchBar becomeFirstResponder];
}

- (void)addBackgroundCoverViewToCurrentViewController {
  self.searchBar.backgroundCoverView.frame = self.visibleViewController.view.bounds;
  [self.visibleViewController.view addSubview:self.searchBar.backgroundCoverView];
}

- (void)removeBackgroundCoverViewFromCurrentViewController {
  [self.searchBar.backgroundCoverView removeFromSuperview];
}

- (void)logout {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate logout];
}

#pragma mark - search delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  NIDPRINT(@"search did clicked");
  [self.searchBar resignFirstResponder];
  if (self.searchBar.text.length) {
    NSURL *searchUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[LCSettingsInfo sharedInstance].searchEngine, [self.searchBar.text stringByAddingPercentEscapesForURLParameter]]];
    LCSummonerSearchController *webController = [[LCSummonerSearchController alloc] initWithURL:searchUrl];
    [self pushViewController:webController animated:NO];
  }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self removeBackgroundCoverViewFromCurrentViewController];
  [self.searchBar resignFirstResponder];
  [self menuNavigationItemForViewController:self.visibleViewController];
}

- (BOOL)shouldResetNavigationBarItemWithViewController:(UIViewController *)viewController {
  UIViewController *contentViewController = viewController;
  if ([contentViewController isKindOfClass:[LCSummonerShowController class]]
      || [contentViewController isKindOfClass:[LCSampleGameTabBarController class]]) {
    return NO;
  }

  return YES;
}

#pragma mark - navigation delegate 

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (![self shouldResetNavigationBarItemWithViewController:viewController]) {
    return;
  }
  viewController.navigationItem.hidesBackButton = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (![self shouldResetNavigationBarItemWithViewController:viewController]) {
    return;
  }
  [self menuNavigationItemForViewController:viewController];
  self.viewControllers = [self.viewControllers select:^BOOL(id obj) {
    return obj == viewController;
  }];
  NIDPRINT(@"viewcontroller size => %d", self.viewControllers.count);
}

- (void)menuNavigationItemForViewController:(UIViewController *)viewController {
  UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
  viewController.navigationItem.leftBarButtonItem = leftBarButtonItem;
  UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
  viewController.navigationItem.rightBarButtonItem = rightBarButtonItem;
  viewController.navigationItem.titleView = nil;
}
@end

@implementation LCADHomeViewController {
  ADBannerView *_bannerView;
}

- (instancetype)initWithContentViewController:(UIViewController *)contentController
{
  // If contentController is nil, -loadView is going to throw an exception when it attempts to setup
  // containment of a nil view controller.  Instead, throw the exception here and make it obvious
  // what is wrong.
  NSAssert(contentController != nil, @"Attempting to initialize a BannerViewController with a nil contentController.");

  self = [super init];
  if (self != nil) {
    // On iOS 6 ADBannerView introduces a new initializer, use it when available.
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
      _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
      _bannerView = [[ADBannerView alloc] init];
    }
    _contentController = contentController;
    _bannerView.delegate = self;
  }
  return self;
}

- (void)loadView
{
  UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  [contentView addSubview:_bannerView];

  // Setup containment of the _contentController.
  [self addChildViewController:_contentController];
  [contentView addSubview:_contentController.view];
  [_contentController didMoveToParentViewController:self];

  self.view = contentView;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return [_contentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
#endif

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return [_contentController preferredInterfaceOrientationForPresentation];
}

- (NSUInteger)supportedInterfaceOrientations
{
  return [_contentController supportedInterfaceOrientations];
}

- (void)viewDidLayoutSubviews
{
  // This method will be called whenever we receive a delegate callback
  // from the banner view.
  // (See the comments in -bannerViewDidLoadAd: and -bannerView:didFailToReceiveAdWithError:)

  CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
  // If configured to support iOS <6.0, then we need to set the currentContentSizeIdentifier in order to resize the banner properly.
  // This continues to work on iOS 6.0, so we won't need to do anything further to resize the banner.
  if (contentFrame.size.width < contentFrame.size.height) {
    _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
  } else {
    _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
  }
  bannerFrame = _bannerView.frame;
#else
  // If configured to support iOS >= 6.0 only, then we want to avoid currentContentSizeIdentifier as it is deprecated.
  // Fortunately all we need to do is ask the banner for a size that fits into the layout area we are using.
  // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
  bannerFrame.size = [_bannerView sizeThatFits:contentFrame.size];
#endif

  // Check if the banner has an ad loaded and ready for display.  Move the banner off
  // screen if it does not have an ad.
  if (_bannerView.bannerLoaded) {
    contentFrame.size.height -= bannerFrame.size.height;
    bannerFrame.origin.y = contentFrame.size.height;
  } else {
    bannerFrame.origin.y = contentFrame.size.height;
  }
  _contentController.view.frame = contentFrame;
  _bannerView.frame = bannerFrame;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
  [UIView animateWithDuration:0.25 animations:^{
    // -viewDidLayoutSubviews will handle positioning the banner such that it is either visible
    // or hidden depending upon whether its bannerLoaded property is YES or NO (It will be
    // YES if -bannerViewDidLoadAd: was last called).  We just need our view
    // to (re)lay itself out so -viewDidLayoutSubviews will be called.
    // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
    // as requiring layout...
    [self.view setNeedsLayout];
    // ...then ask it to lay itself out immediately if it is flagged as requiring layout...
    [self.view layoutIfNeeded];
    // ...which has the same effect.
  }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
  [UIView animateWithDuration:0.25 animations:^{
    // -viewDidLayoutSubviews will handle positioning the banner such that it is either visible
    // or hidden depending upon whether its bannerLoaded property is YES or NO (It will be
    // NO if -bannerView:didFailToReceiveAdWithError: was last called).  We just need our view
    // to (re)lay itself out so -viewDidLayoutSubviews will be called.
    // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
    // as requiring layout...
    [self.view setNeedsLayout];
    // ...then ask it to lay itself out immediately if it is flagged as requiring layout...
    [self.view layoutIfNeeded];
    // ...which has the same effect.
  }];
}



@end
