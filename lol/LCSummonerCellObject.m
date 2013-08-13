//
//  LCSummonerCellObject.m
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummonerCellObject.h"
#import "LCSummoner.h"

@implementation LCSummonerCellObject

- (void)dealloc {
  [_summoner removeObserver:self forKeyPath:@"level" context:nil];
}

- (id)initWithCellClass:(Class)cellClass summoner:(LCSummoner *)summoner gameMode:(LCGameMode)gameMode delegate:(id)delegate {
  self = [super initWithCellClass:cellClass];
  if (self) {
    self.gameMode = gameMode;
    self.summoner = summoner;
    self.delegate = delegate;
    [_summoner addObserver:self forKeyPath:@"level" options:NSKeyValueObservingOptionNew context:nil];
    if (_summoner.level == 0) {
        [_summoner retiveLevel];
    }
  }
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (object == _summoner && [keyPath isEqualToString:@"level"]
      && [_delegate respondsToSelector:@selector(reloadData)]) {
    [_delegate performSelector:@selector(reloadData)];
  }
}

@end
