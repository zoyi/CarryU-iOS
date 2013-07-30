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
#import "LCSettingsInfo.h"
#import <GCOLaunchImageTransition/GCOLaunchImageTransition.h>

static NSString *kRegionKey = @"_region";

NSString * const kUsernameKey = @"username";
NSString * const kPasswordKey = @"_password";
#ifdef IAD
NSString * const kTestFilghtToken= @"48673066-e6fc-4f04-9708-798d441c6d96";
#else
NSString * const kTestFilghtToken = @"1ded3e52-07bf-4d98-8179-61f9790080c0";
#endif

@interface LCAppDelegate () <XMPPStreamDelegate>

- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

- (void)setupRestkit;
- (void)setupApiRouter;
- (void)setupGAI;

- (void)setupAppearence;
- (void)getInProcessGameInfo;

- (void)retrieveServerInfo;

- (void)changeUserAgent;

- (void)showHomeStatusController;

@property (nonatomic, strong) NSString *password;

@end


@implementation LCAppDelegate

- (void)dealloc{
  [self teardownStream];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [application cancelAllLocalNotifications];
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];
#ifdef TESTFLIGHT
  [TestFlight takeOff:kTestFilghtToken];
#endif
  [self setupGAI];
  [self changeUserAgent];

  [self retrieveServerInfo];
  self.regeion = [[NSUserDefaults standardUserDefaults] objectForKey:kRegionKey];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
  LCLoginViewController *loginController = [[LCLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
#ifdef DEBUG
  [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
  [self setupRestkit];
  [self setupApiRouter];
  [self xmppStream];
  [self setupAppearence];
  [self stateMachine];

  [self.window setRootViewController:loginController];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  // remove all notifications
  [application cancelAllLocalNotifications];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [GCOLaunchImageTransition transitionWithDuration:0.5 style:GCOLaunchImageTransitionAnimationStyleZoomIn];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)setupGAI {
  // Optional: automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
  [GAI sharedInstance].dispatchInterval = 20;
  // Optional: set debug to YES for extra debugging information.
#ifdef DEBUG
  [GAI sharedInstance].debug = YES;
#endif
  // Create tracker instance.
  id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-42254758-2"];
  [GAI sharedInstance].defaultTracker = tracker;
}

- (void)setupAppearence {
  [[UIToolbar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor midnightBlueColor] cornerRadius:0] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
  
  [UIBarButtonItem configureFlatButtonsWithColor:[UIColor midnightBlueColor] highlightedColor:[UIColor midnightBlueColor] cornerRadius:0];

  [[UINavigationBar appearance] configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
  [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor midnightBlueColor] cornerRadius:0]];
}

- (void)setupRestkit {

  RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[LCServerInfo sharedInstance].currentServer.rtmpHost];
  [RKObjectManager setSharedManager:manager];
  [LCSummoner routing];
  [LCGame routing];
#ifdef DEBUG
  RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
#else
  RKLogConfigureByName("RestKit/Network", RKLogLevelOff);
#endif
}

- (void)setupApiRouter {
  [LCApiRouter setSharedInstance:[[LCApiRouter alloc] initWithBaseURL:[LCServerInfo sharedInstance].currentServer.apiUrl]];
  [LCSummoner apiRouting];
  [LCGame apiRouting];

}

- (void)setRegeion:(NSString *)regeion {
  if (regeion == nil) {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"ko"]) {
      regeion = @"kr";
    } else {
      regeion = @"na";
    }

  }
  if (![regeion isEqualToString:_regeion]) {
    _regeion = regeion;
    //    [[LCSettingsInfo sharedInstance] updateRegion];
    [self teardownStream];
    [self xmppStream];
    [self setupRestkit];
    [self setupApiRouter];
  }
  [[NSUserDefaults standardUserDefaults] setObject:_regeion forKey:kRegionKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
}

