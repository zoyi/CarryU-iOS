//
//  LCTipWebController.m
//  lol
//
//  Created by Di Wu on 7/10/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCGuidesWebController.h"

@interface LCGuidesWebController ()<UIWebViewDelegate>
- (NSString *)tabBarTitle;
@end

@implementation LCGuidesWebController

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
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSString *)tabBarTitle {
  return NSLocalizedString(@"guides_tab_title", nil);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [super webViewDidFinishLoad:webView];
  self.tabBarItem.title = self.tabBarTitle;
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
  [super webViewDidStartLoad:webView];
  self.tabBarItem.title = self.tabBarTitle;
}

@end
