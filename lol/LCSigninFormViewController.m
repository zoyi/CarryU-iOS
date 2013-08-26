//
//  LCSigninFormViewController.m
//  lol
//
//  Created by Di Wu on 8/23/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSigninFormViewController.h"
#import "UIBarButtonItem+LCCategory.h"
#import "LCAppDelegate.h"
#import "LCCurrentSummoner.h"

@interface LCSigninFormViewController ()

@property (nonatomic, strong) NITableViewModel *model;
@property (nonatomic, strong) NICellFactory *cellFactory;
@property (nonatomic, strong) UIView *footerView;

@end

@implementation LCSigninFormViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.dataSource = self.model;
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  self.tableView.tableFooterView = self.footerView;

  self.tableView.separatorColor = [UIColor carryuColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

  self.navigationItem.hidesBackButton = YES;
  self.navigationItem.leftBarButtonItem = [UIBarButtonItem carryuBackBarButtonItem];

  UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView)];

  //  tap.cancelsTouchesInView = NO;

  [self.tableView addGestureRecognizer:tap];
}

- (void)didTapTableView {
  [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return  30;
  }
  return 0;
}

- (NICellFactory *)cellFactory {
  if (nil == _cellFactory) {
    self.cellFactory = [NICellFactory new];
    [_cellFactory mapObjectClass:[NITextInputFormElement class] toCellClass:[LCTextInputFormElementCell class]];
  }
  return _cellFactory;
}

- (NITableViewModel *)model {
  if (nil == _model) {
    self.model = [[NITableViewModel alloc] initWithSectionedArray:[self tableContents] delegate:(id)self.cellFactory];
  }
  return _model;
}

- (NSArray *)tableContents {
  return nil;
}

- (UIView *)footerView {
  if (nil == _footerView) {
    self.footerView = [[UIView alloc] initWithFrame:CGRectZero];
    _footerView.backgroundColor = [UIColor clearColor];
    CGFloat top = 10.f , left = 10.f;
    FUIButton *button = [FUIButton lcButtonWithTitle:self.buttonTitle];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(left, top, self.view.width - left*2, 44);
    [_footerView addSubview:button];
    top += button.height + 20;

    NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    label.text = self.additionalNote;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = _footerView.backgroundColor;
    label.textColor = [UIColor carryuColor];
    label.width = self.view.width - left*2;

    [label sizeToFit];
    label.width = self.view.width - left*2;
    label.origin = CGPointMake(left, top);
    [_footerView addSubview:label];
    top += label.height;

    _footerView.size = CGSizeMake(self.view.width, top);
  }
  return _footerView;
}

- (void)buttonAction { }

- (NSString *)buttonTitle { return nil; }

- (NSString *)additionalNote { return nil; }

@end

@interface LCSigninRiotFormViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NITextInputFormElement *username;
@property (nonatomic, strong) NITextInputFormElement *password;
@end

@implementation LCSigninRiotFormViewController

- (void)buttonAction {

  if (_username.value.length == 0 || _password.value.length == 0) {
    [[SIAlertView carryuWarningAlertWithMessage:NSLocalizedString(@"username_or_password_cant_be_blank_msg", nil)] show];
    return;
  }
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate connectWithJID:_username.value password:_password.value];
}

- (NSString *)buttonTitle {
  return NSLocalizedString(@"login_btn_label", nil);
}

- (NSString *)additionalNote {
  return NSLocalizedString(@"using_password_description", nil);
}

- (NSArray *)tableContents {
  return @[@"", self.username, self.password];
}

- (NITextInputFormElement *)username {
  if (nil == _username) {
    self.username = [NITextInputFormElement textInputElementWithID:0 placeholderText:NSLocalizedString(@"name_placeholder", nil) value:nil delegate:self];
  }
  return _username;
}

- (NITextInputFormElement *)password {
  if (nil == _password) {
    self.password = [NITextInputFormElement passwordInputElementWithID:0 placeholderText:NSLocalizedString(@"password_placeholder", nil) value:nil delegate:self];
  }
  return _password;
}

@end

@interface LCSigninSummonerNameFormViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NITextInputFormElement *summonerName;
@end

@implementation LCSigninSummonerNameFormViewController

- (void)buttonAction {
  if (_summonerName.value.length) {
    [LCCurrentSummoner sharedInstance].name = _summonerName.value;
    LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.gameMode = LCObserveModeManual;
    [appDelegate rebuildHomeRootViewController];
  } else {
    [SIAlertView carryuAlertWithTitle:nil message:NSLocalizedString(@"summoner_name_cant_be_blank", nil)];
  }
}

- (NSString *)buttonTitle {
  return NSLocalizedString(@"binding", nil);
}

- (NSString *)additionalNote {
  return nil;
}

- (NSArray *)tableContents {
  return @[self.summonerName];
}

- (NITextInputFormElement *)summonerName {
  if (nil == _summonerName) {
    self.summonerName = [NITextInputFormElement textInputElementWithID:0 placeholderText:NSLocalizedString(@"summoner_name_placeholder", nil) value:nil delegate:self];
  }
  return _summonerName;
}

@end

@implementation LCTextInputFormElementCell

- (void)layoutSubviews {
  [super layoutSubviews];
  self.textField.textColor = [UIColor carryuColor];
  [self.textField setValue:[UIColor wetAsphaltColor] forKeyPath:@"_placeholderLabel.textColor"];
  if (!self.textField.isSecureTextEntry) {
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  }
  self.backgroundColor = RGBCOLOR(0x10, 0x13, 0x16);
}

@end
