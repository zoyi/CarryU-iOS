//
//  LCGameTabBarController.h
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LCGame;
@interface LCGameTabBarController : UITabBarController
@property (nonatomic, strong) LCGame *game;
- (id)initWithGame:(LCGame *)game;
@end

@interface LCSampleGameTabBarController : LCGameTabBarController

@end