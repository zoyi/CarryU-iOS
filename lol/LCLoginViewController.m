//
//  LCLoginViewController.m
//  lol
//
//  Created by Di Wu on 6/14/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCLoginViewController.h"
#import "LCAppDelegate.h"
#import <ActionSheetPicker2/ActionSheetStringPicker.h>

static NSInteger kUsernameTextFieldTag = 234;
static NSInteger kPasswordTextFieldTag = 2389;
static CGFloat kDefaultServerIndicatorWidth = 30;

@interface LCLoginViewController () <UITextFieldDelegate, NIPagingScrollViewDataSource, NIPagingScrollViewDelegate>

@property (nonatomic, strong) NITableViewActions *actions;
@property (nonatomic, strong) NITableViewModel *model;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) NICellFactory *cellFactory;
@property (nonatomic, strong) NIPagingScrollView *regionPickerView;

- (void)login;
- (void)hideKeyboard;
- (NSArray *)pickerDataSource;

- (void)setPrevServer;
- (void)setNextServer;
@end

@implementation LCLoginViewController

- (void)loadView {
  [super loadView];
  [self backgroundView];
  UIImageView *labelView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lol_label.png"]];
  labelView.right = [UIScreen mainScreen].bounds.size.width;
  [self.view addSubview:labelView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[GAI sharedInstance].defaultTracker sendView:@"/LoginScreen"];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.actions = [[NITableViewActions alloc] initWithTarget:self];
  self.cellFactory = [[NICellFactory alloc] init];
  self.tableView.delegate = [self.actions forwardingTo:self];

  NSArray *tableForm =
  @[
    NSLocalizedString(@"use_your_lol_account_desc", nil),
    [NITextInputFormElement textInputElementWithID:kUsernameTextFieldTag placeholderText:NSLocalizedString(@"name_placeholder", nil) value:[[NSUserDefaults standardUserDefaults] stringForKey:kUsernameKey] delegate:self],
    [NITextInputFormElement passwordInputElementWithID:kPasswordTextFieldTag placeholderText:NSLocalizedString(@"password_placeholder", nil) value:[[NSUserDefaults standardUserDefaults] stringForKey:kPasswordKey] delegate:self]
    ];
  [_cellFactory mapObjectClass:[NITextInputFormElement class] toCellClass:[LCTextInputFormElementCell class]];
  self.model = [[NITableViewModel alloc] initWithSectionedArray:tableForm delegate:(id)_cellFactory];
  
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.separatorColor = RGBCOLOR(0x72, 0x88, 0x9e);
  self.tableView.dataSource = _model;
  self.tableView.scrollEnabled = NO;

  self.tableView.tableHeaderView = [self headerView];
  self.tableView.tableFooterView = [self footerView];

  UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView)];

  //  tap.cancelsTouchesInView = NO;

  [self.tableView addGestureRecognizer:tap];
  [self.regionPickerView reloadData];
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSInteger selectedPageIndex = [self.pickerDataSource indexOfObject:appDelegate.regeion];
  [self.regionPickerView setCenterPageIndex:selectedPageIndex];
}

- (UIImageView *)backgroundView {
  if (nil == _backgroundView) {
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    _backgroundView.image = [UIImage imageNamed:@"bg.png"];
    self.tableView.backgroundView = _backgroundView;
  }
  return _backgroundView;
}

- (UIView *)footerView {
  UIView *footerView = [[UIView alloc] init];
  CGFloat top = 0;
  CGFloat left = 10;
  FUIButton *loginButton = [FUIButton lcButtonWithTitle:NSLocalizedString(@"login_btn_label", nil)];
  loginButton.frame = CGRectMake(left, top, [UIScreen mainScreen].bounds.size.width - 2*left, 44);
  [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
  [footerView addSubview:loginButton];
  CGFloat serverTopPadding = 20;
  if (isiPhone5) {
    serverTopPadding = 30;
  }
  top += loginButton.frame.size.height + serverTopPadding;

  {
    CGFloat innerLeft = left;

    // prev
     
    NINetworkImageView *prevIndicatorView = [[NINetworkImageView alloc] initWithImage:[UIImage imageNamed:@"server_prev.png"]];
    prevIndicatorView.contentMode = UIViewContentModeTopLeft;
    prevIndicatorView.size = CGSizeMake(kDefaultServerIndicatorWidth, kDefaultServerIndicatorWidth);
    prevIndicatorView.origin = CGPointMake(innerLeft, top);

    prevIndicatorView.userInteractionEnabled = YES;
    UITapGestureRecognizer *prevTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setPrevServer)];
    prevTapGesture.numberOfTapsRequired = 1;
    prevTapGesture.numberOfTouchesRequired = 1;
    [prevIndicatorView addGestureRecognizer:prevTapGesture];
    
    [footerView addSubview:prevIndicatorView];

    // next
    NINetworkImageView *nextIndicatorView = [[NINetworkImageView alloc] initWithImage:[UIImage imageNamed:@"server_next.png"]];
    nextIndicatorView.top = top;
    nextIndicatorView.contentMode = UIViewContentModeTopRight;
    nextIndicatorView.size = CGSizeMake(kDefaultServerIndicatorWidth, kDefaultServerIndicatorWidth);
    nextIndicatorView.userInteractionEnabled = YES;
    UITapGestureRecognizer *nextTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextServer)];
    nextTapGesture.numberOfTapsRequired = 1;
    nextTapGesture.numberOfTouchesRequired = 1;
    [nextIndicatorView addGestureRecognizer:nextTapGesture];
    
    nextIndicatorView.right = [UIScreen mainScreen].bounds.size.width - innerLeft;
    [footerView addSubview:nextIndicatorView];

    self.regionPickerView.frame = CGRectMake(prevIndicatorView.right, top, nextIndicatorView.left - prevIndicatorView.right, loginButton.height);
    [footerView addSubview:_regionPickerView];
    top += _regionPickerView.height;
  }
  
  footerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, top);
  return footerView;
}

