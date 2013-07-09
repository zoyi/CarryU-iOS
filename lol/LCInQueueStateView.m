//
//  LCInQueueStateView.m
//  lol
//
//  Created by Di Wu on 7/9/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCInQueueStateView.h"

@interface LCInQueueStateView ()
@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) NIAttributedLabel *descriptionLabel;
@end

@implementation LCInQueueStateView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.backgroundColor = [UIColor clearColor];
  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  CGFloat top = floorf([UIScreen mainScreen].bounds.size.height*1/6);

  self.titleImageView.frame = CGRectMake(floorf((screenWidth - self.titleImageView.width)/2), top, self.titleImageView.width, self.titleImageView.height);
  top += _titleImageView.height + 30;

  _descriptionLabel.width = _titleImageView.width;
  [self.descriptionLabel sizeToFit];
  _descriptionLabel.origin = CGPointMake(floorf((screenWidth - _descriptionLabel.width)/2), top);
}

- (UIImageView *)titleImageView {
  if (nil == _titleImageView) {
    self.titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searching_match.png"]];
    _titleImageView.backgroundColor = self.backgroundColor;
    [self addSubview:_titleImageView];
  }
  return _titleImageView;
}

- (NIAttributedLabel *)descriptionLabel {
  if (nil == _descriptionLabel) {
    self.descriptionLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _descriptionLabel.backgroundColor = self.backgroundColor;
    _descriptionLabel.textColor = RGBCOLOR(0x32, 0x3a, 0x42);
    _descriptionLabel.font = [UIFont systemFontOfSize:14];
    _descriptionLabel.text = NSLocalizedString(@"pull_to_reload_desc", nil);
    [_descriptionLabel insertImage:[UIImage imageNamed:@"refresh.png"] atIndex:0 margins:UIEdgeInsetsMake(2, 2, 2, 7) verticalTextAlignment:NIVerticalTextAlignmentMiddle];
    _descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_descriptionLabel];
  }
  return _descriptionLabel;
}

@end
