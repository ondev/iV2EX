//
//  FileUtils.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

+ (NSString *)filePath;

+ (NSDate *)fileModifyDate:(NSString *)filePath;
+ (BOOL)fileExistORNot:(NSString *)filePath;

+ (id)fileContent:(NSString *)fileName;
+ (BOOL)save:(id)content toFile:(NSString *)fileName;
@end
