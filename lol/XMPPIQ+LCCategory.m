//
//  XMPPIQ+LCCategory.m
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "XMPPIQ+LCCategory.h"
#import "DDXMLDocument+LCCategory.h"
#import "LCSummoner.h"

@implementation XMPPIQ (LCCategory)

- (NSArray *)rawSummonerItems {

  return [[self.childElement elementsForName:@"item"] map:^id(DDXMLElement *ele) {
    return [ele attributeStringValueForName:@"name"];
  }];
}


@end
