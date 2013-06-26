//
//  LCServerInfo.m
//  lol
//
//  Created by Di Wu on 6/26/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "LCServerInfo.h"
#import <JSONKit/JSONKit.h>
#import "LCAppDelegate.h"

@implementation LCServerInfo

+ (LCServerInfo *)sharedInstance {
  static LCServerInfo *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[LCServerInfo alloc] init];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    // retrive from NSUserDefaults
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    id serverInfo = [standardUserDefaults objectForKey:NSStringFromClass([self class])];
    LCServerInfo *archivedServerInfo = nil;
    if (serverInfo != nil) {
      archivedServerInfo = [NSKeyedUnarchiver unarchiveObjectWithData:serverInfo];
    }
    if (archivedServerInfo != nil) {
      self = archivedServerInfo;
      // update from gist http://lol-gist.wudi.me
      NSURL *url = [NSURL URLWithString:@"http://lol-gist.wudi.me"];
      AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
      [httpClient getPath:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding] stringByReplacingXMLEscape];
        NSDictionary *jsonResult = [responseStr objectFromJSONString];
        if (jsonResult) {
          self.servers = [self parseWithJSON:jsonResult];
        }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NIDPRINT(@"retive server sinfo error = %@", error.debugDescription);
      }];

    } else {
      // load from plist backup
      NSString *serverPlistPath = [[NSBundle mainBundle] pathForResource:@"server_info" ofType:@"plist"];
      serverInfo = [NSDictionary dictionaryWithContentsOfFile:serverPlistPath];
      self.servers = [self parseWithJSON:serverInfo];
    }
  }
  return self;
}

- (void)setServers:(NSDictionary *)servers {
  if (servers != _servers) {
    _servers = servers;
  }
  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
  [standardUserDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:NSStringFromClass([self class])];
  [standardUserDefaults synchronize];
}

- (NSDictionary *)parseWithJSON:(NSDictionary *)json {
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  [json each:^(NSString *key, NSDictionary *obj) {
    LCServer *server = [LCServer new];
    server.railsHost = [NSURL URLWithString:[obj objectForKey:@"rails_host"]];
    server.rtmpHost = [NSURL URLWithString:[obj objectForKey:@"rtmp_host"]];
    server.region = key;
    server.apiUrl = [NSString stringWithFormat:@"%@/api/%@/", server.railsHost, [obj objectForKey:@"api_version"]];
    server.xmppPort = [obj objectForKey:@"xmpp_port"];
    server.xmppHost = [obj objectForKey:@"xmpp_host"];
    [result setObject:server forKey:key];
  }];
  return result;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _servers = [aDecoder decodeObjectForKey:@"servers"];
    _currentServer = [aDecoder decodeObjectForKey:@"current_server"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  if (self.servers) {
    [aCoder encodeObject:self.servers forKey:@"servers"];
  }
  if (self.currentServer) {
    [aCoder encodeObject:self.currentServer forKey:@"current_server"];
  }
}

- (LCServer *)currentServer {
  LCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  return [self.servers objectForKey:appDelegate.regeion];
}

@end

@implementation LCServer

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.railsHost = [aDecoder decodeObjectForKey:@"rails_host"];
    self.rtmpHost = [aDecoder decodeObjectForKey:@"rtmp_host"];
    self.xmppHost = [aDecoder decodeObjectForKey:@"xmpp_host"];
    self.region = [aDecoder decodeObjectForKey:@"region"];
    self.apiUrl = [aDecoder decodeObjectForKey:@"api_url"];
    self.xmppPort = [aDecoder decodeObjectForKey:@"xmpp_port"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  if (self.railsHost) {
    [aCoder encodeObject:self.railsHost forKey:@"rails_host"];
  }
  if (self.rtmpHost) {
    [aCoder encodeObject:self.rtmpHost forKey:@"rtmp_host"];
  }
  if (self.region) {
    [aCoder encodeObject:self.region forKey:@"region"];
  }
  if (self.apiUrl) {
    [aCoder encodeObject:self.apiUrl forKey:@"api_url"];
  }
  if (self.xmppHost) {
    [aCoder encodeObject:self.xmppHost forKey:@"xmpp_host"];
  }
  if (self.xmppPort) {
    [aCoder encodeObject:self.xmppPort forKey:@"xmpp_port"];
  }
}

@end
