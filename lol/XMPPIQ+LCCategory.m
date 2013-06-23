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
  NSError *error = nil;
  NSArray *rawSummoners = [[self iqDocument] nodesForXPath:@"//item" error:&error];
  if (error) {
    NIDPRINT(@"parsing raw summoner error = %@", error.debugDescription);
    return nil;
  }

  return [rawSummoners mappedArrayUsingBlock:^id(DDXMLNode *node, NSUInteger idx) {
    LCSummoner *summoner = [LCSummoner new];
    summoner.name = node.name;
    return summoner;
  }];
}

- (DDXMLDocument *)iqDocument {
  NSError *error = nil;
  DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:[self stringValue] options:0 error:&error];
  if (error) {
    NIDPRINT(@"parsing iq to document with error %@", error.debugDescription);
    return nil;
  }
  return xmlDoc;
}

@end
