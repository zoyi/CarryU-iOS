//
//  LCSummonerCell.m
//  lol
//
//  Created by Di Wu on 6/19/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummonerCell.h"
#import "LCSummoner.h"
#import "LCSummonerCellObject.h"
#import "LCChampion.h"

static CGFloat kChampionAvatarDefaultHeight = 50;
static CGFloat kChampionAvatarDefaultWidth = 50;

static CGFloat kSpellImageDefaultWidth = 20;
static CGFloat kSpellImageDefaultHeight = 20;

static CGFloat kMediumPadding = 20;
static CGFloat kSmallPadding = 10;

@implementation LCSummonerCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat left = kSmallPadding;
  CGFloat top = kSmallPadding;
  _championAvatarView.frame = CGRectMake(left, 0, kChampionAvatarDefaultWidth, kChampionAvatarDefaultHeight);
  _championAvatarView.top = (kSummonerCellDefaultHeight - kChampionAvatarDefaultHeight)/2;
  left += _championAvatarView.width + kMediumPadding;

  CGFloat labelMaxWidth = [UIScreen mainScreen].bounds.size.width - left - kSmallPadding*2 - kSpellImageDefaultWidth;
  _summonerNameLabel.frame = CGRectMake(left, top, labelMaxWidth, 0);
  [_summonerNameLabel sizeToFit];
  top += _summonerNameLabel.height + kSmallPadding;

  _descriptionLabel.frame = CGRectMake(left, top, labelMaxWidth, 0);
  [_descriptionLabel sizeToFit];

  {
    CGFloat innerTop = (kSummonerCellDefaultHeight - kSpellImageDefaultHeight*2 - kSmallPadding)/2;
    CGFloat innerLeft = [UIScreen mainScreen].bounds.size.width - kSmallPadding - kSpellImageDefaultWidth;
    _spell1ImageView.frame = CGRectMake(innerLeft, innerTop, kSpellImageDefaultWidth, kSpellImageDefaultHeight);
    innerTop += kSpellImageDefaultHeight + kSmallPadding;
    _spell2ImageView.frame = CGRectMake(innerLeft, innerTop, kSpellImageDefaultWidth, kSpellImageDefaultHeight);
  }
}

- (BOOL)shouldUpdateCellWithObject:(id)object {
  LCSummonerCellObject *cellObject = object;
  LCSummoner *summoner = cellObject.summoner;
  [self.championAvatarView setImageWithURL:[summoner.champion championAvatarUrl]];
  [self.spell1ImageView setImageWithURL:[summoner spell1ImageUrl]];
  [self.spell2ImageView setImageWithURL:[summoner spell2ImageUrl]];
  NSMutableString *summonerNameText = [NSMutableString string];
  [summonerNameText appendString:summoner.name];
  if (summoner.level) {
    [summonerNameText appendFormat:@"(Lv%@)", summoner.level];
  } else {
    [summonerNameText appendString:@"(Lv??)"];
  }
  self.summonerNameLabel.text = summonerNameText;
  self.descriptionLabel.text = summoner.internalName;
  return YES;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.championAvatarView.image = nil;
  self.spell2ImageView.image = nil;
  self.spell1ImageView.image = nil;
  self.summonerNameLabel.text = nil;
  self.descriptionLabel.text = nil;
}

- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  self.championAvatarView.backgroundColor = self.contentView.backgroundColor;
}

#pragma mark - getters

- (NINetworkImageView *)championAvatarView {
  if (nil == _championAvatarView) {
    self.championAvatarView = [[NINetworkImageView alloc] initWithFrame:CGRectZero];
    _championAvatarView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_championAvatarView];
  }
  return _championAvatarView;
}

- (NINetworkImageView *)spell1ImageView {
  if (nil == _spell1ImageView) {
    self.spell1ImageView = [[NINetworkImageView alloc] initWithFrame:CGRectZero];
    _spell1ImageView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_spell1ImageView];
  }
  return _spell1ImageView;
}

- (NINetworkImageView *)spell2ImageView {
  if (nil == _spell2ImageView) {
    self.spell2ImageView = [[NINetworkImageView alloc] initWithFrame:CGRectZero];
    _spell2ImageView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_spell2ImageView];
  }
  return _spell2ImageView;
}

- (NIAttributedLabel *)summonerNameLabel {
  if (nil == _summonerNameLabel) {
    self.summonerNameLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _summonerNameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_summonerNameLabel];
  }
  return _summonerNameLabel;
}

- (NIAttributedLabel *)descriptionLabel {
  if (nil == _descriptionLabel) {
    self.descriptionLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_descriptionLabel];
  }
  return _descriptionLabel;
}


@end
