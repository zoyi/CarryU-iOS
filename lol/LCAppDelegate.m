//
//  LCAppDelegate.m
//  lol
//
//  Created by Di Wu on 6/13/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCAppDelegate.h"
#import "LCLoginViewController.h"
#import "LCHomeViewController.h"
#import "LCGameTabBarController.h"
#import "LCHomeNavigationController.h"
#import "XMPPIQ+LCCategory.h"
#import "LCSummoner.h"
#import "LCCurrentSummoner.h"
#import "LCGame.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "LCServerInfo.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface LCAppDelegate () <XMPPStreamDelegate>

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

- (void)setupRestkit;

- (void)setupAppearence;
- (void)getInProcessGameInfo;

- (void)retrieveServerInfo;

@property (nonatomic, strong) NSString *password;

@end

@implementation LCAppDelegate

- (void)dealloc{
  [self teardownStream];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];
  [self retrieveServerInfo];
  self.regeion = @"kr";
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
  LCLoginViewController *loginController = [[LCLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
  [DDLog addLogger:[DDTTYLogger sharedInstance]];
  [self setupRestkit];
  [self setupStream];
  [self setupAppearence];
  [self stateMachine];

  LCHomeNavigationController *navigationController = [[LCHomeNavigationController alloc] initWithRootViewController:[[LCHomeViewController alloc] initWithStyle:UITableViewStylePlain]];
  self.window.rootViewController = loginController;

  //  [self.window setRootViewController:loginController];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) {
		[application setKeepAliveTimeout:600 handler:^{

			DDLogVerbose(@"KeepAliveHandler");

			// Do other keep alive stuff here.
		}];
	}

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)setupAppearence {

  [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:0];

  [[UINavigationBar appearance] configureFlatNavigationBarWithColor:[UIColor peterRiverColor]];
  [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor wetAsphaltColor] cornerRadius:0]];
}

- (void)setupRestkit {
  RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[LCServerInfo sharedInstance].currentServer.rtmpHost];
  [RKObjectManager setSharedManager:manager];
  [LCSummoner routing];
  [LCSummoner apiRouting];
  [LCGame routing];
  RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
}

#pragma mark - XMPP

- (void)setupStream {
  self.xmppStream = [[XMPPStream alloc] init];
  
  _xmppStream.hostPort = [[LCServerInfo sharedInstance].currentServer.xmppPort integerValue];
  _xmppStream.hostName = [LCServerInfo sharedInstance].currentServer.xmppHost;

  _xmppStream.enableBackgroundingOnSocket = YES;
  self.xmppReconnect = [[XMPPReconnect alloc] init];

	// Activate xmpp modules

	[_xmppReconnect         activate:_xmppStream];

  [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

}

- (void)teardownStream {
  [_xmppStream removeDelegate:self];

	[_xmppReconnect         deactivate];

	[_xmppStream disconnect];

	self.xmppStream = nil;
	self.xmppReconnect = nil;
}

- (void)goOnline {
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit

	[[self xmppStream] sendElement:presence];
}

- (void)goOffline {
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];

	[[self xmppStream] sendElement:presence];
}

