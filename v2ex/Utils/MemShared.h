//
//  MemShareUtil.h
//  v2ex
//
//  Created by Haven on 6/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MemUser.h"


@interface MemShared : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL haveSession;
@property (nonatomic) BOOL fullVersion;
@property (nonatomic, strong) MemUser *user;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSData *tokenData;
@property (nonatomic, strong) NSDictionary *clientConfig;
@property (nonatomic) CLLocationCoordinate2D coord;

- (NSString *)userName;
- (void)logout;
@end
