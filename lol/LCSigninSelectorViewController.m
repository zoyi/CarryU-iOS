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
- (void)showRiotLoginPage;
- (void)showSummonerNameBindingPage;
- (void)checkServerStatus;
- (UIView *)errorViewWithMessage:(NSString *)message;
@end

@implementation LCSigninSelectorViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  [refreshControl addTarget:self action:@selector(checkServerStatus) forControlEvents:UIControlEventValueChanged];
  refreshControl.tintColor = [UIColor carryuColor];
  self.refreshControl = refreshControl;
  self.title = NSLocalizedString(@"home", nil);

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self checkServerStatus];
}

- (void)loadView {
  [super loadView];
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];

  [self.view addSubview:self.previewSampleView];
  UIEdgeInsets tableViewEdgeInsets = UIEdgeInsetsMake(0, 0, _previewSampleView.height, 0);
  [self.tableView setContentInset:tableViewEdgeInsets];
  [self.tableView setScrollIndicatorInsets:tableViewEdgeInsets];
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
    CGFloat top = self.view.height / 15, left = 10;
    if (isiPhone5) {
      top = self.view.height / 10;
    }
    LCLoginBox *riotAccountBox = [[LCLoginBox alloc] initWithFrame:CGRectZero];
    [riotAccountBox.button addTarget:self action:@selector(showRiotLoginPage) forControlEvents:UIControlEventTouchUpInside];
    [riotAccountBox.button setTitle:NSLocalizedString(@"login_with_riot_account_btn_title", nil) forState:UIControlStateNormal];
    riotAccountBox.titleLabel.text = NSLocalizedString(@"login_with_riot_account_desc", nil);
    riotAccountBox.width = self.view.width - left *2;
    [riotAccountBox sizeToFit];
    riotAccountBox.origin = CGPointMake(left, top);
    [_footerView addSubview:riotAccountBox];
    top += riotAccountBox.height + kSamllPadding;

    // divider
    UIImageView *dividerView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, riotAccountBox.width, 1)];
    dividerView.image = [UIImage imageNamed:@"hr"];
    [_footerView addSubview:dividerView];
    top += dividerView.height;
    if (isiPhone5) {
      top += kMidPadding*1.5;
    } else {
      top += kMidPadding;
    }

    LCLoginBox *summonerNameBox = [[LCLoginBox alloc] initWithFrame:CGRectZero];
    [summonerNameBox.button addTarget:self action:@selector(showSummonerNameBindingPage) forControlEvents:UIControlEventTouchUpInside];
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
    CGFloat top = 0, left = kSamllPadding*2;
    NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = _previewSampleView.backgroundColor;
    label.textColor = [UIColor carryuColor];
    label.font = [UIFont defaultFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"preview_sample_game_desc", nil);
    CGFloat labelWidth = self.view.width - 2*left;
    label.width = labelWidth;
    [label sizeToFit];
    label.width = labelWidth;
    label.origin = CGPointMake(left, top);
    [_previewSampleView addSubview:label];
    top += label.height + 8;

    FUIButton *button = [FUIButton lcButtonWithTitle:NSLocalizedString(@"preview_game_btn_title", nil)];
    button.frame = CGRectMake(left, top, self.view.width - left*2, 44);
    button.buttonColor = [UIColor midnightBlueColor];
    button.shadowColor = [UIColor blackColor];
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

- (UIView *)errorViewWithMessage:(NSString *)message {
  UIView *errorView = [[UIView alloc] initWithFrame:CGRectZero];
  errorView.backgroundColor = [UIColor clearColor];
  CGFloat left = 10, top = 50;

  NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  label.numberOfLines = 0;
  label.textAlignment = NSTextAlignmentCenter;
  label.textColor = [UIColor carryuColor];
  label.backgroundColor = errorView.backgroundColor;
  label.font = [UIFont largeFont];
  label.text = message.length ? message : NSLocalizedString(@"default_server_status_error_msg", nil);

  CGFloat labelWidth = self.view.width - 2*left;
  label.width = labelWidth;
  [label sizeToFit];
  label.frame = CGRectMake(left, top, labelWidth, label.height);
  [errorView addSubview:label];
  top += label.height;
  errorView.size = CGSizeMake(self.view.width, top);
  return errorView;
}

- (void)checkServerStatus {
  RKRequestMethod requestMethod;
  NSURL *requestUrl = [[LCApiRouter sharedInstance] URLForRouteNamed:@"status" method:&requestMethod object:nil]; 
  NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];

  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    self.tableView.tableFooterView = self.footerView;
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    NSString *errorMsg = nil;
    NSArray *errorStrs = [JSON objectForKey:@"errors"];
    if ([errorStrs isKindOfClass:[NSArray class]]) {
      errorMsg = [[errorStrs map:^id(NSDictionary *obj) {
        return [obj objectForKey:@"message"];
      }] componentsJoinedByString:@"\n"];
    }
    self.tableView.tableFooterView = [self errorViewWithMessage:errorMsg];
    [self.refreshControl endRefreshing];
    [SVProgressHUD dismiss];

  }];

  [SVProgressHUD showWithStatus:NSLocalizedString(@"checking_server_status", nil) maskType:SVProgressHUDMaskTypeBlack];
  [operation start];
}

- (void)showRiotLoginPage {
  LCSigninRiotFormViewController *controller = [[LCSigninRiotFormViewController alloc] initWithStyle:UITableViewStyleGrouped];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)showSummonerNameBindingPage {
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
    top += _titleLabel.height + kSamllPadding*2;
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
    _titleLabel.font = [UIFont defaultFont];
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
