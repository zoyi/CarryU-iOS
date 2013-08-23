//
//  LCLoginViewController.m
//  lol
//
//  Created by Di Wu on 6/14/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCLoginViewController.h"
#import "LCAppDelegate.h"
#import <ActionSheetPicker2/ActionSheetStringPicker.h>
#import <CoreText/CoreText.h>
#import "LCSigninSelectorViewController.h"
#import "LCHomeNavigationController.h"
#import "LCAppDelegate.h"

static CGFloat kDefaultServerIndicatorWidth = 25;
static CGFloat kDefaultServerIndicatorHeight = 44;
@interface LCLoginViewController () <UITextFieldDelegate, NIPagingScrollViewDataSource, NIPagingScrollViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) NIPagingScrollView *regionPickerView;

- (NSArray *)pickerDataSource;

- (void)setPrevServer;
- (void)setNextServer;

- (void)nextStep;

@end

@implementation LCLoginViewController

- (void)loadView {
  [super loadView];
  [self backgroundView];
  UIImageView *labelView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lol_label.png"]];
  labelView.right = [UIScreen mainScreen].bounds.size.width;
  [self.view addSubview:labelView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[GAI sharedInstance].defaultTracker sendView:@"/LoginScreen"];
}

- (void)viewDidLoad {
  [super viewDidLoad];
   
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.separatorColor = RGBCOLOR(0x72, 0x88, 0x9e);

  self.tableView.scrollEnabled = NO;

  self.tableView.tableHeaderView = [self headerView];
  self.tableView.tableFooterView = [self footerView];

  [self.regionPickerView reloadData];
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSInteger selectedPageIndex = [self.pickerDataSource indexOfObject:appDelegate.regeion];
  [self.regionPickerView setCenterPageIndex:selectedPageIndex];
}

- (UIImageView *)backgroundView {
  if (nil == _backgroundView) {
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    _backgroundView.image = [UIImage imageNamed:@"bg.png"];
    self.tableView.backgroundView = _backgroundView;
  }
  return _backgroundView;
}

- (UIView *)footerView {
  UIView *footerView = [[UIView alloc] init];
  CGFloat top = 0;
  CGFloat left = 10;

//  CGFloat serverTopPadding = 20;
//  if (isiPhone5) {
//    serverTopPadding = 30;
//  }
//  top += serverTopPadding;

  {
    CGFloat innerLeft = left;

    // prev
     
    NINetworkImageView *prevIndicatorView = [[NINetworkImageView alloc] initWithImage:[UIImage imageNamed:@"server_prev.png"]];
    prevIndicatorView.contentMode = (UIViewContentModeLeft);
    prevIndicatorView.size = CGSizeMake(kDefaultServerIndicatorWidth, kDefaultServerIndicatorHeight);
    prevIndicatorView.origin = CGPointMake(innerLeft, top);

    prevIndicatorView.userInteractionEnabled = YES;
    UITapGestureRecognizer *prevTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setPrevServer)];
    prevTapGesture.numberOfTapsRequired = 1;
    prevTapGesture.numberOfTouchesRequired = 1;
    [prevIndicatorView addGestureRecognizer:prevTapGesture];
    
    [footerView addSubview:prevIndicatorView];

    // next
    NINetworkImageView *nextIndicatorView = [[NINetworkImageView alloc] initWithImage:[UIImage imageNamed:@"server_next.png"]];

    nextIndicatorView.contentMode = (UIViewContentModeRight);
    nextIndicatorView.size = prevIndicatorView.size;
    nextIndicatorView.top = prevIndicatorView.top;
    nextIndicatorView.right = [UIScreen mainScreen].bounds.size.width - innerLeft;
    
    nextIndicatorView.userInteractionEnabled = YES;
    UITapGestureRecognizer *nextTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextServer)];
    nextTapGesture.numberOfTapsRequired = 1;
    nextTapGesture.numberOfTouchesRequired = 1;
    [nextIndicatorView addGestureRecognizer:nextTapGesture];

    [footerView addSubview:nextIndicatorView];

    self.regionPickerView.frame = CGRectMake(prevIndicatorView.right, top, nextIndicatorView.left - prevIndicatorView.right, 44);
    [footerView addSubview:_regionPickerView];
    top += _regionPickerView.height + 80;
  }

  FUIButton *nextButton = [FUIButton lcButtonWithTitle:NSLocalizedString(@"next_btn_label", nil)];
  nextButton.frame = CGRectMake(left, top, [UIScreen mainScreen].bounds.size.width - 2*left, 44);
  [nextButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
  [footerView addSubview:nextButton];

  top += nextButton.height;

  footerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, top);
  return footerView;
}

