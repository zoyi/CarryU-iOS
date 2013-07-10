//
//  LCSummonerShowController.m
//  lol
//
//  Created by Di Wu on 6/28/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummonerShowController.h"
#import "UIBarButtonItem+LCCategory.h"

@interface LCSummonerShowController ()

@end

@implementation LCSummonerShowController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.navigationItem.hidesBackButton = YES;
  self.navigationItem.leftBarButtonItem = [UIBarButtonItem carryuBackBarButtonItem];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
