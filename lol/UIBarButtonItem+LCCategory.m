//
//  UIBarButtonItem+LCCategory.m
//  lol
//
//  Created by Di Wu on 7/10/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "UIBarButtonItem+LCCategory.h"
#import "LCAppDelegate.h"

@implementation UIBarButtonItem (LCCategory)
+ (UIBarButtonItem *)carryuBackBarButtonItem {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:appDelegate.window.rootViewController action:@selector(popViewControllerAnimated:)];
  return barItem;
}
@end
