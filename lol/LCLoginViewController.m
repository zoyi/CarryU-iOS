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

@interface LCLoginViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NITableViewActions *actions;
@property (nonatomic, strong) NITableViewModel *model;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NITitleCellObject *regionObject;
- (void)login;

@end

@implementation LCLoginViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.actions = [[NITableViewActions alloc] initWithTarget:self];
  self.tableView.delegate = [self.actions forwardingTo:self];

  NSArray *tableForm = @[
                         @"",
                         [NITextInputFormElement textInputElementWithID:kUsernameTextFieldTag placeholderText:NSLocalizedString(@"username", nil) value:[[NSUserDefaults standardUserDefaults] stringForKey:kUsernameKey] delegate:self],
                         [NITextInputFormElement passwordInputElementWithID:kPasswordTextFieldTag placeholderText:NSLocalizedString(@"password", nil) value:@"" delegate:self],
                         @"",
                         [_actions attachToObject:self.regionObject tapBlock:^BOOL(id object, id target) {
                           [ActionSheetStringPicker showPickerWithTitle:@"Choose your region" rows:@[@"NA", @"KR"] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                             _regionObject.title = [NSString stringWithFormat:@"Server - %@", selectedValue];
                             LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                             appDelegate.regeion = [selectedValue lowercaseString];
                             [self.tableView reloadData];
                           } cancelBlock:^(ActionSheetStringPicker *picker) {
                             NIDPRINT(@"select canceld.");
                           } origin:self.tableView];
                           return YES;
                         }]
                         ];
  self.model = [[NITableViewModel alloc] initWithSectionedArray:tableForm delegate:(id)[NICellFactory class]];
  
  self.tableView.backgroundColor = [UIColor cloudsColor];
  self.tableView.backgroundView = nil;

  self.tableView.dataSource = _model;
  self.tableView.scrollEnabled = NO;

  self.tableView.tableHeaderView = [self headerView];
  self.tableView.tableFooterView = [self footerView];

  UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView)];

  tap.cancelsTouchesInView = NO;

  [self.tableView addGestureRecognizer:tap];
}

- (UIView *)footerView {
  UIView *footerView = [[UIView alloc] init];
  CGFloat top = 20;
  CGFloat left = 10;
  FUIButton *loginButton = [FUIButton lcButtonWithTitle:NSLocalizedString(@"login", nil)];
  loginButton.frame = CGRectMake(left, top, [UIScreen mainScreen].bounds.size.width - 2*left, 44);
  [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
  [footerView addSubview:loginButton];
  top += loginButton.frame.size.height + 30;

  footerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, top);
  return footerView;
}

- (UIView *)headerView {
  UIView *headerView = [[UIView alloc] init];
  return headerView;
}

- (NITitleCellObject *)regionObject {
  if (nil == _regionObject) {
    LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.regionObject = [[NITitleCellObject alloc] initWithTitle:[NSString stringWithFormat:@"Server - %@", [appDelegate.regeion uppercaseString]]];
  }
  return _regionObject;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  // Customize the presentation of certain types of cells.
  if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
    NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
    [self textFieldDidEndEditing:textInputCell.textField];
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (textField.tag == kUsernameTextFieldTag) {
    self.username = [textField.text lowercaseString];
  } else if (textField.tag == kPasswordTextFieldTag) {
    self.password = textField.text;
  }
}

- (void)didTapTableView {
  [self.view endEditing:YES];
}

- (void)login {
  NIDPRINT(@"curreny usename = %@, password = %@", _username, _password);
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate connectWithJID:_username password:_password];
}


@end
