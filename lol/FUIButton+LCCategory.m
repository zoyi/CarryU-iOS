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
  button.buttonColor = [UIColor wetAsphaltColor];
  button.shadowColor = [UIColor midnightBlueColor];
  button.shadowHeight = 2.f;
  button.cornerRadius = 3.f;
  button.titleLabel.font = [UIFont boldFlatFontOfSize:15];
  [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
  return button;
}
@end
