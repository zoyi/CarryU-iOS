//
//  LCSettingsController.m
//  lol
//
//  Created by Di Wu on 6/27/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSettingsController.h"
#import "LCSettingsInfo.h"
#import "LCAppDelegate.h"

@interface LCSettingsController () <NIRadioGroupDelegate>
@property (nonatomic, strong) NIMutableTableViewModel *model;

@property (nonatomic, readwrite, retain) NIRadioGroup* radioGroup;

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
  [self radioGroup];
  
  self.model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];
  [_model addSectionWithTitle:@""];
  [_model addObject:[NISwitchFormElement switchElementWithID:12 labelText:@"Keep screep on:" value:NO didChangeTarget:self didChangeSelector:@selector(keepScreenOnControlDidChanged:)]];
  [_model addSectionWithTitle:@"Radio group"];

  NSDictionary *searchEngines = [LCSettingsInfo sharedInstance].searchEngines;

  [[searchEngines allKeys] each:^(NSString *key) {
    NSUInteger index = [[searchEngines allKeys] indexOfObject:key];

    [_model addObject:[_radioGroup mapObject:[NITitleCellObject objectWithTitle:key] toIdentifier:index]];
    if ([key isEqualToString:[LCSettingsInfo sharedInstance].choosedSearchEngine]) {
      [_radioGroup setSelectedIdentifier:index];
    }
  }];

}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.backgroundView = nil;
  self.tableView.backgroundColor = [UIColor cloudsColor];
  self.tableView.dataSource = self.model;
  self.tableView.delegate = [self.radioGroup forwardingTo:self.tableView.delegate];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)keepScreenOnControlDidChanged:(UISwitch *)switchControl {
  [UIApplication sharedApplication].idleTimerDisabled = switchControl.on;
  [LCSettingsInfo sharedInstance].keepScreenOn = switchControl.on;
  NIDPRINT(@"value is %d", switchControl.on);
}

- (NIRadioGroup *)radioGroup {
  if (nil == _radioGroup) {
    self.radioGroup = [NIRadioGroup new];
    _radioGroup.delegate = self;
  }
  return _radioGroup;
}

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
  [LCSettingsInfo sharedInstance].choosedSearchEngine = [[[LCSettingsInfo sharedInstance].searchEngines allKeys] objectAtIndex:identifier];
}

@end
