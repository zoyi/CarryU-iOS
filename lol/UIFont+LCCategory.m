//
//  UIFont+LCCategory.m
//  lol
//
//  Created by Di Wu on 7/4/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "UIFont+LCCategory.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIFont (LCCategory)

+ (void)load {
  if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
    method_exchangeImplementations(class_getClassMethod(self, @selector(systemFontOfSize:)),
                                   class_getClassMethod(self, @selector(optimaFontWithSize:)));
    method_exchangeImplementations(class_getClassMethod(self, @selector(boldSystemFontOfSize:)),
                                   class_getClassMethod(self, @selector(boldOptimaFontWithSize:)));
  }
}

+ (UIFont *)optimaFontWithSize:(CGFloat)size {
  return [UIFont fontWithName:@"Optima-Bold" size:size];
}

+ (UIFont *)boldOptimaFontWithSize:(CGFloat)size {
  return [UIFont fontWithName:@"Optima-ExtraBlack" size:size];
}

+ (UIFont *)defaultFont {
  return [UIFont systemFontOfSize:15];
}

+ (UIFont *)smallFont {
  return [UIFont systemFontOfSize:13];
}

+ (UIFont *)largeFont {
  return [UIFont systemFontOfSize:17];
}
@end
