//
//  LCSigninSelectorViewController.h
//  lol
//
//  Created by Di Wu on 8/21/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCSigninSelectorViewController : UITableViewController
- (id)initWithStyle:(UITableViewStyle)style;
@end


@interface LCLoginBox : UIView
@property (nonatomic, strong) NIAttributedLabel *titleLabel;
@property (nonatomic, strong) FUIButton *button;
@end