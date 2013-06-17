//
//  NSString+LCCategory.m
//  lol
//
//  Created by Di Wu on 6/14/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "NSString+LCCategory.h"

@implementation NSString (LCCategory)

- (NSString *)stringByReplacingXMLEscape {
  return [[[[[self stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"]
             stringByReplacingOccurrencesOfString: @"&quot;" withString:@"\\"]
            stringByReplacingOccurrencesOfString: @"&#x39;" withString: @"'"]
           stringByReplacingOccurrencesOfString: @"&gt;" withString: @">"]
          stringByReplacingOccurrencesOfString: @"&lt;" withString: @"<"];
}
@end
