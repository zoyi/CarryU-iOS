//
//  LCApiRouter.m
//  lol
//
//  Created by Di Wu on 6/25/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCApiRouter.h"
#import "LCServerInfo.h"
@implementation LCApiRouter
+ (LCApiRouter *)sharedInstance {
  static LCApiRouter *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[LCApiRouter alloc] initWithBaseURL:[LCServerInfo sharedInstance].currentServer.apiUrl];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}
@end
