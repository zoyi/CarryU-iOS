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
#import "LCSettingsInfo.h"
#import <REMenu/REMenu.h>

@interface LCHomeNavigationController () <UISearchBarDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) LCSearchBar *searchBar;
@property (nonatomic, strong) REMenu *menu;

- (void)showMenu;
- (void)showSearchBar;
- (void)menuNavigationItemForViewController:(UIViewController *)viewController;
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
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Home" subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item){
      if ([item.title isEqualToString:@"Home"]) {
        LCHomeViewController *homeViewController = [[LCHomeViewController alloc] initWithStyle:UITableViewStylePlain];
        [self pushViewController:homeViewController animated:NO];
      } else {
        LCAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate showInGameTabController];
      }
    }];

    REMenuItem *settingsItem = [[REMenuItem alloc] initWithTitle:@"Settings" subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item) {
      LCSettingsController *settingsController = [[LCSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
      [self pushViewController:settingsController animated:NO];
    }];

    REMenuItem *logOutItem = [[REMenuItem alloc] initWithTitle:@"Log Out" subtitle:nil image:nil highlightedImage:nil action:^(REMenuItem *item) {
      LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
      [appDelegate logout];
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
    [[self.menu.items objectAtIndex:0] setTitle:@"In Game"];
  } else {
    [[self.menu.items objectAtIndex:0] setTitle:@"Home"];
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
  [_searchBar setShowsCancelButton:YES];
  [_searchBar becomeFirstResponder];
}

#pragma mark - search delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  NIDPRINT(@"search did clicked");
  [self.searchBar resignFirstResponder];
  if (self.searchBar.text.length) {
    NSString *searchUrlpath = [NSString stringWithFormat:@"%@%@",[LCSettingsInfo sharedInstance].searchEngine, [self.searchBar.text stringByAddingPercentEscapesForURLParameter]];
    LCSummonerSearchController *webController = [[LCSummonerSearchController alloc] initWithURL:[NSURL URLWithString:searchUrlpath]];
    [self pushViewController:webController animated:NO];
  }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self.searchBar resignFirstResponder];
  [self menuNavigationItemForViewController:self.visibleViewController];
}

#pragma mark - navigation delegate 

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if ([viewController isKindOfClass:[LCSummonerShowController class]]) {
    return;
  }
  viewController.navigationItem.hidesBackButton = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if ([viewController isKindOfClass:[LCSummonerShowController class]]) {
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
