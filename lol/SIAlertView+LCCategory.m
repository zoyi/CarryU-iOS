//
//  SIAlertView+LCCategory.m
//  lol
//
//  Created by Di Wu on 7/5/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "SIAlertView+LCCategory.h"

@implementation SIAlertView (LCCategory)
+ (SIAlertView *)carryuWarningAlertWithMessage:(NSString *)message {
  SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) andMessage:message];

  alertView.titleColor = [UIColor cloudsColor];
  alertView.messageColor = [UIColor cloudsColor];
  alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

  [alertView addButtonWithTitle:NSLocalizedString(@"okay", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
    [alertView dismissAnimated:YES];
  }];

  alertView.willShowHandler = ^(SIAlertView *alertView) {
    alertView.viewBackgroundColor = RGBCOLOR(0x2c, 0x3e, 0x50);
  };

  return alertView;
}
@end
