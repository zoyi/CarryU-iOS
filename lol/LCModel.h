//
//  LCModel.h
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCModel : NSObject
+ (RKObjectMapping *)mapping;
+ (void)routing;
+ (void)apiRouting;
@end
