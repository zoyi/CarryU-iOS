//
//  LCSettingsController.h
//  lol
//
//  Created by Di Wu on 6/27/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCSettingsController : UITableViewController

@end

@interface LCRadioTitleCell : NITextCell

@property (nonatomic, strong) UIImageView *checkmarkImageView;

@end

@interface LCSwitchFormElementCell : NISwitchFormElementCell<UITextFieldDelegate>

@property (nonatomic, strong) FUISwitch *flatSwitchControl;

@end