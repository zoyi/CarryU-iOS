//
//  LCSigninFormViewController.h
//  lol
//
//  Created by Di Wu on 8/23/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCSigninFormViewController : UITableViewController
- (NSArray *)tableContents;
- (void)buttonAction;
- (NSString *)buttonTitle;

- (NSString *)additionalNote;
@end

@interface LCSigninRiotFormViewController : LCSigninFormViewController

@end

@interface LCSigninSummonerNameFormViewController : LCSigninFormViewController

@end

@interface LCTextInputFormElementCell : NITextInputFormElementCell

@end