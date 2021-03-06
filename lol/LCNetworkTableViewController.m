//
//  LCNetworkTableViewController.m
//  lol
//
//  Created by Di Wu on 7/1/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCNetworkTableViewController.h"
#import "LCAppDelegate.h"
#import "LCGameTabBarController.h"

@interface LCNetworkTableViewController ()
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@end

@implementation LCNetworkTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
  [super loadView];
  if (!self.tabBarController || ![self.tabBarController isKindOfClass:[LCSampleGameTabBarController class]]) {
    [self refreshControl];
  }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ODRefreshControl *)refreshControl {
  if (nil == _refreshControl) {

    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    _refreshControl.tintColor = [UIColor carryuColor];
    _refreshControl.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [_refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
  }
  return _refreshControl;
}

- (void)refreshTableView {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate refreshXmppPrecense:_refreshControl];
}

@end
