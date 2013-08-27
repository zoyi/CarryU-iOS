//
//  LCManualGameViewController.m
//  lol
//
//  Created by Di Wu on 8/26/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCManualGameViewController.h"
#import "LCOutOfGameView.h"
#import "LCCurrentSummoner.h"
#import "UIViewController+LCCategory.h"

@interface LCManualGameViewController ()
@property (nonatomic, strong) LCOutOfGameView *outOfGameView;
@end

@implementation LCManualGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
  CGRect viewBounds = self.view.bounds;
  viewBounds.size.height -= 44;
  self.outOfGameView.frame = viewBounds;
  self.title = [LCCurrentSummoner sharedInstance].name;
  self.tableView.tableFooterView = self.outOfGameView;
  self.tableView.separatorColor = [UIColor tableViewSeperatorColor];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (LCOutOfGameView *)outOfGameView {
  if (nil == _outOfGameView) {
    self.outOfGameView  = [[LCOutOfGameView alloc] initWithFrame:CGRectZero];
    _outOfGameView.titleLabel.text = NSLocalizedString(@"manual_game_desc", nil);
    [_outOfGameView.previewButton addTarget:self action:@selector(showSampleGame) forControlEvents:UIControlEventTouchUpInside];
  }
  return _outOfGameView;
}

@end
