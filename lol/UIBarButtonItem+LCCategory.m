//
//  UIBarButtonItem+LCCategory.m
//  lol
//
//  Created by Di Wu on 7/10/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "UIBarButtonItem+LCCategory.h"
#import "LCAppDelegate.h"
#import "LCHomeNavigationController.h"

@implementation UIBarButtonItem (LCCategory)
+ (UIBarButtonItem *)carryuBackBarButtonItem {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  UINavigationController *naviController = nil;
  if ([appDelegate.window.rootViewController isKindOfClass:[UINavigationController class]]) {
    naviController = (UINavigationController *)appDelegate.window.rootViewController;
  } else if ([appDelegate.window.rootViewController isKindOfClass:[LCADHomeViewController class]]){
    naviController = (UINavigationController *)[(LCADHomeViewController *)appDelegate.window.rootViewController contentController];
  }
  UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:naviController action:@selector(popViewControllerAnimated:)];
  return barItem;
}
@end
