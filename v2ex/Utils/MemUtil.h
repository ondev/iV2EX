//
//  MemUtils.h
//  v2ex
//
//  Created by Haven on 2/5/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemUtil: NSObject

+ (BOOL)updateUser;
+ (NSNumber *)notificationTypeFromString:(NSString *)str;
+ (NSString *)notificationStringFromType:(NSNumber *)type;

+ (NSDate *)estimateDateFromString:(NSString *)formatTime estime:(NSInteger)sec;
+ (NSArray *)digitalFromString:(NSString *)string;
+ (NSString *)formatStringFromDate:(NSDate *)date;

+ (NSString *)userName;
@end
