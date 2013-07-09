//
//  LCSearchBar.m
//  lol
//
//  Created by Di Wu on 6/25/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSearchBar.h"

@implementation LCSearchBar

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)layoutSubviews {

  UITextField *searchField;
  NSUInteger numViews = [self.subviews count];
  for (int i = 0; i < numViews; ++i) {
    if ([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
      searchField = [self.subviews objectAtIndex:i];
    }
  }
  [self bringSubviewToFront:searchField];
  if(searchField != nil) {
    searchField.font = [UIFont systemFontOfSize:16];
    searchField.textColor = RGBCOLOR(0x77, 0x77, 0x77);
    searchField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    searchField.background = nil;
//    searchField.borderStyle = UITextBorderStyleNone;
  }

  [super layoutSubviews];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (UIView *)backgroundCoverView {
  if (nil == _backgroundCoverView) {
    self.backgroundCoverView = [[UIView alloc] initWithFrame:CGRectZero];
    _backgroundCoverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
  }
  return _backgroundCoverView;
}

@end
