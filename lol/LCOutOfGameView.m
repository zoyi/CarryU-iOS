//
//  LCOutOfGameView.m
//  lol
//
//  Created by Di Wu on 7/5/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCOutOfGameView.h"

static CGFloat kOutOfGameViewButtonDefaultHeight = 44;
static CGFloat kOutOfGameViewButtonDefaultWidth = 320-20;
@implementation LCOutOfGameView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code

  }
  return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)layoutSubviews {
  [super layoutSubviews];
  //  [self backgroundView];
  self.backgroundColor = [UIColor clearColor];

  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  CGFloat top = floorf([UIScreen mainScreen].bounds.size.height*1/6);
  CGFloat left = 30;
  self.imageView.frame = CGRectMake(floorf((screenWidth - self.imageView.width)/2), top, self.imageView.width, self.imageView.height);
  top += _imageView.height + 15;

  CGFloat maxLabelWidth = screenWidth - left*2;
  self.titleLabel.width = maxLabelWidth;
  [_titleLabel sizeToFit];
  self.titleLabel.width = maxLabelWidth;
  _titleLabel.origin = CGPointMake(left, top);
  top += _titleLabel.height + 15;

  self.pullReloadDescLabel.width = maxLabelWidth;
  [_pullReloadDescLabel sizeToFit];
  _pullReloadDescLabel.origin = CGPointMake((screenWidth - _pullReloadDescLabel.width)/2, top);
  {
    CGFloat bottomPadding = 10;
#ifdef IAD
    bottomPadding += 50;
#endif
    CGFloat innerLeft = 10.f;
    maxLabelWidth = screenWidth - 2*innerLeft;
    self.sampleGameDescLabel.width = maxLabelWidth;
    [_sampleGameDescLabel sizeToFit];

    CGFloat innerTop = self.height - kOutOfGameViewButtonDefaultHeight - bottomPadding - _sampleGameDescLabel.height - 10.f;

//    self.tutorialVideoButton.frame = CGRectMake(innerLeft, innerTop, kOutOfGameViewButtonDefaultWidth, kOutOfGameViewButtonDefaultHeight);
//  innerLeft += kOutOfGameViewButtonDefaultWidth + 10;

    _sampleGameDescLabel.frame = CGRectMake(innerLeft, innerTop, maxLabelWidth, _sampleGameDescLabel.height);
    innerTop += _sampleGameDescLabel.height + 10;
    self.previewButton.frame = CGRectMake(innerLeft, innerTop, kOutOfGameViewButtonDefaultWidth, kOutOfGameViewButtonDefaultHeight);
  }

}

#pragma mark - getters

- (UIImageView *)imageView {
  if (nil == _imageView) {
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"summon_game.png"]];

    [self addSubview:_imageView];
  }
  return _imageView;
}

- (NIAttributedLabel *)pullReloadDescLabel {
  if (nil == _pullReloadDescLabel) {
    self.pullReloadDescLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _pullReloadDescLabel.backgroundColor = [UIColor clearColor];
    _pullReloadDescLabel.textColor = RGBCOLOR(0x32, 0x3a, 0x42);
    _pullReloadDescLabel.font = [UIFont systemFontOfSize:14];
    _pullReloadDescLabel.text = NSLocalizedString(@"pull_to_reload_desc", nil);
    [_pullReloadDescLabel insertImage:[UIImage imageNamed:@"refresh.png"] atIndex:0 margins:UIEdgeInsetsMake(2, 2, 2, 7) verticalTextAlignment:NIVerticalTextAlignmentMiddle];
    _pullReloadDescLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_pullReloadDescLabel];
  }
  return _pullReloadDescLabel;
}

- (NIAttributedLabel *)sampleGameDescLabel {
  if (nil ==_sampleGameDescLabel) {
    self.sampleGameDescLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _sampleGameDescLabel.textColor = [UIColor carryuColor];
    _sampleGameDescLabel.backgroundColor = [UIColor clearColor];
    _sampleGameDescLabel.font = [UIFont defaultFont];
    _sampleGameDescLabel.textAlignment = NSTextAlignmentCenter;
    _sampleGameDescLabel.text = NSLocalizedString(@"preview_sample_game_desc", nil);
    [self addSubview:_sampleGameDescLabel];
  }
  return _sampleGameDescLabel;
}

- (NIAttributedLabel *)titleLabel {
  if (nil == _titleLabel) {
    self.titleLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor carryuColor];
    _titleLabel.text = NSLocalizedString(@"out_of_game_description", nil);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.lineHeight = 24;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
  }
  return _titleLabel;
}

- (FUIButton *)tutorialVideoButton {
  if (nil == _tutorialVideoButton) {
    self.tutorialVideoButton = [FUIButton lcButtonWithTitle:NSLocalizedString(@"tutorial_btn_title", nil)];
    [self addSubview:_tutorialVideoButton];
  }
  return _tutorialVideoButton;
}

- (FUIButton *)previewButton {
  if (nil == _previewButton) {
    self.previewButton = [FUIButton lcButtonWithTitle:NSLocalizedString(@"preview_game_btn_title", nil)];
    _previewButton.buttonColor = [UIColor midnightBlueColor];
    _previewButton.shadowColor = [UIColor blackColor];
    [self addSubview:_previewButton];
  }
  return _previewButton;
}

- (UIImageView *)backgroundView {
  if (nil == _backgroundView) {
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    _backgroundView.frame = self.bounds;
  }
  return _backgroundView;
}

@end

