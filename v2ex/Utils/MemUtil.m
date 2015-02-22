//
//  MemUtils.m
//  v2ex
//
//  Created by Haven on 2/5/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "MemUtil.h"
#import "MemShared.h"
#import "DBUtil.h"
#import "Utils.h"

@implementation MemUtil

+ (BOOL)updateUser {
    NSString *userName = [[MemShared sharedInstance] userName];
    if (userName) {
        [MemShared sharedInstance].user = [DBUtil loadMemUserByName:userName];
    }
    else {
        [MemShared sharedInstance].user = nil;
    }
    
    return YES;
}

+ (NSNumber *)notificationTypeFromString:(NSString *)str {
    NSNumber *nType = nil;
    if ([str rangeOfString:@"在"].location != NSNotFound) {
        nType = @(Notification_Reply);
    }
    else if ([str rangeOfString:@"收藏"].location != NSNotFound) {
        nType = @(Notification_Collected);
    }
    else if ([str rangeOfString:@"感谢了你发"].location != NSNotFound) {
        nType = @(Notification_Thanks_TopicCreate);
    }
    else if ([str rangeOfString:@"感谢了你在"].location != NSNotFound) {
        nType = @(Notification_Thanks_Reply);
    }
    
    return nType;
}

+ (NSString *)notificationStringFromType:(NSNumber *)type {
    NSInteger nType = [type integerValue];
    NSString *notification = nil;
    switch (nType) {
        case Notification_Reply:
            notification = @"%@ 回复了你的主题:%@";
            break;
        case Notification_Collected:
            notification = @"%@ 收藏了你发布的主题:%@";
            break;
        case Notification_Thanks_Reply:
            notification = @"%@ 感谢了你在主题里回复:%@";
            break;
        case Notification_Thanks_TopicCreate:
            notification = @"%@ 感谢了你发布的主题:%@";
            break;
        default:
            break;
    }
    
    
    return notification;
}


+ (NSDate *)estimateDateFromString:(NSString *)formatTime estime:(NSInteger)sec {
    NSTimeInterval interval = 0;
    if ([formatTime rangeOfString:@"刚刚"].location != NSNotFound) {
        interval = -30;
    }
    else if ([formatTime rangeOfString:@"几秒"].location != NSNotFound) {
        interval = -30;
    }
    else if ([formatTime rangeOfString:@"分钟"].location != NSNotFound) {
        NSArray *digital = [MemUtil digitalFromString:formatTime];
        if ([formatTime rangeOfString:@"小时"].location != NSNotFound) {
            assert(digital.count == 2);
            NSInteger hours = [digital[0] integerValue];
            NSInteger mins = [digital[1] integerValue];
            
            interval = -hours * 60 * 60 - mins * 60;
        }
        else {
            assert(digital.count == 1);
            NSInteger mins = [digital[0] integerValue];
            interval = 60 * mins;
        }
    }
    else if ([formatTime rangeOfString:@"天"].location != NSNotFound) {
        NSArray *digital = [MemUtil digitalFromString:formatTime];
        assert(digital.count == 1);
        NSInteger day = [digital[0] integerValue];
        interval = -day * 24 * 60 * 60 - sec;
    }
    else {
//          •  2011-10-13 08:56:13  •  最后回复来自
        NSString *parten = @"(?<=•  ).*(?=  •)";//  •
        
        NSError* error = NULL;
        
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
        NSTextCheckingResult *firstMatch=[reg firstMatchInString:formatTime options:0 range:NSMakeRange(0, [formatTime length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            
            //从urlString当中截取数据
            NSString *result = [formatTime substringWithRange:resultRange];
            //输出结果
            NSDate *date = [Utils dateFromString:result];
            assert(date);
            return date;
        }
        else {
//            •  
            NSRange range = [formatTime rangeOfString:@"•  "];
            if (range.location != NSNotFound) {
                NSString *result = [formatTime substringFromIndex:range.length + range.location];
                NSDate *date = [Utils dateFromString:result];
                assert(date);
                return date;
            }
        }
        return nil;
    }
    
    //刚刚， 几秒钟前，1分钟前, 1小时20分钟前， 1天前, 100天前， 具体时间
    return [NSDate dateWithTimeIntervalSinceNow:interval];
}

+ (NSArray *)digitalFromString:(NSString *)string {
    assert(string);
    
    // Intermediate
    NSMutableArray *results = [NSMutableArray new];
    NSString *tempStr = nil;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    
    while (![scanner isAtEnd]) {
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        tempStr = nil;
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        if (tempStr) {
            [results addObject:tempStr];
        }
    }
    
    return results;
}

+ (NSString *)formatStringFromDate:(NSDate *)date {
    assert(date);
    NSTimeInterval  timeInterval = [date timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分前",temp];
    }
    
    else if((temp = temp/60) < 24){
        result = [NSString stringWithFormat:@"%ld小前",temp];
    }
    
    else if((temp = temp/24) < 30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    
    else if((temp = temp/30) < 12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    
    return  result;
}


+ (NSString *)userName {
    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKeyPath:UserNameKey];
    
    return userName;
}

@end
