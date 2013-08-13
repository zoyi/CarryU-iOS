//
//  LCGame.m
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCGame.h"
#import "LCSummoner.h"
#import "LCCurrentSummoner.h"

static NSString *SUMMONER_ACTIVE_GAME_ROUTE = @"active_games/:name";
static NSString *SAMPLE_GAME_ROUTE = @"active_game/sample.json";

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
//  RKObjectManager *manager = [RKObjectManager sharedManager];
//  RKRoute *activeGameRoute = [RKRoute routeWithName:@"active_game" pathPattern:SUMMONER_ACTIVE_GAME_ROUTE method:RKRequestMethodGET];
//  activeGameRoute.shouldEscapePath = YES;
//  [manager.router.routeSet addRoute:activeGameRoute];
//
//  RKResponseDescriptor *activeGameDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LCGame mapping] pathPattern:SUMMONER_ACTIVE_GAME_ROUTE keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//  [manager addResponseDescriptor:activeGameDescriptor];

}

+ (void)apiRouting {
  RKRoute *sampleGameRoute = [RKRoute routeWithName:@"sample_game" pathPattern:SAMPLE_GAME_ROUTE method:RKRequestMethodGET];
  [[LCApiRouter sharedInstance].routeSet addRoute:sampleGameRoute];

  RKRoute *activeGameRoute = [RKRoute routeWithRelationshipName:@"active_game" objectClass:[LCCurrentSummoner class] pathPattern:SUMMONER_ACTIVE_GAME_ROUTE method:RKRequestMethodGET];
  activeGameRoute.shouldEscapePath = YES;
  [[LCApiRouter sharedInstance].routeSet addRoute:activeGameRoute];
}

@end
