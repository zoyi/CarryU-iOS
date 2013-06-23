//
//  LCSummonerCell.h
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "NICellCatalog.h"

static CGFloat kSummonerCellDefaultHeight = 78;

@interface LCSummonerCell : NITextCell
@property (nonatomic, strong) NINetworkImageView *championAvatarView;
@property (nonatomic, strong) NINetworkImageView *spell1ImageView;
@property (nonatomic, strong) NINetworkImageView *spell2ImageView;
@property (nonatomic, strong) NIAttributedLabel *summonerNameLabel;
@property (nonatomic, strong) NIAttributedLabel *descriptionLabel;

@end
