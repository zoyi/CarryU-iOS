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
#import "LCStateView.h"
#import "LCSummoner.h"
#import "LCGame.h"
#import "LCSummonerCellObject.h"
#import "LCSummonerCell.h"
#import "LCGameTabBarController.h"
#import "XMPPIQ+LCCategory.h"

@interface LCHomeViewController () <XMPPStreamDelegate>

@property (nonatomic, strong) NIMutableTableViewModel *model;
@property (nonatomic, strong) NITableViewActions *actions;

@property (nonatomic, strong) LCStateView *outOfGameStateView;
@property (nonatomic, strong) LCStateView *inQueueStateView;
@property (nonatomic, strong) LCStateView *championSelectStateView;
@property (nonatomic, strong) LCStateView *inGameStateView;
@property (nonatomic, strong) NSString *summonerName;

- (void)getInProcessGameInfo;

- (void)resetModel;

- (void)reloadData;

- (void)fireInGameEvent;

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
  [_actions attachToClass:[LCSummonerCellObject class] tapBlock:^BOOL(id object, id target) {
    LCSummonerCellObject *cellObject = object;
    NIDPRINT(@"CELL OBJECT is %@", cellObject.debugDescription);
    return YES;
  }];
  self.tableView.delegate = [_actions forwardingTo:self];
  self.tableView.rowHeight = kSummonerCellDefaultHeight;

  self.tableView.backgroundColor = [UIColor cloudsColor];
  self.outOfGameStateView.frame = self.view.bounds;
  self.inQueueStateView.frame = self.view.bounds;
  self.championSelectStateView.frame = self.view.bounds;
  self.inGameStateView.frame = self.view.bounds;
  [self stateMachine];
}

- (void)resetModel {
  self.model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];
  self.tableView.dataSource = _model;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - Getters

- (TKStateMachine *)stateMachine {
  if (nil == _stateMachine) {
    self.stateMachine = [TKStateMachine new];

    TKState *outOfGame = [TKState stateWithName:@"outOfGame"];
    [outOfGame setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to outOfGame");
      [self.view bringSubviewToFront:_outOfGameStateView];
    }];

    TKState *inQueue = [TKState stateWithName:@"inQueue"];
    [inQueue setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to inQueue");
      [self.view bringSubviewToFront:_inQueueStateView];
    }];

    TKState *championSelect = [TKState stateWithName:@"championSelect"];
    [championSelect setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"group chat id is %@", _groupChatJID.description);
      NIDPRINT(@"User State Did change to championSelect");
      [self.view bringSubviewToFront:_championSelectStateView];
    }];

    TKState *inGame = [TKState stateWithName:@"inGame"];
    [inGame setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to inGame");
      [self getInProcessGameInfo];
    }];

    [_stateMachine addStates:@[outOfGame, inQueue, championSelect, inGame]];
    _stateMachine.initialState = outOfGame;

    TKEvent *outOfGameToInQueueEvent = [TKEvent eventWithName:@"inQueue" transitioningFromStates:@[outOfGame] toState:inQueue];
    TKEvent *inQueueToChampionSelectEvent = [TKEvent eventWithName:@"championSelect" transitioningFromStates:@[outOfGame, inQueue] toState:championSelect];
    TKEvent *championSelectToInGameEvent = [TKEvent eventWithName:@"inGame" transitioningFromStates:@[outOfGame, championSelect] toState:inGame];
    TKEvent *stateToOutOfGameEvent = [TKEvent eventWithName:@"outOfGame" transitioningFromStates:@[outOfGame, inGame, championSelect, inQueue] toState:outOfGame];

    [_stateMachine addEvents:@[outOfGameToInQueueEvent, inQueueToChampionSelectEvent, championSelectToInGameEvent, stateToOutOfGameEvent]];
    [_stateMachine activate];
  }
  return _stateMachine;
}


