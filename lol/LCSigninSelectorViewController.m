//
//  LCSigninSelectorViewController.m
//  lol
//
//  Created by Di Wu on 8/21/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSigninSelectorViewController.h"

@interface LCSigninSelectorViewController ()
@property (nonatomic, strong) UIView *footerView;
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
}

- (void)loadView {
  [super loadView];
  self.tableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (UIView *)footerView {
  if (nil == _footerView) {
    
  }
  return _footerView;
}

@end
