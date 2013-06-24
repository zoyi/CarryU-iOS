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
   @"is_bot" : @"isBot",
   @"spell1" : @"spell1",
   @"spell2" : @"spell2"
   }];
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
  return [NSURL URLWithString:[NSString stringWithFormat:@"http://lol.red.zoyi.co/spells/%@/image", self.spell1]];
}

- (NSURL *)spell2ImageUrl {
  return [NSURL URLWithString:[NSString stringWithFormat:@"http://lol.red.zoyi.co/spells/%@/image", self.spell2]];
}

- (void)retiveLevel {
  NSURL *url = [[LCApiRouter sharedInstance] URLForRouteNamed:@"summoner_level" method:RKRequestMethodGET object:self];

  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    self.level = [[JSON objectForKey:@"summoner"] objectForKey:@"level"];
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    NIDPRINT(@"Encountered error when retrieve summoner level %@", error.debugDescription);
  }];
  [operation start];
}

@end
