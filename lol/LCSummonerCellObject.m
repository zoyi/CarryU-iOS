//
//  LCSummonerCellObject.m
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummonerCellObject.h"

@implementation LCSummonerCellObject
- (id)initWithCellClass:(Class)cellClass summoner:(LCSummoner *)summoner {
  self = [super initWithCellClass:cellClass];
  if (self) {
    self.summoner = summoner;
  }
  return self;
}
@end
