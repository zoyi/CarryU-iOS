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
#import "LCChampion.h"
#import "LCSummonerViewController.h"
#import "LCAppDelegate.h"
#import "LCStateView.h"
#import "XMPPIQ+LCCategory.h"
#import "XMPPPresence+LCCategory.h"
#import "LCServerInfo.h"
#import "LCCurrentSummoner.h"
#import "LCGuidesWebController.h"
#import "UIBarButtonItem+LCCategory.h"

@interface LCGameTabBarController ()
- (NSString *)guidesUrlPath;
- (NSString *)GAIScreenName;
- (NSString *)controllerTitle;
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

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[GAI sharedInstance].defaultTracker sendView:[self GAIScreenName]];
}

- (NSString *)GAIScreenName {
  return @"/InGameTabScreen";
}

- (NSString *)controllerTitle {
  if (_game.lcGameMode == kNormalGame) {
    return NSLocalizedString(@"Normal_navi_title", nil);
  } else if (_game.lcGameMode == kRankedGame) {
    return NSLocalizedString(@"Ranked_navi_title", nil);
  }
  return NSLocalizedString(@"Activated_navi_title", nil);
}

#pragma mark - setter

- (void)setGame:(LCGame *)game {
  if (game != _game) {
    _game = game;

    LCSummonerViewController *ourTeamController = [[LCSummonerViewController alloc] initWithSummoners:_game.playerTeam gameMode:_game.lcGameMode];
    ourTeamController.tabBarItem.title = NSLocalizedString(@"my_team_tab_title", nil);
    [ourTeamController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"myteam.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"myteam.png"]];

    LCSummonerViewController *enemyTeamController = [[LCSummonerViewController alloc] initWithSummoners:_game.enemyTeam gameMode:_game.lcGameMode];
    enemyTeamController.tabBarItem.title = NSLocalizedString(@"enemies_team_tab_title", nil);
    [enemyTeamController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"enemies_icon.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"enemies_icon.png"]];

   
    LCGuidesWebController *webController = [[LCGuidesWebController alloc] initWithURL:[NSURL URLWithString:[self guidesUrlPath]]];
    webController.tabBarItem.title = NSLocalizedString(@"guides_tab_title", nil);
    [webController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tips.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tips.png"]];

    self.viewControllers = @[ourTeamController, enemyTeamController, webController];
    self.title = self.controllerTitle;
  }
}

- (NSString *)guidesUrlPath {
  NSString *baseUrl = [LCServerInfo sharedInstance].currentServer.railsHost.absoluteString;
  __block NSNumber *championId = nil;
  [_game.playerTeam each:^(LCSummoner *summoner) {
    if ([summoner.name caseInsensitiveCompare:[LCCurrentSummoner sharedInstance].name] == NSOrderedSame) {
      championId = summoner.champion.cid;
    }
  }];

  if (!championId) {
    [_game.enemyTeam each:^(LCSummoner *summoner) {
      if ([summoner.name caseInsensitiveCompare:[LCCurrentSummoner sharedInstance].name] == NSOrderedSame) {
        championId = summoner.champion.cid;
      }
    }];
  }

  if (!championId) {
    championId = [NSNumber numberWithInteger:98];
  }
  
  return [NSString stringWithFormat:@"%@/champions/%@/guides", baseUrl, championId];
}

@end

@implementation LCSampleGameTabBarController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.leftBarButtonItem = [UIBarButtonItem carryuBackBarButtonItem];
}

- (NSString *)controllerTitle {
  return  NSLocalizedString(@"sample_game_title", nil);
}

- (NSString *)GAIScreenName {
  return @"/HomeScreen/SampleGameTabScreen";
}

@end
