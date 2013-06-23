//
//  LCHomeViewController.h
//  lol
//
//  Created by Di Wu on 6/17/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

@interface LCHomeViewController : NINetworkTableViewController

@property (nonatomic, strong) TKStateMachine *stateMachine;
@property (nonatomic, strong) XMPPJID *groupChatJID;

- (id)initWithStyle:(UITableViewStyle)style;

@end
