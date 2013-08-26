//
//  UIViewController+LCCategory.m
//  lol
//
//  Created by Di Wu on 8/26/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "UIViewController+LCCategory.h"
#import "LCGame.h"
#import "LCGameTabBarController.h"

@implementation UIViewController (LCCategory)
- (void)showSampleGame {
  RKRoute *sampleRoute = [[LCApiRouter sharedInstance].routeSet routeForName:@"sample_game"];

  RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LCGame mapping] pathPattern:sampleRoute.pathPattern keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  responseDescriptor.baseURL = [LCApiRouter sharedInstance].baseURL;

  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[[LCApiRouter sharedInstance] URLWithRoute:sampleRoute object:nil]];

  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:urlRequest responseDescriptors:@[responseDescriptor]];
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

    LCGame *game = [mappingResult.dictionary objectForKey:[NSNull null]];
    if (game) {
      LCSampleGameTabBarController *sampleGameTabController = [[LCSampleGameTabBarController alloc] initWithGame:game];
      [self.navigationController pushViewController:sampleGameTabController animated:YES];
    } else {
      // show error message
      [SIAlertView carryuWarningAlertWithMessage:NSLocalizedString(@"retrieve_sample_game_error", nil)];
    }
    [SVProgressHUD dismiss];
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    [SVProgressHUD dismiss];
    NIDPRINT(@"retrieve sample game with error %@", error.debugDescription);
  }];
  [SVProgressHUD showWithStatus:NSLocalizedString(@"retrieve_sample_game", nil) maskType:SVProgressHUDMaskTypeBlack];
  [operation start];
}
@end
