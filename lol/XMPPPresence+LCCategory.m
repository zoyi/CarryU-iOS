//
//  XMPPPresence+LCCategory.m
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "XMPPPresence+LCCategory.h"
#import "DDXMLDocument+LCCategory.h"

@implementation XMPPPresence (LCCategory)
- (NSString *)gameStatus {
  NSError *error = nil;
  NSString *gameStatus = [[self presenceBody] firstValueForXPath:@"/body/gameStatus" error:&error];
  if (error) {
    NIDPRINT(@"parsing game status error => %@", error.debugDescription);
  }
  return gameStatus;
}

- (NSString *)skinname {
  NSError *error = nil;
  NSString *skinname = [[self presenceBody] firstValueForXPath:@"/body/skinname" error:&error];
  if (error) {
    NIDPRINT(@"parsing game status error => %@", error.debugDescription);
  }
  return skinname;
}

- (DDXMLDocument *)presenceBody {
  NSString *statusXmlString = [[self elementForName:@"status"] stringValue];
  DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:statusXmlString options:0 error:nil];
  return xmlDoc;
}

@end