- (void)logout {
  [self teardownStream];
  self.game = nil;
  self.gameWillStart = nil;
  self.groupChatJID = nil;
  LCLoginViewController *loginController = [[LCLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];

  self.window.rootViewController = loginController;
  [self.stateMachine fireEvent:@"outOfGame" error:nil];
}

#pragma mark - XMPP


- (XMPPStream *)xmppStream {
  if (nil == _xmppStream) {
    self.xmppStream = [[XMPPStream alloc] init];

    _xmppStream.hostPort = [[LCServerInfo sharedInstance].currentServer.xmppPort integerValue];
    _xmppStream.hostName = [LCServerInfo sharedInstance].currentServer.xmppHost;

    _xmppStream.enableBackgroundingOnSocket = YES;
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self xmppReconnect];
  }
  return _xmppStream;
}

- (XMPPReconnect *)xmppReconnect {
  if (nil == _xmppReconnect) {
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    _xmppReconnect.usesOldSchoolSecureConnect = YES;
    // Activate xmpp modules
    _xmppReconnect.autoReconnect = YES;
    [_xmppReconnect activate:_xmppStream];

  }
  return _xmppReconnect;
}

- (void)teardownStream {
  [_xmppStream removeDelegate:self];

	[_xmppReconnect deactivate];

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
	if (![self.xmppStream isDisconnected]) {
    [self.xmppStream disconnect];
	}

  [[NSUserDefaults standardUserDefaults] setObject:jid forKey:kUsernameKey];
  [[NSUserDefaults standardUserDefaults] setObject:passwd forKey:kPasswordKey];
  [[NSUserDefaults standardUserDefaults] synchronize];

	[_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@pvp.net", jid]]];
	self.password = [NSString stringWithFormat:@"AIR_%@", passwd];

  [SVProgressHUD showWithStatus:NSLocalizedString(@"authenticating", nil) maskType:SVProgressHUDMaskTypeBlack];
	NSError *error = nil;
	if (![_xmppStream oldSchoolSecureConnectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
		NIDPRINT(@"Error connecting: %@", error);
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
  NIDPRINT(@"socket did connect");

}


- (void)xmppStreamDidSecure:(XMPPStream *)sender {
  NIDPRINT(@"socket did secure");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
  NIDPRINT(@"stream did connect");
  //	isXmppConnected = YES;

	NSError *error = nil;
	if (![[self xmppStream] authenticateWithPassword:_password error:&error]) {

		NIDPRINT(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
  [SVProgressHUD dismiss];

  NSString *sumID = [sender.myJID.user substringFromIndex:3];
  if (sumID.length) {
    [LCCurrentSummoner sharedInstance].sID = [sumID toNumber];
  }
	[self goOnline];

  LCHomeNavigationController *navigationController = [[LCHomeNavigationController alloc] initWithRootViewController:[[LCHomeViewController alloc] initWithStyle:UITableViewStylePlain]];

#ifdef IAD
  UIViewController *rootViewController = [[LCADHomeViewController alloc] initWithContentViewController:navigationController];
#else
  UIViewController *rootViewController = navigationController;
#endif

  self.window.rootViewController = rootViewController;

  NIDPRINT(@"now jid is %@", sender.myJID.debugDescription);
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
  [SVProgressHUD dismiss];
  [sender disconnect];

  [[SIAlertView carryuWarningAlertWithMessage:NSLocalizedString(@"wrong_username_or_password", nil)] show];
  NIDPRINT(@"xmpp did not authenticate with error %@", error.debugDescription);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
  NIDPRINT(@"xmpp did receive error %@", [error debugDescription]);
  [SVProgressHUD dismiss];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
  [SVProgressHUD dismiss];
  NIDPRINT(@"did disconnect with error => %@", error.debugDescription);
  if (error.code == 7 &&
      [error.domain isEqualToString:@"GCDAsyncSocketErrorDomain"]
      && ![self.window.rootViewController isKindOfClass:[LCLoginViewController class]]) {
    [_xmppReconnect manualStart];
  }
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
          [_stateMachine fireEvent:@"inQueue" error:&error];
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
  if ([_stateMachine isInState:@"inQueue"]) {
    // message contain x
    NSString *type = [message attributeStringValueForName:@"type"];
    NSString *mid = [message attributeStringValueForName:@"id"];
    if ([type isEqualToString:@"groupchat"]
        && !mid.length) {
      self.groupChatJID = message.from.bareJID;
      NIDPRINT(@"group chat jid => %@", _groupChatJID.debugDescription);
    }
  }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
  NIDPRINT(@"did recieve iq => %@", iq.debugDescription);
  NSString *fromBareJID = [iq.from.bareJID description];
  NSString *toBareJID = [iq.to.bareJID description];
  [iq rawSummonerItems];
  if ([fromBareJID isEqualToString:_groupChatJID.description]
      && [toBareJID isEqualToString:sender.myJID.bareJID.description]
      && [iq isResultIQ]
      && [_stateMachine isInState:@"inQueue"]) {

    // get items
    NSArray *rawSummoners = [iq rawSummonerItems];
    if (rawSummoners.count) {
      NSMutableArray *championSummoners = [NSMutableArray array];

      [rawSummoners each:^(NSString *summonerName) {
        LCSummoner *summoner = [LCSummoner new];
        summoner.name = summonerName;
        [championSummoners addObject:summoner];
      }];
      LCGame *theGame = [LCGame new];
      theGame.playerTeam = championSummoners;
      self.gameWillStart = theGame;

      // fire locale notification
      [self fireLocalNotificationWithMessage:NSLocalizedString(@"champion_select_noti_msg", nil)];
    }
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
    }];

    TKState *inQueue = [TKState stateWithName:@"inQueue"];
    [inQueue setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to inQueue");
      self.gameWillStart = nil;
      NIDPRINT(@"group chat id is %@", _groupChatJID.description);
    }];

    [inQueue setDidExitStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      self.gameWillStart = nil;
      self.groupChatJID = nil;
    }];

    TKState *inGame = [TKState stateWithName:@"inGame"];
    [inGame setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"User State Did change to inGame");
      [self getInProcessGameInfo];
      [self fireLocalNotificationWithMessage:NSLocalizedString(@"in_game_notification_msg", nil)];
    }];

    [inGame setDidExitStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
      NIDPRINT(@"user did left game");
      [self showHomeStatusController];
    }];

    [_stateMachine addStates:@[outOfGame, inQueue, inGame]];
    _stateMachine.initialState = outOfGame;

    TKEvent *outOfGameToInQueueEvent = [TKEvent eventWithName:@"inQueue" transitioningFromStates:@[outOfGame] toState:inQueue];
    TKEvent *inQueueToInGameEvent = [TKEvent eventWithName:@"inGame" transitioningFromStates:@[outOfGame, inQueue] toState:inGame];
    TKEvent *stateToOutOfGameEvent = [TKEvent eventWithName:@"outOfGame" transitioningFromStates:@[outOfGame, inGame, inQueue] toState:outOfGame];

    [_stateMachine addEvents:@[outOfGameToInQueueEvent, inQueueToInGameEvent, stateToOutOfGameEvent]];
    [_stateMachine activate];
  }
  return _stateMachine;
}

