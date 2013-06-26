//
//  LCSettingsController.m
//  lol
//
//  Created by Di Wu on 6/27/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSettingsController.h"

@interface LCSettingsController ()
@property (nonatomic, strong) NITableViewModel *model;
- (void)keepScreenOnControlDidChanged:(UISwitch *)switchControl;
@end

@implementation LCSettingsController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)loadView {
  [super loadView];
  NSArray *tableContent =
  @[@"",
    [NISwitchFormElement switchElementWithID:12 labelText:@"Keep screep on:" value:NO didChangeTarget:self didChangeSelector:@selector(keepScreenOnControlDidChanged:)]
    ];
  self.model = [[NITableViewModel alloc] initWithSectionedArray:tableContent delegate:(id)[NICellFactory class]];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.backgroundView = nil;
  self.tableView.backgroundColor = [UIColor cloudsColor];
  self.tableView.dataSource = self.model;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)keepScreenOnControlDidChanged:(UISwitch *)switchControl {
  [UIApplication sharedApplication].idleTimerDisabled = switchControl.on;
  NIDPRINT(@"value is %d", switchControl.on);
}

@end
