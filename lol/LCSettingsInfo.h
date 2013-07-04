//
//  LCSettingsInfo.h
//  lol
//
//  Created by Di Wu on 6/29/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCSettingsInfo : NSObject <NSCoding>

+ (LCSettingsInfo *)sharedInstance;

@property (nonatomic, assign) BOOL keepScreenOn;
@property (nonatomic, strong) NSDictionary *searchEngines;
@property (nonatomic, strong) NSString *choosedSearchEngine;

- (NSString *)searchEngine;
- (void)updateRegion;
@end
