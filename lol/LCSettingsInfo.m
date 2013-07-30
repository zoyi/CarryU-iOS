//
//  LCSettingsInfo.m
//  lol
//
//  Created by Di Wu on 6/29/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCSettingsInfo.h"
#import <JSONKit/JSONKit.h>
#import "LCAppDelegate.h"
#import <TestFlightSDK/TestFlight.h>

static NSString *kAppDelegateRegionKey = @"regeion";

@interface LCSettingsInfo ()
- (NSString *)archiveKey;

@end

@implementation LCSettingsInfo

@synthesize searchEngines = _searchEngines;
@synthesize choosedSearchEngine = _choosedSearchEngine;
static LCSettingsInfo *sharedInstance = nil;
static BOOL isUpdated = NO;

+ (LCSettingsInfo *)sharedInstance {

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[LCSettingsInfo alloc] init];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}

- (void)archiveSelf {
  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
  [standardUserDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:[self archiveKey]];
  [standardUserDefaults synchronize];
}

- (NSString *)archiveKey {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  return [NSString stringWithFormat:@"%@_%@", appDelegate.regeion, NSStringFromClass([self class])];
}

- (id)init {
  self = [super init];
  if (self) {
    // retrive from NSUserDefaults
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    id settingsInfo = [standardUserDefaults objectForKey:[self archiveKey]];
    LCSettingsInfo *archivedSettingsInfo = nil;
    if (settingsInfo != nil) {
      archivedSettingsInfo = [NSKeyedUnarchiver unarchiveObjectWithData:settingsInfo];
    }
    if (archivedSettingsInfo != nil) {
      self = archivedSettingsInfo;
      if (!isUpdated) {
        NSURL *url = [NSURL URLWithString:@"http://carryu.co/api/v1/search_engines.json"];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
          self.searchEngines = JSON;
          isUpdated = YES;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
          NIDPRINT(@"retive search engines info error = %@", error.debugDescription);
#ifdef TESTFLIGHT
          TFLog(@"retive search engines info error = %@", error.debugDescription);
#endif
        }];
        [operation start];
      }
      
    } else {
      // load from plist backup
      NSString *settingsPlistPath = [[NSBundle mainBundle] pathForResource:@"search_engines" ofType:@"plist"];
      settingsInfo = [NSDictionary dictionaryWithContentsOfFile:settingsPlistPath];
      self.searchEngines = settingsInfo;
    }
  }
  self.keepScreenOn = self.keepScreenOn;
  return self;
}

- (void)updateRegion {
  sharedInstance = [[LCSettingsInfo alloc] init];
}

- (NSDictionary *)currentRegionSearchEngines {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  return [_searchEngines objectForKey:appDelegate.regeion];
}

- (void)setKeepScreenOn:(BOOL)keepScreenOn {
  _keepScreenOn = keepScreenOn;
  [UIApplication sharedApplication].idleTimerDisabled = _keepScreenOn;
  [self archiveSelf];
}

- (void)setSearchEngines:(NSDictionary *)engines {
  if (_searchEngines != engines) {
    _searchEngines = engines;
    [self archiveSelf];
  }
}

- (void)setChoosedSearchEngine:(NSString *)choosedSearchEngine {
  if (_choosedSearchEngine != choosedSearchEngine) {
    _choosedSearchEngine = choosedSearchEngine;
    [self archiveSelf];
  }
}

- (NSString *)choosedSearchEngine {
  if (!_choosedSearchEngine.length) {
    self.choosedSearchEngine =  @"carryu.co";
  }
  return _choosedSearchEngine;
}

- (NSString *)searchEngine {
  NSString *searchEngine = [[self currentRegionSearchEngines] objectForKey:self.choosedSearchEngine];
  if (!searchEngine.length) {
    LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return [NSString stringWithFormat:@"http://%@.carryu.co/summoners/", appDelegate.regeion];
  }
  return searchEngine;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.keepScreenOn = [aDecoder decodeBoolForKey:@"_keep_screen_on"];
    self.searchEngines = [aDecoder decodeObjectForKey:@"_search_engines"];
    self.choosedSearchEngine = [aDecoder decodeObjectForKey:@"_choosed_search_engine"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeBool:self.keepScreenOn forKey:@"_keep_screen_on"];
  [aCoder encodeObject:self.searchEngines forKey:@"_search_engines"];
  [aCoder encodeObject:self.choosedSearchEngine forKey:@"_choosed_search_engine"];
}

@end