- (void)nextStep {
  LCSigninSelectorViewController *signinSelectorViewController = [[LCSigninSelectorViewController alloc] initWithStyle:UITableViewStylePlain];
  LCHomeNavigationController *navigationController = [[LCHomeNavigationController alloc] initWithRootViewController:signinSelectorViewController];

#ifdef IAD
  UIViewController *rootViewController = [[LCADHomeViewController alloc] initWithContentViewController:navigationController];
#else
  UIViewController *rootViewController = navigationController;
#endif
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  appDelegate.window.rootViewController = rootViewController;
  [appDelegate.window makeKeyAndVisible];
}

- (NIPagingScrollView *)regionPickerView {
  if (nil == _regionPickerView) {
    self.regionPickerView = [[NIPagingScrollView alloc] initWithFrame:CGRectZero];
    _regionPickerView.dataSource = self;
    _regionPickerView.delegate = self;
  }
  return _regionPickerView;
}

- (UIView *)headerView {
  UIView *headerView = [[UIView alloc] init];
  CGFloat top = self.view.height / 10;


  UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
  [logoView sizeToFit];
  logoView.left = floorf(([UIScreen mainScreen].bounds.size.width - logoView.width)/2);
  logoView.top = top;
 
  [headerView addSubview:logoView];
  top = logoView.bottom;
  if (!isiPhone5) {
    top -= 20;
  }
  headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, top);
  return headerView;
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - picker methods

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView {
  NSInteger index = pagingScrollView.centerPageIndex;
  NSString *selectedValue = [self.pickerDataSource objectAtIndex:index];
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  appDelegate.regeion = [selectedValue lowercaseString];
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
  LCRegionPageView *pageView = [[LCRegionPageView alloc] initWithFrame:pagingScrollView.bounds];
  pageView.label.text = [NSString stringWithFormat:NSLocalizedString(@"server_picker_format", nil), NSLocalizedString([self.pickerDataSource objectAtIndex:pageIndex], nil)];
  return pageView;
}

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
  return self.pickerDataSource.count;
}

- (NSArray *)pickerDataSource {
  return @[@"kr", @"na", @"euw"];
}
//////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  // Customize the presentation of certain types of cells.
  if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
    NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
    [self textFieldDidEndEditing:textInputCell.textField];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return [self tableView:tableView viewForHeaderInSection:section].height;
}

- (void)hideKeyboard {
  [UIView animateWithDuration:0.25 animations:^{
    self.view.top = NIStatusBarHeight();
  }];
}

- (void)setPrevServer {
  if ([_regionPickerView hasPrevious]) {
    [_regionPickerView moveToPreviousAnimated:YES];
  } else {
    [_regionPickerView moveToPageAtIndex:_regionPickerView.numberOfPages -1 animated:YES];
  }
}

- (void)setNextServer {
  if ([_regionPickerView hasNext]) {
    [_regionPickerView moveToNextAnimated:YES];
  } else {
    [_regionPickerView moveToPageAtIndex:0 animated:YES];
  }
}

@end

@implementation LCRegionPageView
@synthesize pageIndex = _pageIndex;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.label.frame = self.bounds;
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (_label.text) {
    [_label sizeToFit];
    _label.width = self.width;
    _label.centerY = self.centerY;
  }
}

- (NIAttributedLabel *)label {
  if (nil == _label) {
    self.label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    _label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _label.font = [UIFont systemFontOfSize:24];
    _label.adjustsFontSizeToFitWidth =YES;
    _label.numberOfLines = 1;
    _label.textAlignment = NSTextAlignmentCenter;

    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor carryuColor];

    [self addSubview:_label];
  }
  return _label;
}

- (void)setPageIndex:(NSInteger)pageIndex {
  _pageIndex = pageIndex;
  
  [self setNeedsLayout];
}

- (void)prepareForReuse {
  self.label.text = nil;
}

@end

