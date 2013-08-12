//
//  SIAlertView+LCCategory.h
//  lol
//
//  Created by Di Wu on 7/5/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "SIAlertView.h"

@interface SIAlertView (LCCategory)
+ (SIAlertView *)carryuWarningAlertWithMessage:(NSString *)message;
+ (SIAlertView *)carryuAlertWithTitle:(NSString *)title message:(NSString *)message;
@end
