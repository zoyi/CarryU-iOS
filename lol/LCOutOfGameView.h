//
//  LCOutOfGameView.h
//  lol
//
//  Created by Di Wu on 7/5/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCOutOfGameView : UIView
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NIAttributedLabel *titleLabel;
@property (nonatomic, strong) NIAttributedLabel *pullReloadDescLabel;
@property (nonatomic, strong) NIAttributedLabel *sampleGameDescLabel;
@property (nonatomic, strong) FUIButton *tutorialVideoButton;
@property (nonatomic, strong) FUIButton *previewButton;
@end
