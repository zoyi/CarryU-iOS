//
//  LCServerInfo.h
//  lol
//
//  Created by Di Wu on 6/26/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LCServer;
@interface LCServerInfo : NSObject <NSCoding>

+ (LCServerInfo *)sharedInstance;

@property (nonatomic, strong) NSDictionary *servers;
@property (nonatomic, readonly) LCServer *currentServer;

@end


@interface LCServer : NSObject <NSCoding>
@property (nonatomic, strong) NSURL *railsHost;
@property (nonatomic, strong) NSURL *rtmpHost;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSURL *apiUrl;
@property (nonatomic, strong) NSString *xmppHost;
@property (nonatomic, strong) NSNumber *xmppPort;
@end