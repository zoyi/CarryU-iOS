//
//  LCCurrentSummoner.m
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCCurrentSummoner.h"

@implementation LCCurrentSummoner
@synthesize sID = _sID;
+ (LCCurrentSummoner *)sharedInstance {
  static LCCurrentSummoner *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[LCCurrentSummoner alloc] init];
  });
  return sharedInstance;
}

- (void)setSID:(NSNumber *)sID {
  if (_sID != sID) {
    _sID = sID;
  }
  // retrive summoner name
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/summoner_name/%@", [RKObjectManager sharedManager].router.baseURL.absoluteString, _sID]];
  AFJSONRequestOperation *getSumNameOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    [LCCurrentSummoner sharedInstance].name = [[JSON objectForKey:@"summoner_name"] stringByAddingPercentEscapesForURLParameter];
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    NIDPRINT(@"Retrive summoner name with error => %@", error.debugDescription);
  }];
  [getSumNameOperation start];
}
@end
