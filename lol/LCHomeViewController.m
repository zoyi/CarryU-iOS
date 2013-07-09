//
//  LCHomeViewController.m
//  lol
//
//  Created by Di Wu on 6/17/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCHomeViewController.h"
#import "LCAppDelegate.h"
#import "XMPPPresence+LCCategory.h"
#import "LCCurrentSummoner.h"
#import "LCStateView.h"
#import "LCSummoner.h"
#import "LCGame.h"
#import "LCSummonerCellObject.h"
#import "LCSummonerCell.h"
#import "LCGameTabBarController.h"
#import "LCSummonerShowController.h"
#import "XMPPIQ+LCCategory.h"
#import "LCSettingsInfo.h"
#import "LCOutOfGameView.h"
#import "LCInQueueStateView.h"

static NSString *kCurrentStateKey = @"currentState";
static NSString *kGameWillStartKey = @"gameWillStart";

@interface LCHomeViewController ()

@property (nonatomic, strong) NIMutableTableViewModel *model;
@property (nonatomic, strong) NITableViewActions *actions;

@property (nonatomic, strong) LCOutOfGameView *outOfGameView;
@property (nonatomic, strong) LCInQueueStateView *inQueueStateView;

- (void)resetModel;

- (void)fireInGameEvent;

- (void)showStateView;
@end

@implementation LCHomeViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [self initWithStyle:style activityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  if (self) {

  }
  return self;
}

- (void)loadView {
  [super loadView];
  [self resetModel];

  self.actions = [[NITableViewActions alloc] initWithTarget:self];
  [_actions attachToClass:[LCSummonerCellObject class] tapBlock:^BOOL(LCSummonerCellObject *object, id target) {
    NIDPRINT(@"object is => %@", object.debugDescription);
    
    LCSummonerShowController *webController = [[LCSummonerShowController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[LCSettingsInfo sharedInstance].searchEngine, [object.summoner.name stringByAddingPercentEscapesForURLParameter]]]];
    [self.navigationController pushViewController:webController animated:YES];
    return YES;
  }];
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  self.tableView.delegate = [_actions forwardingTo:self];
  self.tableView.rowHeight = kSummonerCellDefaultHeight;

  self.tableView.backgroundColor = [UIColor cloudsColor];
  CGRect viewBounds = self.view.bounds;
  viewBounds.size.height -= 44;
  self.outOfGameView.frame = viewBounds;
  self.inQueueStateView.frame = viewBounds;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

  [appDelegate.stateMachine addObserver:self forKeyPath:kCurrentStateKey options:NSKeyValueObservingOptionNew context:nil];
  [appDelegate addObserver:self forKeyPath:kGameWillStartKey options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
  [self showStateView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = NSLocalizedString(@"deactivated_navi_title", nil);
  self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate.stateMachine removeObserver:self forKeyPath:kCurrentStateKey context:nil];
  [appDelegate removeObserver:self forKeyPath:kGameWillStartKey context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([object isKindOfClass:[TKStateMachine class]]
      && [keyPath isEqualToString:kCurrentStateKey]) {
    [self showStateView];
  } else if ([keyPath isEqualToString:kGameWillStartKey]) {
    LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.gameWillStart.playerTeam.count
        && [appDelegate.stateMachine isInState:@"inQueue"]
        ) {
      [self resetModel];
    } else {
      self.model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];
      self.tableView.dataSource = _model;
      [self.tableView reloadData];
    }
  }
}

- (void)resetModel {
  self.tableView.tableHeaderView = nil;
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSMutableArray *tableContent = [NSMutableArray arrayWithCapacity:5];
  [appDelegate.gameWillStart.playerTeam each:^(LCSummoner *summoner) {
    [tableContent addObject:[[LCSummonerCellObject alloc] initWithCellClass:[LCSummonerCell class] summoner:summoner delegate:self.tableView]];
  }];
  self.model = [[NIMutableTableViewModel alloc] initWithListArray:tableContent delegate:(id)[NICellFactory class]];
  self.tableView.dataSource = _model;
  [self.tableView reloadData];
  [self.view bringSubviewToFront:self.tableView];
}


- (LCOutOfGameView *)outOfGameView {
  if (nil == _outOfGameView) {
    self.outOfGameView = [[LCOutOfGameView alloc] initWithFrame:CGRectZero];
    //    [_outOfGameView.tutorialVideoButton addTarget:self action:@selector(fireInGameEvent) forControlEvents:UIControlEventTouchUpInside];
  }
  return _outOfGameView;
}

- (LCInQueueStateView *)inQueueStateView {
  if (nil == _inQueueStateView) {
    self.inQueueStateView = [[LCInQueueStateView alloc] initWithFrame:CGRectZero];
  }
  return _inQueueStateView;
}

#pragma mark - private method

- (void)fireInGameEvent {
  NSError *error = nil;

  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate.stateMachine fireEvent:@"inGame" error:&error];
  if (error) {
    NIDPRINT(@"fire inGame event error => %@", error.debugDescription);
    [appDelegate.stateMachine fireEvent:@"outOfGame" error:nil];
  }
}

- (void)showStateView {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  if ([appDelegate.stateMachine isInState:@"outOfGame"]) {
    self.title = NSLocalizedString(@"deactivated_navi_title", nil);
    self.tableView.tableHeaderView = self.outOfGameView;
  } else if ([appDelegate.stateMachine isInState:@"inQueue"]) {
    self.title = NSLocalizedString(@"Activated_navi_title", nil);
    if (appDelegate.gameWillStart.playerTeam.count) {
      [self resetModel];
    } else {
      self.tableView.tableHeaderView = self.inQueueStateView;
    }
  }
}

@end