#pragma mark - XMPPStream Delegate 

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error {
  NIDPRINT(@"xmpp did receive error => %@", error.debugDescription);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
  NIDPRINT(@"did recieve iq => %@", iq.debugDescription);
  NSString *fromBareJID = [iq.from.bareJID description];
  NSString *toBareJID = [iq.to.bareJID description];
  if ([fromBareJID isEqualToString:_groupChatJID.description]
      && [toBareJID isEqualToString:sender.myJID.bareJID.description]
      && [iq.type isEqualToString:@"result"]) {

    // get items
    NSArray *rawSummoners = [iq rawSummonerItems];
    NIDPRINT(@"raw summoners => %@", rawSummoners);
    [rawSummoners each:^(LCSummoner *summoner) {
      [self resetModel];
      [_model addObject:[[LCSummonerCellObject alloc] initWithCellClass:[LCSummonerCell class] summoner:summoner]];
      [self reloadData];
    }];
  }
  return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
  NIDPRINT(@"xmpp did receive message => %@", [message.debugDescription stringByReplacingXMLEscape]);
  if ([_stateMachine isInState:@"championSelect"] || [_stateMachine isInState:@"inQueue"]) {
    // message contain x
    NSString *type = [message attributeStringValueForName:@"type"];
    NSString *mid = [message attributeStringValueForName:@"id"];
    if ([type isEqualToString:@"groupchat"] && !mid.length) {
      self.groupChatJID = message.from.bareJID;
      NIDPRINT(@"group chat jid => %@", _groupChatJID.debugDescription);
    }
  }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
  NIDPRINT(@"xmpp did receive presence => %@", [presence.debugDescription stringByReplacingXMLEscape]);

  if ([sender.myJID.bareJID.description isEqualToString:presence.from.bareJID.description]) {
    // my status update.
    NSString *gameStatus = [presence gameStatus];
    if (gameStatus.length) {
      // change state machine
      NSError *error = nil;
      
      if ([gameStatus isEqualToString:@"outOfGame"]) {
        // out of game
        [_stateMachine fireEvent:@"outOfGame" error:&error];
      } else if ([gameStatus isEqualToString:@"inQueue"]) {
        NSString *skinname = [presence skinname];
        if (skinname.length) {
          // champion select
          [_stateMachine fireEvent:@"championSelect" error:&error];
        } else {
          // in Queue
          [_stateMachine fireEvent:@"inQueue" error:&error];
        }
      } else if ([gameStatus isEqualToString:@"inGame"]) {
        [_stateMachine fireEvent:@"inGame" error:&error];
      }

      if (error) {
        NIDPRINT(@"state machine fire with error %@", error.debugDescription);
      }

    }
  }
}

- (LCStateView *)outOfGameStateView {
  if (nil == _outOfGameStateView) {
    self.outOfGameStateView = [[LCStateView alloc] initWithTitle:NSLocalizedString(@"out_of_game_title", nil) subtitle:NSLocalizedString(@"", nil) image:nil];
    [_outOfGameStateView addReloadButton];
    [_outOfGameStateView.reloadButton addTarget:self action:@selector(fireInGameEvent) forControlEvents:UIControlEventTouchUpInside];
    _outOfGameStateView.backgroundColor = self.tableView.backgroundColor;
    [self.view insertSubview:_outOfGameStateView belowSubview:self.tableView];
  }
  return _outOfGameStateView;
}

- (LCStateView *)inQueueStateView {
  if (nil == _inQueueStateView) {
    self.inQueueStateView = [[LCStateView alloc] initWithTitle:NSLocalizedString(@"in_queue_title", nil) subtitle:NSLocalizedString(@"searching for new game...", nil) image:nil];
    _inQueueStateView.backgroundColor = self.tableView.backgroundColor;
    [self.view insertSubview:_inQueueStateView belowSubview:self.tableView];
  }
  return _inQueueStateView;
}

- (LCStateView *)championSelectStateView {
  if (nil == _championSelectStateView) {
    self.championSelectStateView = [[LCStateView alloc] initWithTitle:NSLocalizedString(@"champion_select_title", nil) subtitle:NSLocalizedString(@"choosing champions", nil) image:nil];
    _championSelectStateView.backgroundColor = self.tableView.backgroundColor;
    [self.view insertSubview:_championSelectStateView belowSubview:self.tableView];
  }
  return _championSelectStateView;
}

- (LCStateView *)inGameStateView {
  if (nil == _inGameStateView) {
    self.inGameStateView = [[LCStateView alloc] initWithTitle:NSLocalizedString(@"in_game_title", nil) subtitle:NSLocalizedString(@"happy gaming", nil) image:nil];
    _inGameStateView.backgroundColor = self.tableView.backgroundColor;
    [self.view insertSubview:_inGameStateView belowSubview:self.tableView];
  }
  return _inGameStateView;
}

#pragma mark - setter

- (void)setGroupChatJID:(XMPPJID *)groupChatJID {
  if (![groupChatJID.description isEqualToString:_groupChatJID.description]) {
    _groupChatJID = groupChatJID;
    // fetch room members
    LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = appDelegate.xmppStream.myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:_groupChatJID.description];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    [appDelegate.xmppStream sendElement:iq];
  }
}

#pragma mark - private method

- (void)getInProcessGameInfo {
  LCSummoner *summoner = [LCSummoner new];
  summoner.name = @"chaox";
  [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"active_game" object:summoner parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    NIDPRINT(@"all summoner's info is => %@", mappingResult.debugDescription);
    self.game = [[mappingResult dictionary] objectForKey:[NSNull null]];
    if (_game) {

      LCGameTabBarController *gameTabBarController = [[LCGameTabBarController alloc] initWithGame:_game];
      LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
      appDelegate.window.rootViewController = gameTabBarController;

    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NIDPRINT(@"retrive all summoners info error => %@", error.debugDescription);
    [self.stateMachine fireEvent:@"outOfGame" error:nil];
  }];
}

- (void)reloadData {
  [self.tableView reloadData];
  [self.view bringSubviewToFront:self.tableView];
  [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)fireInGameEvent {
  NSError *error = nil;
  [self.stateMachine fireEvent:@"inGame" error:&error];
  if (error) {
    NIDPRINT(@"fire inGame event error => %@", error.debugDescription);
    [self.stateMachine fireEvent:@"outOfGame" error:nil];
  }
}

@end
