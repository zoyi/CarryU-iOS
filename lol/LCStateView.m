//
//  LCStateView.m
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCStateView.h"

static const CGFloat kVPadding1 = 30.0f;
static const CGFloat kVPadding2 = 10.0f;
static const CGFloat kVPadding3 = 15.0f;
static const CGFloat kHPadding  = 10.0f;

@interface LCStateView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UILabel *subtitleView;

@end

@implementation LCStateView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addReloadButton {
  _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_reloadButton setImage:[UIImage imageNamed:@"reloadButton.png"]
                 forState:UIControlStateNormal];
  [_reloadButton setImage:[UIImage imageNamed:@"reloadButtonActive.png"] forState:UIControlStateHighlighted];
  [_reloadButton sizeToFit];
  [self addSubview:_reloadButton];

  [self layoutSubviews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image {
	self = [self init];
  if (self) {
    self.title = title;
    self.subtitle = subtitle;
    self.image = image;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];

    _titleView = [[UILabel alloc] init];
    _titleView.backgroundColor = [UIColor clearColor];
    _titleView.textColor = RGBCOLOR(96, 103, 111);
    _titleView.font = [UIFont boldSystemFontOfSize:18];
    _titleView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleView];

    _subtitleView = [[UILabel alloc] init];
    _subtitleView.backgroundColor = [UIColor clearColor];
    _subtitleView.textColor = RGBCOLOR(96, 103, 111);
    _subtitleView.font = [UIFont boldSystemFontOfSize:12];
    _subtitleView.textAlignment = NSTextAlignmentCenter;
    _subtitleView.numberOfLines = 0;
    [self addSubview:_subtitleView];
  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  _subtitleView.size = [_subtitleView sizeThatFits:CGSizeMake(self.width - kHPadding*2, 0)];
  [_titleView sizeToFit];
  [_imageView sizeToFit];

  CGFloat maxHeight = _imageView.height + _titleView.height + _subtitleView.height
  + kVPadding1 + kVPadding2;
  BOOL canShowImage = _imageView.image && self.height > maxHeight;

  CGFloat totalHeight = 0.0f;

  if (canShowImage) {
    totalHeight += _imageView.height;
  }
  if (_titleView.text.length) {
    totalHeight += (totalHeight ? kVPadding1 : 0) + _titleView.height;
  }
  if (_subtitleView.text.length) {
    totalHeight += (totalHeight ? kVPadding2 : 0) + _subtitleView.height;
  }

  totalHeight += (totalHeight ? kVPadding3 : 0) + _reloadButton.height;

  CGFloat top = floor(self.height/2 - totalHeight/2);

  if (canShowImage) {
    _imageView.origin = CGPointMake(floor(self.width/2 - _imageView.width/2), top);
    _imageView.hidden = NO;
    top += _imageView.height + kVPadding1;

  } else {
    _imageView.hidden = YES;
  }
  if (_titleView.text.length) {
    _titleView.origin = CGPointMake(floor(self.width/2 - _titleView.width/2), top);
    top += _titleView.height + kVPadding2;
  }
  if (_subtitleView.text.length) {
    _subtitleView.origin = CGPointMake(floor(self.width/2 - _subtitleView.width/2), top);
    top += _subtitleView.height + kVPadding3;
  }

  if (_reloadButton!=nil) {
    _reloadButton.origin = CGPointMake(floor(self.width/2 - _reloadButton.width/2), top);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)title {
  return _titleView.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTitle:(NSString*)title {
  _titleView.text = title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitle {
  return _subtitleView.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSubtitle:(NSString*)subtitle {
  _subtitleView.text = subtitle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)image {
  return _imageView.image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(UIImage*)image {
  _imageView.image = image;
}


@end
