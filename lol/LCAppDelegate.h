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

@interface LCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - XMPP
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;

- (BOOL)connectWithJID:(NSString *)jid password:(NSString *)passwd;
- (void)disconnect;

@end
