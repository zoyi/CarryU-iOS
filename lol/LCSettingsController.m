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
#import <objc/message.h>
#import <uservoice-iphone-sdk/UserVoice.h>

@interface LCSettingsController () <NIRadioGroupDelegate>
@property (nonatomic, strong) NIMutableTableViewModel *model;
@property (nonatomic, strong) NITableViewActions *actions;
@property (nonatomic, strong) NITableViewModelFooter *footer;
@property (nonatomic, strong) NICellFactory *cellFactory;
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

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[GAI sharedInstance].defaultTracker sendView:@"/SettingsScreen"];
}

- (void)loadView {
  [super loadView];
  [self radioGroup];
  self.cellFactory = [[NICellFactory alloc] init];
  self.actions = [[NITableViewActions alloc] initWithTarget:self];
  
  [_cellFactory mapObjectClass:[NITitleCellObject class] toCellClass:[LCRadioTitleCell class]];
  [_cellFactory mapObjectClass:[NISwitchFormElement class] toCellClass:[LCSwitchFormElementCell class]];

  self.model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)_cellFactory];
  [_model addSectionWithTitle:@""];
  [_model addObject:[NISwitchFormElement switchElementWithID:12 labelText:NSLocalizedString(@"keep_screen_on", nil) value:[LCSettingsInfo sharedInstance].keepScreenOn didChangeTarget:self didChangeSelector:@selector(keepScreenOnControlDidChanged:)]];

  [_model addSectionWithTitle:NSLocalizedString(@"search_engine_section_title", nil)];

  NSDictionary *searchEngines = [LCSettingsInfo sharedInstance].currentRegionSearchEngines;

  [[searchEngines sortedAllKeys] each:^(NSString *key) {
    NSUInteger index = [[searchEngines sortedAllKeys] indexOfObject:key];
    [_model addObject:[_radioGroup mapObject:[NITitleCellObject objectWithTitle:key] toIdentifier:index]];
    if ([key isEqualToString:[LCSettingsInfo sharedInstance].choosedSearchEngine]) {
      [_radioGroup setSelectedIdentifier:index];
    }
  }];

  [_model addSectionWithTitle:@""];
  [_model addObject:[_actions attachToObject:[NISubtitleCellObject objectWithTitle:NSLocalizedString(@"faq_n_feedback", nil)] tapBlock:^BOOL(id object, id target) {
    LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UVConfig *config = nil;
    if ([appDelegate.regeion isEqualToString:@"kr"]) {
      config = [UVConfig configWithSite:@"carryukr.uservoice.com" andKey:@"HTYpZ28NKWvR1rBQo23Q" andSecret:@"yeApEnh3yvHWtgIpasWy3Zp21TlhmIzTQtGD7nO1Ow"];

    } else {
      config = [UVConfig configWithSite:@"carryu.uservoice.com"
                                         andKey:@"rl1xXqEXPx2Q8Co7IZ7TKQ"
                                      andSecret:@"F9l79tMF92Afx59eU58rXQsAxrtwguKTzKgV5QL8YK4"];
    }

    [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];

    [[GAI sharedInstance].defaultTracker sendView:@"/SettingsScreen/Feedback"];
    return YES;
  }]];

}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.separatorColor = [UIColor carryuColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.dataSource = self.model;
  self.tableView.delegate = [self.radioGroup forwardingTo:[self.actions forwardingTo:self]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)keepScreenOnControlDidChanged:(FUISwitch *)switchControl {
  [LCSettingsInfo sharedInstance].keepScreenOn = switchControl.isOn;
  NIDPRINT(@"value is %d", switchControl.on);
}

- (NIRadioGroup *)radioGroup {
  if (nil == _radioGroup) {
    self.radioGroup = [NIRadioGroup new];
    _radioGroup.delegate = self;
    _radioGroup.tableViewCellSelectionStyle = UITableViewCellSelectionStyleGray;
  }
  return _radioGroup;
}

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
  [LCSettingsInfo sharedInstance].choosedSearchEngine = [[[LCSettingsInfo sharedInstance].currentRegionSearchEngines sortedAllKeys] objectAtIndex:identifier];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSString *title = [self.model tableView:tableView titleForHeaderInSection:section];
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
  NIAttributedLabel *headerLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
  headerLabel.textColor = [UIColor carryuColor];
  headerLabel.text = title;
  headerLabel.font = [UIFont systemFontOfSize:17];
  headerLabel.backgroundColor = [UIColor clearColor];
  [headerLabel sizeToFit];
  [headerView addSubview:headerLabel];
  headerLabel.centerY = headerView.centerY;
  headerView.backgroundColor = [UIColor clearColor];
  return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([tableView.dataSource isKindOfClass:[NITableViewModel class]]);
  if ([tableView.dataSource isKindOfClass:[NITableViewModel class]]) {
    NITableViewModel* model = (NITableViewModel *)tableView.dataSource;
    id object = [model objectAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor carryuColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    if ([self.radioGroup isObjectInRadioGroup:object]) {
      cell.accessoryType = UITableViewCellAccessoryNone;
      if ([self.radioGroup isObjectSelected:object]
          && [cell isKindOfClass:[LCRadioTitleCell class]]) {
        [[(LCRadioTitleCell *)cell checkmarkImageView] setHidden:NO];
      } else {
        [[(LCRadioTitleCell *)cell checkmarkImageView] setHidden:YES];
      }
    }
  }

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  NSString *title = nil;
  if (section == 0) {
    title = NSLocalizedString(@"keep_screen_on_desc", nil);
  }
  UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
  footerView.backgroundColor = [UIColor clearColor];
  NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  label.text = title;
  label.backgroundColor = footerView.backgroundColor;
  label.textColor = [UIColor carryuColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.font = [UIFont systemFontOfSize:13];
  label.numberOfLines = 0;
  if (label.text.length) {
    label.width = 200;
    [label sizeToFit];
    label.width = 200;
    label.top = 15;
    label.left = 60;
    [footerView addSubview:label];
    footerView.frame = CGRectMake(0, 0, 320, label.height + 30);
  }
  return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  UIView *footerView = [self tableView:tableView viewForFooterInSection:section];
  return footerView.height;
}

@end

@implementation LCRadioTitleCell

- (void)layoutSubviews {
  [super layoutSubviews];
  [self checkmarkImageView];
}

- (UIImageView *)checkmarkImageView {
  if (nil == _checkmarkImageView) {
    self.checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    self.checkmarkImageView.top = floorf((self.contentView.height - _checkmarkImageView.height)/2);
    self.checkmarkImageView.right = [UIScreen mainScreen].bounds.size.width - 30;
    self.checkmarkImageView.hidden = YES;
    [self.contentView addSubview:_checkmarkImageView];
  }
  return _checkmarkImageView;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.checkmarkImageView.hidden = YES;
}

@end

@implementation LCSwitchFormElementCell

- (BOOL)shouldUpdateCellWithObject:(NISwitchFormElement *)switchElement {
  if ([super shouldUpdateCellWithObject:switchElement]) {
    self.flatSwitchControl.on = switchElement.value;
    self.textLabel.text = switchElement.labelText;

    _flatSwitchControl.tag = self.tag;

    [self setNeedsLayout];
    return YES;
  }
  return NO;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.flatSwitchControl.frame = CGRectZero;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self.switchControl setHidden:YES];
  self.flatSwitchControl.frame = self.switchControl.frame;
}

- (FUISwitch *)flatSwitchControl {
  if (nil == _flatSwitchControl) {
    self.flatSwitchControl = [[FUISwitch alloc] initWithFrame:CGRectZero];
    _flatSwitchControl.onColor = RGBCOLOR(0x01, 0xe2, 0xf0);
    _flatSwitchControl.offColor = RGBCOLOR(0x41, 0x54, 0x68);
    _flatSwitchControl.onBackgroundColor = [UIColor midnightBlueColor];
    _flatSwitchControl.offBackgroundColor = [UIColor carryuColor];
    _flatSwitchControl.offLabel.font = [UIFont boldFlatFontOfSize:14];
    _flatSwitchControl.onLabel.font = [UIFont boldFlatFontOfSize:14];
    _flatSwitchControl.layer.cornerRadius = 14.f;
    [_flatSwitchControl addTarget:self action:@selector(switchDidChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_flatSwitchControl];
  }
  return _flatSwitchControl;
}

- (void)switchDidChangeValue {
  NISwitchFormElement* switchElement = (NISwitchFormElement *)self.element;
  switchElement.value = _flatSwitchControl.isOn;

  if (nil != switchElement.didChangeSelector && nil != switchElement.didChangeTarget
      && [switchElement.didChangeTarget respondsToSelector:switchElement.didChangeSelector]) {

    // This throws a warning a seclectors that the compiler do not know about cannot be
    // memory managed by ARC
    //[switchElement.didChangeTarget performSelector: switchElement.didChangeSelector
    //                                    withObject: _switchControl];

    // The following is a workaround to supress the warning and requires <objc/message.h>
    objc_msgSend(switchElement.didChangeTarget,
                 switchElement.didChangeSelector, _flatSwitchControl);
  }
}

@end
