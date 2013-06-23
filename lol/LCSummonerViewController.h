//
//  LCSummonerViewController.h
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//


@class LCSummoner;
@interface LCSummonerViewController : NINetworkTableViewController
@property (nonatomic, strong) NSArray *summoners;

- (id)initWithSummoners:(NSArray *)summoners;
@end
