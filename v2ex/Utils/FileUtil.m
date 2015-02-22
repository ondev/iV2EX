//
//  FileUtils.m
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

+ (NSString *)filePath {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [searchPaths objectAtIndex: 0];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"files"];
    
    return path;
}

+ (NSDate *)fileModifyDate:(NSString *)filePath {
    NSError *error = nil;
    NSDictionary* properties = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    NSDate *modifyDate = [properties objectForKey:NSFileModificationDate];
    
    return modifyDate;
}

+ (BOOL)fileExistORNot:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (id)fileContent:(NSString *)fileName {
    NSString *filePath = [[FileUtil filePath] stringByAppendingPathComponent:fileName];
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return dic;
}

+ (BOOL)save:(id)content toFile:(NSString *)fileName {
    NSString *filePath = [[FileUtil filePath] stringByAppendingPathComponent:fileName];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:content];
    BOOL ret = [data writeToFile:filePath atomically:NO];
    return ret;
}
@end
