//
//  LCAppDelegate.h
//  lol
//
//  Created by Di Wu on 6/13/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString * const kTestFilghtToken;
extern NSString * const kUsernameKey;
extern NSString * const kPasswordKey;
@class LCGame;

typedef NS_ENUM(NSInteger, LCObserveMode) {
  LCObserveModeUnknown,
  LCObserveModeManual,
  LCObserveModeAuto
};

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
@property (nonatomic, assign) LCObserveMode gameMode;

- (BOOL)connectWithJID:(NSString *)jid password:(NSString *)passwd;
- (void)rebuildHomeRootViewController;
- (void)logout;
- (void)refreshXmppPrecense:(id)sender;
- (void)fireLocalNotificationWithMessage:(NSString *)message;
@end
