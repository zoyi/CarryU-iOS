//
//  LCSummonerCellObject.h
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "NICellFactory.h"
@class LCSummoner;
@interface LCSummonerCellObject : NICellObject
@property (nonatomic, strong) LCSummoner *summoner;

- (id)initWithCellClass:(Class)cellClass summoner:(LCSummoner *)summoner;
@end
