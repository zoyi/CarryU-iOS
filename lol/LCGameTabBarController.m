//
//  LCGameTabBarController.m
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCGameTabBarController.h"
#import "LCGame.h"
#import "LCSummoner.h"
#import "LCSummonerViewController.h"
#import "LCAppDelegate.h"
#import "LCStateView.h"
#import "XMPPIQ+LCCategory.h"
#import "XMPPPresence+LCCategory.h"

@interface LCGameTabBarController ()

@end

@implementation LCGameTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (id)initWithGame:(LCGame *)game {
  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    self.game = game;
  }
  return self;
}

- (void)loadView {
  [super loadView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor cloudsColor];
}

#pragma mark - setter

- (void)setGame:(LCGame *)game {
  if (game != _game) {
    _game = game;

    LCSummonerViewController *ourTeamController = [[LCSummonerViewController alloc] initWithSummoners:_game.playerTeam];
    ourTeamController.title = @"ourTeam";
    UINavigationController *ourTeamNavi = [[UINavigationController alloc] initWithRootViewController:ourTeamController];

    LCSummonerViewController *enemyTeamController = [[LCSummonerViewController alloc] initWithSummoners:_game.enemyTeam];
    enemyTeamController.title = @"enemyTeam";
    UINavigationController *enemyTeamNavi = [[UINavigationController alloc] initWithRootViewController:enemyTeamController];

    NIWebController *webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:@"http://m.inven.co.kr/site/lol/champ.php"]];
    webController.title = @"builds";

    self.viewControllers = @[ourTeamNavi, enemyTeamNavi, webController];
  }
}

@end
