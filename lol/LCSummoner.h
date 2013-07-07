//
//  LCSummoner.h
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCModel.h"

@class LCChampion, LCRank;

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
@property (nonatomic, strong) LCRank *leagueRank;
@property (nonatomic, strong) LCRank *normalRank;

- (NSURL *)spell1ImageUrl;
- (NSURL *)spell2ImageUrl;
- (NSURL *)profileIconUrl;

- (void)retiveLevel;
@end

@interface LCRank : LCModel

@property (nonatomic, strong) NSNumber *rank;
@property (nonatomic, strong) NSString *tier;
@property (nonatomic, strong) NSNumber *wins;
@property (nonatomic, strong) NSNumber *losses;

@end
