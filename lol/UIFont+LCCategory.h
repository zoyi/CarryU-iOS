//
//  UIFont+LCCategory.h
//  lol
//
//  Created by Di Wu on 7/4/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (LCCategory)
+ (UIFont *)optimaFontWithSize:(CGFloat)size;
+ (UIFont *)boldOptimaFontWithSize:(CGFloat)size;

+ (UIFont *)defaultFont;
+ (UIFont *)smallFont;
+ (UIFont *)largeFont;
@end
