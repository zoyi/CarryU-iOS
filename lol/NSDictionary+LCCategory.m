//
//  NSDictionary+LCCategory.m
//  lol
//
//  Created by Di Wu on 7/11/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "NSDictionary+LCCategory.h"

@implementation NSDictionary (LCCategory)
- (NSArray *)sortedAllKeys {
  return [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return [[obj1 description] compare:[obj2 description]];
  }];
}
@end
