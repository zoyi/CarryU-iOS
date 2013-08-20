//
//  LCSummonerViewController.m
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummonerViewController.h"
#import "LCSummoner.h"
#import "LCSummonerCell.h"
#import "LCSummonerCellObject.h"
#import "LCSummonerShowController.h"
#import "LCGameTabBarController.h"
#import "LCSettingsInfo.h"

@interface LCSummonerViewController ()
@property (nonatomic, strong) NITableViewModel *model;
@property (nonatomic, strong) NITableViewActions *actions;
- (void)resetModel;
@end

@implementation LCSummonerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSummoners:(NSArray *)summoners gameMode:(LCGameMode)gameMode {
  self = [super initWithStyle:UITableViewStylePlain activityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  if (self) {
    self.summoners = summoners;
    self.gameMode = gameMode;
  }
  return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if ([self.tabBarController isKindOfClass:[LCGameTabBarController class]]) {
    [[GAI sharedInstance].defaultTracker sendView:@"/InGameTabScreen/Team"];
  } else if ([self.tabBarController isKindOfClass:[LCSampleGameTabBarController class]]) {
    [[GAI sharedInstance].defaultTracker sendView:@"/HomeScreen/SampleGameTabScreen/Team"];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.actions = [[NITableViewActions alloc] initWithTarget:self];
  [self model];
  self.tableView.delegate = [self.actions forwardingTo:self];
  
  self.tableView.rowHeight = kSummonerCellDefaultHeight;
  self.tableView.backgroundView = self.backgroundView;
  self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
}

- (NITableViewModel *)model {
  if (nil == _model) {
    NSMutableArray *tableContents = [NSMutableArray arrayWithCapacity:5];
    [_summoners each:^(LCSummoner *summoner) {
      [tableContents addObject:[[LCSummonerCellObject alloc] initWithCellClass:[LCSummonerCell class] summoner:summoner gameMode:_gameMode delegate:self.tableView]];
    }];
    [_actions attachToClass:[LCSummonerCellObject class] tapBlock:^BOOL(LCSummonerCellObject *object, id target) {
      NIDPRINT(@"object is => %@", object.debugDescription);
      NSURL *summonerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[LCSettingsInfo sharedInstance].searchEngine, [object.summoner.name stringByAddingPercentEscapesForURLParameter]]];

      LCSummonerShowController *webController = [[LCSummonerShowController alloc] initWithURL:summonerUrl];

      [self.navigationController pushViewController:webController animated:YES];
      return YES;
    }];
    self.model = [[NITableViewModel alloc] initWithListArray:tableContents delegate:(id)[NICellFactory class]];
    self.tableView.dataSource = _model;
  }
  return _model;
}

- (UIImageView *)backgroundView {
  if (nil == _backgroundView) {
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  }
  return _backgroundView;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTableView{
  [super refreshTableView];
  [self resetModel];
}

- (void)resetModel {
  self.model = nil;
  // init level for update
  [_summoners each:^(LCSummoner *summoner) {
    summoner.level = 0;
  }];
  [self model];
  [self.tableView reloadData];
}

@end
