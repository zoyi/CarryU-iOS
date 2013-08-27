//
//  FUIButton+LCCategory.m
//  lol
//
//  Created by Di Wu on 6/16/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "FUIButton+LCCategory.h"

@implementation FUIButton (LCCategory)
+ (FUIButton *)lcButtonWithTitle:(NSString *)title {
  FUIButton *button = [[FUIButton alloc] initWithFrame:CGRectZero];
  [button setTitle:title forState:UIControlStateNormal];
//  button.buttonColor = [UIColor carryuColor];
  button.buttonColor = RGBCOLOR(0x13, 0x98, 0xb1);
//  button.shadowColor = RGBCOLOR(0x41, 0x4d, 0x5a);
  button.shadowColor = RGBCOLOR(0x0e, 0x78, 0x8b);
  button.shadowHeight = 2.f;
  button.cornerRadius = 3.f;
  button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
  [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
  return button;
}
@end
