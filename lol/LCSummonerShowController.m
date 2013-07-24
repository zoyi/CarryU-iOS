//
//  LCSummonerShowController.m
//  lol
//
//  Created by Di Wu on 6/28/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummonerShowController.h"
#import "LCGameTabBarController.h"
#import "UIBarButtonItem+LCCategory.h"

@interface LCSummonerShowController ()

@end

@implementation LCSummonerShowController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!self.tabBarController) {
    [[GAI sharedInstance].defaultTracker sendView:@"/HomeScreen/ChampionSelectScreen/SummonerShow"];
  } else if ([self.tabBarController isKindOfClass:[LCGameTabBarController class]]) {
    [[GAI sharedInstance].defaultTracker sendView:@"/InGameTabScreen/SummonerShow"];
  } else if ([self.tabBarController isKindOfClass:[LCSampleGameTabBarController class]]) {
    [[GAI sharedInstance].defaultTracker sendView:@"/HomeScreen/SampleGameTabScreen/SummonerShow"];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.navigationItem.hidesBackButton = YES;
  self.navigationItem.leftBarButtonItem = [UIBarButtonItem carryuBackBarButtonItem];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  [super webView:webView didFailLoadWithError:error];
#ifdef TESTFLIGHT
  TFLog(@"Web View did fail load with error => %@", error.debugDescription);
#endif
}

@end
