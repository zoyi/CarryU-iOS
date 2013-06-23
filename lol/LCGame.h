//
//  LCGame.h
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCModel.h"

@interface LCGame : LCModel
@property (nonatomic, strong) NSString *gameType;
@property (nonatomic, strong) NSString *gameMode;
@property (nonatomic, strong) NSString *queue;
@property (nonatomic, strong) NSNumber *gid;
@property (nonatomic, strong) NSArray *playerTeam;
@property (nonatomic, strong) NSArray *enemyTeam;
@property (nonatomic, strong) NSString *playerTeamType;
@property (nonatomic, strong) NSString *enemyTeamType;

@end