- (NIPagingScrollView *)regionPickerView {
  if (nil == _regionPickerView) {
    self.regionPickerView = [[NIPagingScrollView alloc] initWithFrame:CGRectZero];
    _regionPickerView.dataSource = self;
    _regionPickerView.delegate = self;
  }
  return _regionPickerView;
}

- (UIView *)headerView {
  UIView *headerView = [[UIView alloc] init];
  CGFloat top = 14;


  UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
  [logoView sizeToFit];
  logoView.left = floorf(([UIScreen mainScreen].bounds.size.width - logoView.width)/2);
  logoView.top = top;
 
  [headerView addSubview:logoView];
  top = logoView.bottom;
  if (!isiPhone5) {
    top -= 20;
  }
  headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, top);
  return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    NSString *title = [_model tableView:tableView titleForHeaderInSection:section];
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectZero];
    if (isiPhone5) {
      sectionHeader.height = 50;
    }
    NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor carryuColor];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    label.width = 300;
    [label sizeToFit];
    CGFloat labelTop = MAX(sectionHeader.height - label.height, 0);
    label.origin = CGPointMake(10, labelTop);

    [sectionHeader addSubview:label];
    sectionHeader.frame = CGRectMake(0, 0, 320, MAX(sectionHeader.height, label.height) + 5);
    NIDPRINT(@"section header frame = %@", NSStringFromCGRect(label.frame));
    return sectionHeader;
  }
  return nil;
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - picker methods

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView {
  NSInteger index = pagingScrollView.centerPageIndex;
  NSString *selectedValue = [self.pickerDataSource objectAtIndex:index];
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  appDelegate.regeion = [selectedValue lowercaseString];
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
  LCRegionPageView *pageView = [[LCRegionPageView alloc] initWithFrame:pagingScrollView.bounds];
  pageView.label.text = [NSString stringWithFormat:NSLocalizedString(@"server_picker_format", nil), NSLocalizedString([self.pickerDataSource objectAtIndex:pageIndex], nil)];
  return pageView;
}

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
  return self.pickerDataSource.count;
}

- (NSArray *)pickerDataSource {
  return @[@"kr", @"na"];
}
//////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  // Customize the presentation of certain types of cells.
  if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
    NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
    [self textFieldDidEndEditing:textInputCell.textField];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return [self tableView:tableView viewForHeaderInSection:section].height;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (self.view.top >= 0) {
    [UIView animateWithDuration:0.3 animations:^{
      if (isiPhone5) {
        self.view.top = -120;
      } else {
        self.view.top = -140;
      }
    }];
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (textField.tag == kUsernameTextFieldTag) {
    self.username = [textField.text lowercaseString];
  } else if (textField.tag == kPasswordTextFieldTag) {
    self.password = textField.text;
  }
  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self hideKeyboard];
  return YES;
}

- (void)didTapTableView {
  [self hideKeyboard];
  [self.view endEditing:YES];
}

- (void)hideKeyboard {
  [UIView animateWithDuration:0.25 animations:^{
    self.view.top = NIStatusBarHeight();
  }];
}

- (void)setPrevServer {
  if ([_regionPickerView hasPrevious]) {
    [_regionPickerView moveToPreviousAnimated:YES];
  } else {
    [_regionPickerView moveToPageAtIndex:_regionPickerView.numberOfPages -1 animated:YES];
  }
}

- (void)setNextServer {
  if ([_regionPickerView hasNext]) {
    [_regionPickerView moveToNextAnimated:YES];
  } else {
    [_regionPickerView moveToPageAtIndex:0 animated:YES];
  }
}

- (void)login {
  NIDPRINT(@"curreny usename = %@, password = %@", _username, _password);
  [self didTapTableView];
  if (_username.length == 0 || _password.length == 0) {
    [[SIAlertView carryuWarningAlertWithMessage:NSLocalizedString(@"username_or_password_cant_be_blank_msg", nil)] show];
    return;
  }
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate connectWithJID:_username password:_password];
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

@implementation LCRegionPageView
@synthesize pageIndex = _pageIndex;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.label.frame = self.bounds;
  }
  return self;
}

- (NIAttributedLabel *)label {
  if (nil == _label) {
    self.label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _label.font = [UIFont systemFontOfSize:17];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor carryuColor];
    [self addSubview:_label];
  }
  return _label;
}

- (void)setPageIndex:(NSInteger)pageIndex {
  _pageIndex = pageIndex;
  
  [self setNeedsLayout];
}

- (void)prepareForReuse {
  self.label.text = nil;
}

@end

