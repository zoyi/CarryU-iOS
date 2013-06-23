//
//  LCChampion.m
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCChampion.h"

@implementation LCChampion
+ (RKObjectMapping *)mapping {
  RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LCChampion class]];
  [mapping addAttributeMappingsFromDictionary:@{
   @"name" : @"name",
   @"id" : @"cid"
   }];
  return mapping;
}

- (NSURL *)championAvatarUrl {
  return [NSURL URLWithString:[NSString stringWithFormat:@"http://lol.red.zoyi.co/champions/%@/image", self.cid]];
}
@end
