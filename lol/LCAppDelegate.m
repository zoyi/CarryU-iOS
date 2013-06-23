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
#import "LCSummoner.h"
#import "LCGame.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

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
  LCLoginViewController *loginController = [[LCLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
  [DDLog addLogger:[DDTTYLogger sharedInstance]];
  [self setupRestkit];
  [self setupStream];
  [self setupAppearence];
  
  [self.window setRootViewController:loginController];
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
  [[UIToolbar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor wetAsphaltColor] cornerRadius:0] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
  [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor midnightBlueColor] cornerRadius:0] forBarMetrics:UIBarMetricsDefault];
}

- (void)setupRestkit {
  RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://red.zoyi.co:8000/"]];
  [RKObjectManager setSharedManager:manager];
  [LCSummoner routing];
  [LCGame routing];
  RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
}

#pragma mark - XMPP

- (void)setupStream {
  self.xmppStream = [[XMPPStream alloc] init];
  
  _xmppStream.hostPort = 5223;
  _xmppStream.hostName = @"chat.na1.lol.riotgames.com";

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
	[self goOnline];

  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[LCHomeViewController alloc] initWithStyle:UITableViewStylePlain]];
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
//	if (!isXmppConnected) {
//		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
//	}
}

@end
