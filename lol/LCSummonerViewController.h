//
//  LCSummonerViewController.h
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCNetworkTableViewController.h"
#import "LCGame.h"

@class LCSummoner;
@interface LCSummonerViewController : LCNetworkTableViewController
@property (nonatomic, strong) NSArray *summoners;
@property (nonatomic, assign) LCGameMode gameMode;
@property (nonatomic, strong) UIImageView *backgroundView;
- (id)initWithSummoners:(NSArray *)summoners gameMode:(LCGameMode)gameMode;
@end
