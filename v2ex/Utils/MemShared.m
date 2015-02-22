//
//  MemShareUtil.m
//  v2ex
//
//  Created by Haven on 6/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "MemShared.h"
#import "DBUtil.h"
#import <objc/runtime.h>
#import "DBUser.h"


@implementation MemShared

+ (instancetype)sharedInstance {
    static MemShared *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MemShared alloc] init];
    });
    
    return _instance;
}

#pragma mark - Archive
- (void)encodeWithCoder:(NSCoder *)aCoder {
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}


#pragma mark - Logic
- (BOOL)isLogin {
    if (_isLogin) {
        return _isLogin;
    }
    return [self checkLogin];
}

- (BOOL)checkLogin {
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieJar setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSArray *cookies = [cookieJar cookies];
    for (NSHTTPCookie*cookie in cookies) {
        if([[cookie domain] rangeOfString:@"v2ex"].location != NSNotFound)
        {
            NSString *name = cookie.name;
            if ([name isEqualToString:@"A2"] || [name isEqualToString:@"auth"]) {
                NSString *userName = [[MemShared sharedInstance] userName];
                if (userName) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (BOOL)haveSession {
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieJar cookies];
    for (NSHTTPCookie*cookie in cookies) {
        if([[cookie domain] rangeOfString:@"v2ex"].location != NSNotFound)
        {
            NSString *name = cookie.name;
            if ([name isEqualToString:@"A2"] || [name isEqualToString:@"auth"] || [name isEqualToString:@"PB3_SESSION"]) {
                return YES;
            }
        }
    }
    
    return NO;
}


//- (void)setUser{
//    if (_user) {
//        //update
//        u_int count;
//        objc_property_t *properties = class_copyPropertyList([MemberObject class], &count);
//        
//        for (int i = 0; i < count ; i++)
//        {
//            NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
//            
//            SEL selector = NSSelectorFromString(propertyNameString);
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            id value = [user performSelector:selector];
//#pragma clang diagnostic pop
//            
//            if (value == nil)
//            {
//                value = [NSNull null];
//            }
//            else {
//                [_user setValue:value forKey:propertyNameString];
//            }
//        }
//    }
//    else {
//        _user = user;
//    }
//}


#pragma mark - Interface



//- (NSString *)generateLocalDefaultData {
//    NSDate *date = [NSDate date];
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
//    NSString* created = [fmt stringFromDate:date];
//    NSArray *us = [DBUser where:[NSString stringWithFormat:@"userId == '%@'", LocalUserId]];
//    DBUser *u = nil;
//    if (us.count) {
//        u = us[0];
//    }
//    else {
//        u = [DBUser create];
//    }
//    u.userId = LocalUserId;
//    u.created = created;
//    [u save];
//    
//    return LocalUserId;
//}

- (NSString *)userName {
    NSString *userName = [MemUtil userName];
    userName = userName ? userName : @"UnLoginUser";
    return userName;
}

- (void)logout {
    
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieJar cookies];
    for (NSHTTPCookie*cookie in cookies) {
        if([[cookie domain] rangeOfString:@"v2ex"].location != NSNotFound)
        {
            [cookieJar deleteCookie:cookie];
        }
    }
}
@end
