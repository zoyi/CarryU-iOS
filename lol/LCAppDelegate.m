//
//  LCAppDelegate.m
//  lol
//
//  Created by Di Wu on 6/13/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCAppDelegate.h"
#import "LCLoginViewController.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface LCAppDelegate () <XMPPCapabilitiesDelegate, XMPPStreamDelegate, XMPPRosterDelegate>

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

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
  [self setupStream];
  
  [self.window setRootViewController:loginController];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

	[self goOnline];
  //
  NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
  NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
  XMPPJID *myJID = self.xmppStream.myJID;
  [iq addAttributeWithName:@"from" stringValue:myJID.description];
  [iq addAttributeWithName:@"to" stringValue:@"bnbrvjnkuqdx3pngcgqbpiyj-yoj8avq@sec.pvp.net"];
  [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
  [iq addAttributeWithName:@"type" stringValue:@"get"];
  [iq addChild:query];
  [self.xmppStream sendElement:iq];


}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  NIDPRINT(@"did receive iq -> %@", iq.debugDescription);
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	// A simple example of inbound message handling.
//
//	if ([message isChatMessageWithBody]) {
//		XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:[message from]
//		                                                         xmppStream:_xmppStream
//		                                               managedObjectContext:[self managedObjectContext_roster]];
//
//		NSString *body = [[message elementForName:@"body"] stringValue];
//		NSString *displayName = [user displayName];
//
//		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                          message:body
//                                                         delegate:nil
//                                                cancelButtonTitle:@"Ok"
//                                                otherButtonTitles:nil];
//			[alertView show];
//		} else {
//			// We are not active, so use a local notification instead
//			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//			localNotification.alertAction = @"Ok";
//			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
//
//			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//		}
//	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
  NIDPRINT(@"did receive presence %@", [[presence debugDescription] stringByReplacingXMLEscape]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  NIDPRINT(@"did disconnect with error => %@", error.debugDescription);
//	if (!isXmppConnected) {
//		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
//	}
}
@end
