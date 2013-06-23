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
  //  RKObjectManager *manager = [RKObjectManager sharedManager];

}

- (NSURL *)spell1ImageUrl {
  return [NSURL URLWithString:[NSString stringWithFormat:@"http://lol.red.zoyi.co/spells/%@/image", self.spell1]];
}

- (NSURL *)spell2ImageUrl {
  return [NSURL URLWithString:[NSString stringWithFormat:@"http://lol.red.zoyi.co/spells/%@/image", self.spell2]];
}

@end
