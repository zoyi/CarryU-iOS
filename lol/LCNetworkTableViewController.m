//
//  LCNetworkTableViewController.m
//  lol
//
//  Created by Di Wu on 7/1/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCNetworkTableViewController.h"
#import "LCAppDelegate.h"
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
  [self refreshControl];
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
    LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [_refreshControl addTarget:appDelegate action:@selector(refreshXmppPrecense:) forControlEvents:UIControlEventValueChanged];
  }
  return _refreshControl;
}

@end
