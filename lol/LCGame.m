//
//  LCGame.m
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCGame.h"
#import "LCSummoner.h"

static NSString *SUMMONER_ACTIVE_GAME_ROUTE = @"active_game/:name";

@implementation LCGame

+ (RKObjectMapping *)mapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LCGame class]];
  [mapping addAttributeMappingsFromDictionary:@{
   @"id" : @"gid",
   @"game_type" : @"gameType",
   @"game_mode" : @"gameMode",
   @"queue" : @"queue",
   @"player_team_type" : @"playerTeamType",
   @"enemy_team_type" : @"enemyTeamType"
   }];
  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"player_team" toKeyPath:@"playerTeam" withMapping:[LCSummoner mapping]]];
  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"enemy_team" toKeyPath:@"enemyTeam" withMapping:[LCSummoner mapping]]];

  return mapping;
}

+ (void)routing {
  RKObjectManager *manager = [RKObjectManager sharedManager];
  [manager.router.routeSet addRoute:[RKRoute routeWithName:@"active_game" pathPattern:SUMMONER_ACTIVE_GAME_ROUTE method:RKRequestMethodGET]];

  RKResponseDescriptor *activeGameDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LCGame mapping] pathPattern:SUMMONER_ACTIVE_GAME_ROUTE keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  [manager addResponseDescriptor:activeGameDescriptor];

}

@end
