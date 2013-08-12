//
//  LCSummoner.m
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummoner.h"
#import "LCChampion.h"
#import "LCGame.h"
#import "LCServerInfo.h"

static NSString *SUMMONER_NAME_ROUTE = @"/summoner_name/:sID";
static NSString *SUMMONER_LEVEL_ROUTE = @"summoners/:name\\.json";
@implementation LCSummoner

@synthesize sID = _sID;

+ (RKObjectMapping *)mapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LCSummoner class]];
  [mapping addAttributeMappingsFromDictionary:@{
   @"id" :  @"sID",
   @"account_id" : @"accountID",
   @"profile_icon_id" : @"profileIconID",
   @"name" : @"name",
   @"internal_name" : @"internalName",
   @"level" : @"level",
   @"is_bot" : @"isBot",
   @"spell1" : @"spell1",
   @"spell2" : @"spell2"
   }];

  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ranked_solo_stat" toKeyPath:@"leagueRank" withMapping:[LCRank mapping]]];

  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"unranked_stat" toKeyPath:@"normalRank" withMapping:[LCRank mapping]]];

  [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"champion" toKeyPath:@"champion" withMapping:[LCChampion mapping]]];
  return mapping;
}

+ (void)routing {
  RKObjectManager *manager = [RKObjectManager sharedManager];
  [manager.router.routeSet addRoute:[RKRoute routeWithName:@"summoner_name" pathPattern:SUMMONER_NAME_ROUTE method:RKRequestMethodGET]];
}

+ (void)apiRouting {
  RKRoute *summonerLevelRoute = [RKRoute routeWithName:@"summoner_level" pathPattern:SUMMONER_LEVEL_ROUTE method:RKRequestMethodGET];
  summonerLevelRoute.shouldEscapePath = YES;
  [[LCApiRouter sharedInstance].routeSet addRoute:summonerLevelRoute];
}

- (NSURL *)spell1ImageUrl {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/spells/%@/image", [LCServerInfo sharedInstance].currentServer.railsHost, self.spell1]];
}

- (NSURL *)spell2ImageUrl {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/spells/%@/image", [LCServerInfo sharedInstance].currentServer.railsHost, self.spell2]];
}

- (void)retiveLevel {
  NSURL *url = [[LCApiRouter sharedInstance] URLForRouteNamed:@"summoner_level" method:RKRequestMethodGET object:self];
  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LCSummoner mapping] pathPattern:nil keyPath:@"summoner" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  RKObjectRequestOperation *requestOperation = [[RKObjectRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url] responseDescriptors:@[responseDescriptor]];

  [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    NIDPRINT(@"summoner fetching result -> %@", mappingResult.debugDescription);
    LCSummoner *fetchedSummoner = [mappingResult.dictionary objectForKey:@"summoner"];
    self.leagueRank = fetchedSummoner.leagueRank;
    self.normalRank = fetchedSummoner.normalRank;
    self.level = fetchedSummoner.level;
    self.profileIconID = fetchedSummoner.profileIconID;
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NIDPRINT(@"retrive summoner detail info failed with error %@", error.debugDescription);
  }];

  [requestOperation start];
}

- (NSURL *)profileIconUrl {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/assets/profile_icons/%@.jpg", [LCServerInfo sharedInstance].currentServer.railsHost, self.profileIconID]];
}

@end


@implementation LCRank

+ (RKObjectMapping *)mapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LCRank class]];
  [mapping addAttributeMappingsFromDictionary:@{
    @"rank": @"rank",
    @"tier": @"tier",
    @"wins": @"wins",
    @"losses": @"losses",
    @"rating" : @"rating"
   }];
  return mapping;
}

@end
