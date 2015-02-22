//
//  Utils.m
//  v2ex
//
//  Created by Haven on 7/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "Utils.h"
#import "MemShared.h"
#import "UIAlertView+Blocks.h"
#import <ObjC/runtime.h>
#import "DBUser.h"
#import "UICKeyChainStore.h"

@implementation Utils
+ (Utils *)sharedInstance {
    static Utils *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Utils alloc] init];
    });
    
    return _instance;
}

+ (void)showMessage:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

+ (void)loginedNotify {
    if (![MemShared sharedInstance].isLogin) {
        [UIAlertView showWithTitle:nil message:@"需要登陆" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 0:
                    
                    break;
                case 1:
                    break;
                default:
                    break;
            }
        }];
    }
}

+ (NSDictionary *)getCookies {
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieJar cookies];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    return headers;
}

+ (void)updateCookies:(NSArray *)cookies {
    
}

+ (void)copy:(id)ori to:(id)des {
    assert(ori);
    assert(des);
    
    u_int count;
    objc_property_t *properties = class_copyPropertyList([ori class], &count);
    
    for (int i = 0; i < count ; i++)
    {
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        
        SEL selector = NSSelectorFromString(propertyNameString);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [ori performSelector:selector];
#pragma clang diagnostic pop
        
        if (value == nil)
        {
            value = [NSNull null];
        }
        else {
            [des setValue:value forKey:propertyNameString];
        }
    }
}


+ (BOOL)isBuyer {
//    [UICKeyChainStore setString:@"0" forKey:FullVersionKey];
//    return YES;
    return [[UICKeyChainStore stringForKey:FullVersionKey] isEqualToString:@"1"];
}

+ (BOOL)firstRunAfterInstall {
    NSString *uuid = [UICKeyChainStore stringForKey:@"UUID"];
    
    return uuid ? NO : YES;
}

+ (BOOL)saveUser:(NSString *)userName passwd:(NSString *)passwd {
    assert(userName);
    assert(passwd);
    
    return [UICKeyChainStore setString:passwd forKey:userName];
}

+ (NSString *)getPasswdOfUser:(NSString *)userName {
    assert(userName);
    
    return [UICKeyChainStore stringForKey:userName];
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss z"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}

+ (NSString *)stringFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    
    return destDateString;
}

+ (void)unLike {
    [NetHelper setNetworkActivityIndicatorVisible:YES];
    double delayInSeconds = 2;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [NetHelper setNetworkActivityIndicatorVisible:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"举报成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });
}

+ (GADRequest *)gadRequest {
    GADRequest *request = [GADRequest request];
    //    request.testDevices = @[ GAD_SIMULATOR_ID ];
    
    if (CLLocationCoordinate2DIsValid([MemShared sharedInstance].coord)) {
        [request setLocationWithLatitude:[MemShared sharedInstance].coord.latitude longitude:[MemShared sharedInstance].coord.longitude accuracy:1000.0f];
    }
    else {
        [request setLocationWithLatitude:1.393066 longitude:103.895645 accuracy:1000.0f];
    }
    
    return request;
}

#pragma mark - FRP
+ (NSValueTransformer *)numberToString {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *number) {
        return [number stringValue];
    } reverseBlock:^(NSString *str) {
        return @([str intValue]);
    }];
}

+ (NSValueTransformer *)avatarUrlCheck {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *urlString) {
        return [urlString checkAvatarUrl];
    } reverseBlock:^id(NSString *urlString) {
        return urlString;
    }];
}

@end
