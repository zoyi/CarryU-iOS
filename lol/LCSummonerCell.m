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
#import "NSNumber+RomanNumerals.h"

static CGFloat kChampionAvatarDefaultHeight = 60;
static CGFloat kChampionAvatarDefaultWidth = 60;

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
  CGFloat top = kSmallPadding + 2;
  _championAvatarView.frame = CGRectMake(left, top, kChampionAvatarDefaultWidth, kChampionAvatarDefaultHeight);
  left += _championAvatarView.width + kMediumPadding;

  self.actionView.right = [UIScreen mainScreen].bounds.size.width - kSmallPadding;
  self.actionView.centerY = kSummonerCellDefaultHeight/2;

  CGFloat labelMaxWidth = _actionView.left - left - kSmallPadding*2;
  _summonerNameLabel.frame = CGRectMake(left, top, labelMaxWidth, 0);
  [_summonerNameLabel sizeToFit];
  top += _summonerNameLabel.height + 5;

  if (_rankLevelLabel.text.length) {
    _rankLevelLabel.frame = CGRectMake(left, top, labelMaxWidth - kSpellImageDefaultWidth*2 - kSmallPadding, 0);
    [_rankLevelLabel sizeToFit];
    top += _rankLevelLabel.height + 5;
  }

  _descriptionLabel.frame = CGRectMake(left, top, labelMaxWidth, 0);
  [_descriptionLabel sizeToFit];

  {
    CGFloat innerLeft = _actionView.left - kSmallPadding - kSpellImageDefaultWidth*2 - 5;
    _spell1ImageView.frame = CGRectMake(innerLeft, 0, kSpellImageDefaultWidth, kSpellImageDefaultHeight);
    _spell1ImageView.centerY = _actionView.centerY;
    innerLeft += _spell1ImageView.width + 5;
    _spell2ImageView.frame = CGRectMake(innerLeft, 0, kSpellImageDefaultWidth, kSpellImageDefaultHeight);
    _spell2ImageView.centerY = _actionView.centerY;
  }
}

- (BOOL)shouldUpdateCellWithObject:(id)object {
  LCSummonerCellObject *cellObject = object;
  LCSummoner *summoner = cellObject.summoner;
  if (summoner.champion.cid) {
    [self.championAvatarView setImageWithURL:[summoner.champion championAvatarUrl]];
  } else if (summoner.profileIconID) {
    [self.championAvatarView setImageWithURL:[summoner profileIconUrl]];
  }

  [self.spell1ImageView setImageWithURL:[summoner spell1ImageUrl]];
  [self.spell2ImageView setImageWithURL:[summoner spell2ImageUrl]];

  NSMutableString *rankLevelText = [NSMutableString string];
  if (summoner.leagueRank) {
    [rankLevelText appendFormat:@"%@ %@ / ", summoner.leagueRank.tier.capitalizedString, [summoner.leagueRank.rank romanNumeral]];
  }
  if (summoner.level) {
    [rankLevelText appendFormat:@"Lv %@", summoner.level];
  }

  NSMutableString *descriptionText = [NSMutableString string];
  if (summoner.normalRank) {
    [descriptionText appendFormat:NSLocalizedString(@"normal_wins", nil), summoner.normalRank.wins];
  }
  if (summoner.leagueRank) {
    [descriptionText appendFormat:NSLocalizedString(@"rank_wins", nil), summoner.leagueRank.wins];
  }

  if (!descriptionText.length
      && !summoner.level) {
    [descriptionText appendString:NSLocalizedString(@"loading", nil)];
  }

  self.rankLevelLabel.text = rankLevelText;
  if (summoner.leagueRank.tier.length) {
    [_rankLevelLabel insertImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@.png", summoner.leagueRank.tier.lowercaseString, summoner.leagueRank.rank]]
                         atIndex:0
                         margins:UIEdgeInsetsMake(0, 0, 0, 3)
           verticalTextAlignment:NIVerticalTextAlignmentMiddle];
  }

  self.summonerNameLabel.text = summoner.name;

  self.descriptionLabel.text = descriptionText;
  return YES;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.championAvatarView.image = nil;
  self.spell2ImageView.image = nil;
  self.spell1ImageView.image = nil;
  self.summonerNameLabel.text = nil;
  self.rankLevelLabel.text = nil;
  self.descriptionLabel.text = nil;
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

- (UIImageView *)actionView {
  if (nil == _actionView) {
    self.actionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next.png"]];
    [self.contentView addSubview:_actionView];
  }
  return _actionView;
}

- (NIAttributedLabel *)summonerNameLabel {
  if (nil == _summonerNameLabel) {
    self.summonerNameLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _summonerNameLabel.backgroundColor = [UIColor clearColor];
    _summonerNameLabel.textColor = [UIColor whiteColor];
    _summonerNameLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:_summonerNameLabel];
  }
  return _summonerNameLabel;
}

- (NIAttributedLabel *)rankLevelLabel {
  if (nil == _rankLevelLabel) {
    self.rankLevelLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _rankLevelLabel.backgroundColor = [UIColor clearColor];
    _rankLevelLabel.textColor = [UIColor whiteColor];
    _rankLevelLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_rankLevelLabel];
  }
  return _rankLevelLabel;
}

- (NIAttributedLabel *)descriptionLabel {
  if (nil == _descriptionLabel) {
    self.descriptionLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.font = [UIFont systemFontOfSize:13];
    _descriptionLabel.textColor = [UIColor carryuColor];
    [self.contentView addSubview:_descriptionLabel];
  }
  return _descriptionLabel;
}


@end
