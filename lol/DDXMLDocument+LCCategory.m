//
//  DDXMLDocument+LCCategory.m
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "DDXMLDocument+LCCategory.h"

@implementation DDXMLDocument (LCCategory)

- (id)firstValueForXPath:(NSString *)xpath error:(NSError **)error {
  NSArray *nodes = [self nodesForXPath:xpath error:error];
  if (nodes.count > 0) {
    return [[nodes objectAtIndex:0] stringValue];
  }
  return nil;
}

@end
