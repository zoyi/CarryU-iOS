//
//  LCHomeNavigationController.h
//  lol
//
//  Created by Di Wu on 6/25/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface LCHomeNavigationController : UINavigationController

@end


@interface LCADHomeViewController : UIViewController <ADBannerViewDelegate>
@property (nonatomic, readonly) UIViewController *contentController;
- (instancetype)initWithContentViewController:(UIViewController *)contentController;
@end