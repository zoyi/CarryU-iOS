//
//  LCSigninSelectorViewController.m
//  lol
//
//  Created by Di Wu on 8/21/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSigninSelectorViewController.h"
#import "LCSigninFormViewController.h"
#import "UIViewController+LCCategory.h"

static CGFloat const kMidPadding = 30.f;
static CGFloat const kSamllPadding = 10.f;

@interface LCSigninSelectorViewController ()
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *previewSampleView;
- (void)showRiotLoginAlert;
- (void)showSummonerNameBindingAlert;
@end

@implementation LCSigninSelectorViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style activityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = NSLocalizedString(@"login", nil);

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)loadView {
  [super loadView];
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];

  [self.tableView.superview addSubview:self.previewSampleView];
  UIEdgeInsets tableViewEdgeInsets = UIEdgeInsetsMake(0, 0, _previewSampleView.height, 0);
  [self.tableView setContentInset:tableViewEdgeInsets];
  [self.tableView setScrollIndicatorInsets:tableViewEdgeInsets];

  self.tableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (UIView *)footerView {
  if (nil == _footerView) {
    // login with riot account
    self.footerView = [[UIView alloc] initWithFrame:CGRectZero];
    _footerView.backgroundColor = [UIColor clearColor];
    CGFloat top = 70, left = 10;
    LCLoginBox *riotAccountBox = [[LCLoginBox alloc] initWithFrame:CGRectZero];
    [riotAccountBox.button addTarget:self action:@selector(showRiotLoginAlert) forControlEvents:UIControlEventTouchUpInside];
    [riotAccountBox.button setTitle:NSLocalizedString(@"login_with_riot_account_btn_title", nil) forState:UIControlStateNormal];
    riotAccountBox.titleLabel.text = NSLocalizedString(@"login_with_riot_account_desc", nil);
    riotAccountBox.width = self.view.width - left *2;
    [riotAccountBox sizeToFit];
    riotAccountBox.origin = CGPointMake(left, top);
    [_footerView addSubview:riotAccountBox];
    top += riotAccountBox.height + kSamllPadding;

    // divider
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(left, top, riotAccountBox.width, 1)];
    dividerView.backgroundColor = [UIColor carryuColor];
    [_footerView addSubview:dividerView];
    top += dividerView.height + kMidPadding*1.5;

    LCLoginBox *summonerNameBox = [[LCLoginBox alloc] initWithFrame:CGRectZero];
    [summonerNameBox.button addTarget:self action:@selector(showSummonerNameBindingAlert) forControlEvents:UIControlEventTouchUpInside];
    [summonerNameBox.button setTitle:NSLocalizedString(@"login_with_summoner_name_btn_title", nil) forState:UIControlStateNormal];
    summonerNameBox.titleLabel.text = NSLocalizedString(@"login_with_summoner_name_desc", nil);
    summonerNameBox.width = self.view.width - left*2;
    [summonerNameBox sizeToFit];
    summonerNameBox.origin = CGPointMake(left, top);
    [_footerView addSubview:summonerNameBox];
    top += summonerNameBox.height;

    _footerView.size = CGSizeMake(self.view.width, top);

  }
  return _footerView;
}

- (UIView *)previewSampleView {
  if (nil == _previewSampleView) {
    self.previewSampleView = [[UIView alloc] initWithFrame:CGRectZero];
    _previewSampleView.backgroundColor = [UIColor clearColor];
    CGFloat top = kSamllPadding, left = kSamllPadding;
    NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor carryuColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"preview_sample_game_desc", nil);
    CGFloat labelWidth = self.view.width - 2*left;
    label.width = labelWidth;
    [label sizeToFit];
    label.width = labelWidth;
    [_previewSampleView addSubview:label];
    top += label.height + 8;

    FUIButton *button = [FUIButton lcButtonWithTitle:NSLocalizedString(@"preview_game_btn_title", nil)];
    button.frame = CGRectMake(left, top, self.view.width - left*2, 44);
    [button addTarget:self action:@selector(showSampleGame) forControlEvents:UIControlEventTouchUpInside];
    [_previewSampleView addSubview:button];
    top += button.height + kSamllPadding;
    _previewSampleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                           | UIViewAutoresizingFlexibleTopMargin
                                           );
    _previewSampleView.frame = CGRectMake(0, self.view.bounds.size.height - top, self.view.width, top);
  }
  return _previewSampleView;
}

- (void)showRiotLoginAlert {
  LCSigninRiotFormViewController *controller = [[LCSigninRiotFormViewController alloc] initWithStyle:UITableViewStyleGrouped];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)showSummonerNameBindingAlert {
  LCSigninSummonerNameFormViewController *controller = [[LCSigninSummonerNameFormViewController alloc] initWithStyle:UITableViewStyleGrouped];
  [self.navigationController pushViewController:controller animated:YES];
}

@end


@implementation LCLoginBox

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
  if (CGSizeEqualToSize(CGSizeZero, size)) {
    size = self.bounds.size;
  }
  CGFloat top = 0;

  if (_titleLabel.text.length) {
    CGFloat labelWidth = size.width - kSamllPadding*2;
    _titleLabel.width = labelWidth;
    [_titleLabel sizeToFit];
    _titleLabel.width = labelWidth;
    _titleLabel.origin = CGPointMake(kSamllPadding, top);
    top += _titleLabel.height + kMidPadding;
  }

  _button.frame = CGRectMake(kSamllPadding, top, size.width - kSamllPadding*2, 44);

  top += _button.height + kMidPadding;
  return CGSizeMake(size.width, top);
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self sizeThatFits:self.bounds.size];
}

- (NIAttributedLabel *)titleLabel {
  if (nil == _titleLabel) {
    self.titleLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = [UIColor carryuColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    _titleLabel.backgroundColor = self.backgroundColor;
    [self addSubview: _titleLabel];
  }
  return _titleLabel;
}

- (FUIButton *)button {
  if (nil == _button) {
    self.button = [FUIButton lcButtonWithTitle:NSLocalizedString(@"login", nil)];
    [self addSubview:_button];
  }
  return _button;
}

@end
