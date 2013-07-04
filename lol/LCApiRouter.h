//
//  LCApiRouter.h
//  lol
//
//  Created by Di Wu on 6/25/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "RKRouter.h"

@interface LCApiRouter : RKRouter
+ (LCApiRouter *)sharedInstance;
+ (void)setSharedInstance:(id)instance;
@end
