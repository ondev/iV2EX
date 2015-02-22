//
//  Utils.h
//  v2ex
//
//  Created by Haven on 7/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADRequest.h"

@interface Utils : NSObject
+ (Utils *)sharedInstance;

+ (void)showMessage:(NSString *)msg;
+ (void)loginedNotify;
+ (NSDictionary *)getCookies;
+ (void)updateCookies:(NSArray *)cookies;
+ (void)copy:(id)ori to:(id)des;
+ (BOOL)isBuyer;
+ (BOOL)firstRunAfterInstall;

+ (BOOL)saveUser:(NSString *)userName passwd:(NSString *)passwd;
+ (NSString *)getPasswdOfUser:(NSString *)userName;

+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)stringFromDate:(NSDate *)date;

+ (void)unLike;
+ (GADRequest *)gadRequest;

//FRP
+ (NSValueTransformer *)numberToString;
+ (NSValueTransformer *)avatarUrlCheck;
@end
