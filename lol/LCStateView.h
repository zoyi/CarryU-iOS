//
//  LCStateView.h
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCStateView : UIView

@property (nonatomic, strong) UIImage*  image;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* subtitle;
@property (nonatomic, strong)   UIButton* reloadButton;
/**
 * creates an error view
 */
- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image;

/**
 * adds a reload button into the error view
 */
- (void)addReloadButton;

@end
