//
//  LCAppDelegate.h
//  lol
//
//  Created by Di Wu on 6/13/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *kUsernameKey = @"username";
@class LCGame;

@interface LCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - XMPP
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) TKStateMachine *stateMachine;
@property (nonatomic, strong) XMPPJID *groupChatJID;
@property (nonatomic, strong) LCGame *game;
@property (nonatomic, strong) LCGame *gameWillStart;
@property (nonatomic, strong) NSString *regeion;

- (BOOL)connectWithJID:(NSString *)jid password:(NSString *)passwd;
- (void)disconnect;
- (void)showInGameTabController;
- (void)logout;
- (void)refreshXmppPrecense:(id)sender;
@end
