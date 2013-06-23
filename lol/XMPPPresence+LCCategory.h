//
//  XMPPPresence+LCCategory.h
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//
#import "XMPPPresence.h"

@class DDXMLDocument;
@interface XMPPPresence (LCCategory)
- (NSString *)gameStatus;
- (NSString *)skinname;
- (DDXMLDocument *)presenceBody;
@end
