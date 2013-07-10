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
#import "LCServerInfo.h"
#import "LCCurrentSummoner.h"
#import "LCTipWebController.h"
#import "UIBarButtonItem+LCCategory.h"

@interface LCGameTabBarController ()
- (NSString *)tipsUrlPath;
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
}

#pragma mark - setter

- (void)setGame:(LCGame *)game {
  if (game != _game) {
    _game = game;

    LCSummonerViewController *ourTeamController = [[LCSummonerViewController alloc] initWithSummoners:_game.playerTeam];
    ourTeamController.tabBarItem.title = NSLocalizedString(@"my_team_tab_title", nil);
    [ourTeamController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"myteam.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"myteam.png"]];

    LCSummonerViewController *enemyTeamController = [[LCSummonerViewController alloc] initWithSummoners:_game.enemyTeam];
    enemyTeamController.tabBarItem.title = NSLocalizedString(@"enemies_team_tab_title", nil);
    [enemyTeamController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"enemies_icon.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"enemies_icon.png"]];

   
    LCTipWebController *webController = [[LCTipWebController alloc] initWithURL:[NSURL URLWithString:[self tipsUrlPath]]];
    webController.tabBarItem.title = NSLocalizedString(@"tips_tab_title", nil);
    [webController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tips.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tips.png"]];

    //    webController.toolbarHidden = YES;
    self.viewControllers = @[ourTeamController, enemyTeamController, webController];
    self.title = NSLocalizedString(@"Activated_navi_title", nil);
  }
}

- (NSString *)tipsUrlPath {
  NSString *baseUrl = [LCServerInfo sharedInstance].currentServer.railsHost.absoluteString;
  __block NSNumber *championId = nil;
  [_game.playerTeam each:^(LCSummoner *summoner) {
    if ([summoner.sID isEqualToNumber:[LCCurrentSummoner sharedInstance].sID]) {
      championId = summoner.sID;
    }
  }];

  if (!championId) {
    [_game.enemyTeam each:^(LCSummoner *summoner) {
      if ([summoner.sID isEqualToNumber:[LCCurrentSummoner sharedInstance].sID]) {
        championId = summoner.sID;
      }
    }];
  }

  if (!championId) {
    championId = [NSNumber numberWithInteger:98];
  }
  
  return [NSString stringWithFormat:@"%@/champions/%@/tips", baseUrl, championId];
}

@end

@implementation LCSampleGameTabBarController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = NSLocalizedString(@"sample_game_title", nil);
  self.navigationItem.leftBarButtonItem = [UIBarButtonItem carryuBackBarButtonItem];
}

@end
