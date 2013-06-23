//
//  LCChampion.h
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCModel.h"

@interface LCChampion : LCModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *cid;
- (NSURL *)championAvatarUrl;
@end
