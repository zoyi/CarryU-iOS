//
//  LCLoginViewController.h
//  lol
//
//  Created by Di Wu on 6/14/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCLoginViewController : UITableViewController

@end


@interface LCRegionPageView : UIView <NIPagingScrollViewPage>
@property (nonatomic, strong) NIAttributedLabel *label;
@end