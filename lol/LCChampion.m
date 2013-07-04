//
//  LCChampion.m
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCChampion.h"
#import "LCServerInfo.h"
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
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/champions/%@/image", [LCServerInfo sharedInstance].currentServer.railsHost.absoluteString, self.cid]];
}
@end
