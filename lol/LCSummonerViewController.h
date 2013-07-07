//
//  LCSummonerViewController.h
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCNetworkTableViewController.h"
@class LCSummoner;
@interface LCSummonerViewController : LCNetworkTableViewController
@property (nonatomic, strong) NSArray *summoners;
@property (nonatomic, strong) UIImageView *backgroundView;
- (id)initWithSummoners:(NSArray *)summoners;
@end
