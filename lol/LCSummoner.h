//
//  LCSummoner.h
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCModel.h"

@class LCChampion;

@interface LCSummoner : LCModel

@property (nonatomic, strong) NSNumber *sID;
@property (nonatomic, strong) NSNumber *accountID;
@property (nonatomic, strong) NSNumber *profileIconID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *isBot;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *spell1;
@property (nonatomic, strong) NSNumber *spell2;
@property (nonatomic, strong) LCChampion *champion;

- (NSURL *)spell1ImageUrl;
- (NSURL *)spell2ImageUrl;
- (void)retiveLevel;
@end
