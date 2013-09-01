//
//  LCModel.m
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCModel.h"

static NSString * const SERVER_STATUS_ROUTE = @"status";

@implementation LCModel

+ (RKObjectMapping *)mapping {
  return nil;
}

+ (void)routing {

}

+ (void)apiRouting {
  [[LCApiRouter sharedInstance].routeSet addRoute:[RKRoute routeWithName:@"status" pathPattern:SERVER_STATUS_ROUTE method:RKRequestMethodGET]];
}

@end
