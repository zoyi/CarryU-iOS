//
//  NSString+LCCategory.h
//  lol
//
//  Created by Di Wu on 6/14/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LCCategory)
- (NSString *)stringByReplacingXMLEscape;
- (NSNumber *)toNumber;
@end
