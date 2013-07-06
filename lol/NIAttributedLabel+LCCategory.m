//
//  NIAttributedLabel+LCCategory.m
//  lol
//
//  Created by Di Wu on 7/6/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "NIAttributedLabel+LCCategory.h"

@implementation NIAttributedLabel (LCCategory)

+ (NIAttributedLabel *)activeLabel {
  NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  label.textColor = [UIColor whiteColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.text = NSLocalizedString(@"activated_navi_title", nil);
  [label insertImage:[UIImage imageNamed:@"activated.png"] atIndex:0 margins:UIEdgeInsetsMake(2, 0, 2, 7)];
  label.width = [UIScreen mainScreen].bounds.size.width;
  [label sizeToFit];
  return label;
}

+ (NIAttributedLabel *)deactiveLabel {
  NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  label.textColor = [UIColor whiteColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.text = NSLocalizedString(@"deactivated_navi_title", nil);
  [label insertImage:[UIImage imageNamed:@"deactivated.png"] atIndex:0 margins:UIEdgeInsetsMake(0, 0, 5, 7)];
  label.backgroundColor = [UIColor clearColor];
  label.width = [UIScreen mainScreen].bounds.size.width;
  [label sizeToFit];
  NIDPRINT(@"label size = %@", NSStringFromCGRect(label.frame));
  return label;
}

@end
