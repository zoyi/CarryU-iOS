//
//  LCSummonerViewController.m
//  lol
//
//  Created by Di Wu on 6/24/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSummonerViewController.h"
#import "LCSummoner.h"
#import "LCSummonerCell.h"
#import "LCSummonerCellObject.h"

@interface LCSummonerViewController ()
@property (nonatomic, strong) NITableViewModel *model;
@property (nonatomic, strong) NITableViewActions *actions;

@end

@implementation LCSummonerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSummoners:(NSArray *)summoners {
  self = [super initWithStyle:UITableViewStylePlain activityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  if (self) {
    self.summoners = summoners;
 
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.actions = [[NITableViewActions alloc] initWithTarget:self];
  NSMutableArray *tableContents = [NSMutableArray arrayWithCapacity:5];
  [_summoners each:^(LCSummoner *summoner) {
    [tableContents addObject:[[LCSummonerCellObject alloc] initWithCellClass:[LCSummonerCell class] summoner:summoner delegate:self.tableView]];
  }];
  [_actions attachToClass:[LCSummonerCellObject class] tapBlock:^BOOL(LCSummonerCellObject *object, id target) {
    NIDPRINT(@"object is => %@", object.debugDescription);
    NIWebController *webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lolking.net/search?name=%@", object.summoner.name]]];
    [self.navigationController pushViewController:webController animated:YES];
    return YES;
  }];
  self.model = [[NITableViewModel alloc] initWithListArray:tableContents delegate:(id)[NICellFactory class]];
  
  self.tableView.dataSource = self.model;
  self.tableView.delegate = [self.actions forwardingTo:self];
  
  self.tableView.rowHeight = kSummonerCellDefaultHeight;
  self.tableView.backgroundColor = [UIColor cloudsColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
