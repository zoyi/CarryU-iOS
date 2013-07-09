//
//  LCCurrentSummoner.m
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCCurrentSummoner.h"
#import "LCAppDelegate.h"

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
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  __block NSString *summonerNameKey = [NSString stringWithFormat:@"%@_%@", [appDelegate regeion], sID];
  NSString *archivedSummonerName = [[NSUserDefaults standardUserDefaults] stringForKey:summonerNameKey];
  if (archivedSummonerName) {
    [LCCurrentSummoner sharedInstance].name = archivedSummonerName;
  }
  // retrive summoner name
  [SVProgressHUD showWithStatus:NSLocalizedString(@"retreive_profile_info", nil) maskType:SVProgressHUDMaskTypeBlack];
  NSURL *url = [[RKObjectManager sharedManager].router URLForRouteNamed:@"summoner_name" method:RKRequestMethodGET object:self];

  AFJSONRequestOperation *getSumNameOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    [SVProgressHUD dismiss];
    [LCCurrentSummoner sharedInstance].name = [JSON objectForKey:@"summoner_name"];
    [[NSUserDefaults standardUserDefaults] setObject:[LCCurrentSummoner sharedInstance].name forKey:summonerNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    NIDPRINT(@"Retrive summoner name with error => %@", error.debugDescription);
    [SVProgressHUD dismiss];
  }];
  [getSumNameOperation start];
}
@end
