//
//  NSNumber+RomanNumerals.m
//  lol
//
//  Created by Di Wu on 7/7/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "NSNumber+RomanNumerals.h"

@implementation NSNumber (RomanNumerals)
- (NSString *)romanNumeral {
  NSInteger n = [self integerValue];

  NSArray *numerals = [NSArray arrayWithObjects:@"M", @"CM", @"D", @"CD", @"C", @"XC", @"L", @"XL", @"X", @"IX", @"V", @"IV", @"I", nil];

  NSUInteger valueCount = 13;
  NSUInteger values[] = {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1};

  NSMutableString *numeralString = [NSMutableString string];

  for (NSUInteger i = 0; i < valueCount; i++)
  {
    while (n >= values[i])
    {
      n -= values[i];
      [numeralString appendString:[numerals objectAtIndex:i]];
    }
  }

  return numeralString;

}
@end
