//
//  LCAppDelegate.h
//  lol
//
//  Created by Di Wu on 6/13/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

@class LCGame;

@interface LCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - XMPP
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) TKStateMachine *stateMachine;
@property (nonatomic, strong) XMPPJID *groupChatJID;
@property (nonatomic, strong) LCGame *game;

- (BOOL)connectWithJID:(NSString *)jid password:(NSString *)passwd;
- (void)disconnect;
- (void)showInGameTabController;
@end