- (BOOL)connectWithJID:(NSString *)jid password:(NSString *)passwd {
	if (![_xmppStream isDisconnected]) {
		return YES;
	}
//
//  NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
//  NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];


	if (jid == nil || passwd == nil) {
		return NO;
	}

	[_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@pvp.net", jid]]];
	self.password = [NSString stringWithFormat:@"AIR_%@", passwd];

  [SVProgressHUD showWithStatus:@"Authing..." maskType:SVProgressHUDMaskTypeBlack];
	NSError *error = nil;
	if (![_xmppStream oldSchoolSecureConnectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
		DDLogError(@"Error connecting: %@", error);
		return NO;
	}
	return YES;
}

- (void)disconnect {
	[self goOffline];
	[_xmppStream disconnect];
}

#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

  //	isXmppConnected = YES;

	NSError *error = nil;
	if (![[self xmppStream] authenticateWithPassword:_password error:&error]) {
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  [SVProgressHUD dismiss];

  NSString *sumID = [sender.myJID.user substringFromIndex:3];
  if (sumID.length) {
    [LCCurrentSummoner sharedInstance].sID = [sumID toNumber];
  }
	[self goOnline];
  LCHomeNavigationController *navigationController = [[LCHomeNavigationController alloc] initWithRootViewController:[[LCHomeViewController alloc] initWithStyle:UITableViewStylePlain]];
  self.window.rootViewController = navigationController;

  NIDPRINT(@"now jid is %@", sender.myJID.debugDescription);
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  [SVProgressHUD dismiss];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  [SVProgressHUD dismiss];
  NIDPRINT(@"did disconnect with error => %@", error.debugDescription);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {

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
        if (skinname.length && [skinname isEqualToString:@"Random"]) {
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

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
  NIDPRINT(@"did recieve iq => %@", iq.debugDescription);
  NSString *fromBareJID = [iq.from.bareJID description];
  NSString *toBareJID = [iq.to.bareJID description];
  if ([fromBareJID isEqualToString:_groupChatJID.description]
      && [toBareJID isEqualToString:sender.myJID.bareJID.description]
      && [iq.type isEqualToString:@"result"]) {

    // get items
    NSArray *rawSummoners = [iq rawSummonerItems];
//    NIDPRINT(@"raw summoners => %@", rawSummoners);
//    [rawSummoners each:^(LCSummoner *summoner) {
//      [self resetModel];
//      [_model addObject:[[LCSummonerCellObject alloc] initWithCellClass:[LCSummonerCell class] summoner:summoner delegate:self.tableView]];
//      [self reloadData];
//    }];
  }
  return NO;
}

#pragma mark - Getters

- (TKStateMachine *)stateMachine {
  if (nil == _stateMachine) {
    self.stateMachine = [TKStateMachine new];

    TKState *outOfGame = [TKState stateWithName:@"outOfGame"];
    [outOfGame setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to outOfGame");
//      [self.view bringSubviewToFront:_outOfGameStateView];
//      if (self.navigationController.visibleViewController != self) {
//        [self.navigationController popToViewController:self animated:NO];
//      }
    }];

    TKState *inQueue = [TKState stateWithName:@"inQueue"];
    [inQueue setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to inQueue");
      //      [self.view bringSubviewToFront:_inQueueStateView];
    }];

    TKState *championSelect = [TKState stateWithName:@"championSelect"];
    [championSelect setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"group chat id is %@", _groupChatJID.description);
      NIDPRINT(@"User State Did change to championSelect");
      //      [self.view bringSubviewToFront:_championSelectStateView];
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

- (void)setGroupChatJID:(XMPPJID *)groupChatJID {
  if (![groupChatJID.description isEqualToString:_groupChatJID.description]) {
    _groupChatJID = groupChatJID;
    // fetch room members
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = _xmppStream.myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:_groupChatJID.description];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    [_xmppStream sendElement:iq];
  }
}

- (void)getInProcessGameInfo {
  [SVProgressHUD showWithStatus:@"Retriving game status..." maskType:SVProgressHUDMaskTypeBlack];
  LCSummoner *tmpSummoner = [LCSummoner new];
  tmpSummoner.name = @"킬대조영";
  // [LCCurrentSummoner sharedInstance]
  [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"active_game" object:tmpSummoner parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    NIDPRINT(@"all summoner's info is => %@", mappingResult.debugDescription);
    [SVProgressHUD dismiss];
    self.game = [[mappingResult dictionary] objectForKey:[NSNull null]];
    if (_game && [self.window.rootViewController isKindOfClass:[LCHomeNavigationController class]]) {
      LCHomeNavigationController *homeNaviController = (LCHomeNavigationController *)self.window.rootViewController;
      if ([homeNaviController.visibleViewController isKindOfClass:[LCHomeViewController class]]) {
        [self showInGameTabController];
      }
    }
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NIDPRINT(@"retrive all summoners info error => %@", error.debugDescription);
    [SVProgressHUD dismiss];
    [self.stateMachine fireEvent:@"outOfGame" error:nil];
  }];
}

- (void)showInGameTabController {
  if (_game && [self.window.rootViewController isKindOfClass:[LCHomeNavigationController class]]) {
    LCHomeNavigationController *homeNaviController = (LCHomeNavigationController *)self.window.rootViewController;
    LCGameTabBarController *gameController = [[LCGameTabBarController alloc] initWithGame:_game];
    [homeNaviController pushViewController:gameController animated:NO];
  }

}

- (void)retrieveServerInfo{
  [LCServerInfo sharedInstance];
}
@end
