//
//  LCHomeViewController.m
//  lol
//
//  Created by Di Wu on 6/17/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCHomeViewController.h"
#import "LCAppDelegate.h"

@interface LCHomeViewController () <XMPPStreamDelegate>

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
  [self stateMachine];
  self.tableView.backgroundColor = [UIColor cloudsColor];
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
    }];

    TKState *inQueue = [TKState stateWithName:@"inQueue"];
    [inQueue setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to inQueue");
    }];

    TKState *championSelect = [TKState stateWithName:@"championSelect"];
    [championSelect setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to championSelect");
    }];

    TKState *inGame = [TKState stateWithName:@"inGame"];
    [inGame setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to inGame");
    }];

    [_stateMachine addStates:@[outOfGame, inQueue, championSelect, inGame]];
    _stateMachine.initialState = outOfGame;

    TKEvent *outOfGameToInQueueEvent = [TKEvent eventWithName:@"inQueue" transitioningFromStates:@[outOfGame] toState:inQueue];
    TKEvent *inQueueToChampionSelectEvent = [TKEvent eventWithName:@"championSelect" transitioningFromStates:@[inQueue] toState:championSelect];
    TKEvent *championSelectToInGameEvent = [TKEvent eventWithName:@"inGame" transitioningFromStates:@[championSelect] toState:inGame];
    TKEvent *stateToOutOfGameEvent = [TKEvent eventWithName:@"outOfGame" transitioningFromStates:@[inGame, championSelect, inQueue] toState:outOfGame];

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
  return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
  NIDPRINT(@"xmpp did receive message => %@", [message.debugDescription stringByReplacingXMLEscape]);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
  NIDPRINT(@"xmpp did receive presence => %@", [presence.debugDescription stringByReplacingXMLEscape]);
}

@end