- (void)setGroupChatJID:(XMPPJID *)groupChatJID {
  if ([groupChatJID.description rangeOfString:@"~"].location != NSNotFound) {
    return;
  }
  if (![groupChatJID.description isEqualToString:_groupChatJID.description]) {
    _groupChatJID = groupChatJID;
    if (_groupChatJID.description.length) {
      [self performBlock:^(id sender) {
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        XMPPJID *myJID = _xmppStream.myJID;
        [iq addAttributeWithName:@"from" stringValue:myJID.description];
        [iq addAttributeWithName:@"to" stringValue:_groupChatJID.description];
        [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
        [iq addAttributeWithName:@"type" stringValue:@"get"];
        [iq addChild:query];
        [_xmppStream sendElement:iq];
      } afterDelay:3.5];
    }
  }
}

- (void)getInProcessGameInfo {
  [SVProgressHUD showWithStatus:NSLocalizedString(@"retrieve_game_status", nil) maskType:SVProgressHUDMaskTypeBlack];
  LCSummoner *tmpSummoner = [LCSummoner new];
  tmpSummoner.name = @"MVP Looper";
  // [LCCurrentSummoner sharedInstance]
  [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"active_game" object:[LCCurrentSummoner sharedInstance] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    NIDPRINT(@"all summoner's info is => %@", mappingResult.debugDescription);
    [SVProgressHUD dismiss];
    self.game = [[mappingResult dictionary] objectForKey:[NSNull null]];
    if (_game) {
      LCHomeNavigationController *homeNaviController = nil;
      if ([self.window.rootViewController isKindOfClass:[LCADHomeViewController class]]) {
        homeNaviController = (LCHomeNavigationController *)[(LCADHomeViewController *)self.window.rootViewController contentController];
      } else if ([self.window.rootViewController isKindOfClass:[LCHomeNavigationController class]]) {
        homeNaviController = (LCHomeNavigationController *)self.window.rootViewController;
      }
      UIViewController *visiableController = [homeNaviController.viewControllers objectAtIndex:0];
      if ([visiableController isKindOfClass:[LCHomeViewController class]]) {
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
  if (_game) {
    LCHomeNavigationController *homeNaviController = nil;
    if ([self.window.rootViewController isKindOfClass:[LCADHomeViewController class]]) {
      homeNaviController = (LCHomeNavigationController *)[(LCADHomeViewController *)self.window.rootViewController contentController];
    } else if ([self.window.rootViewController isKindOfClass:[LCHomeNavigationController class]]) {
      homeNaviController = (LCHomeNavigationController *)self.window.rootViewController;
    }
    LCGameTabBarController *gameController = [[LCGameTabBarController alloc] initWithGame:_game];
    [homeNaviController pushViewController:gameController animated:NO];
  }
}

- (void)refreshXmppPrecense:(id)sender {
  if ([sender isKindOfClass:[ODRefreshControl class]]) {
    [self goOffline];

    [(ODRefreshControl *)sender performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.35];
    [self performSelector:@selector(goOnline) withObject:nil afterDelay:0.36];
  }
}

- (void)retrieveServerInfo{
  [LCServerInfo sharedInstance];
  [LCSettingsInfo sharedInstance];
}

- (void)changeUserAgent {

  UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
  NIDPRINT(@"default User Agent is %@", secretAgent);
#ifdef IAD
  NSDictionary *dic = @{@"UserAgent" : [NSString stringWithFormat:@"%@ CarryU_Free", secretAgent]};
#else
  NSDictionary *dic = @{@"UserAgent" : [NSString stringWithFormat:@"%@ CarryU", secretAgent]};
#endif
  [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}

- (void)fireLocalNotificationWithMessage:(NSString *)message {
  UIApplication *app = [UIApplication sharedApplication];
  if (app.applicationState == UIApplicationStateBackground) {
    [app cancelAllLocalNotifications];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = message;

    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
  }
}

- (void)showHomeStatusController {
  id naviController = nil;
  LCHomeViewController *homeViewController = [[LCHomeViewController alloc] initWithStyle:UITableViewStylePlain];
#ifdef IAD
  naviController = [(LCADHomeViewController *)self.window.rootViewController contentController];
#else
  naviController = self.window.rootViewController;
#endif
  if ([naviController isKindOfClass:[UINavigationController class]]) {
    [(UINavigationController *)naviController pushViewController:homeViewController animated:NO];
  }
}

@end
