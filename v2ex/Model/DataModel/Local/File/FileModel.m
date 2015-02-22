//
//  FileModel.m
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "FileModel.h"
#import "FileUtil.h"

@interface FileModel()
@end

@implementation FileModel

- (id)init {
    self = [super init];
    if (self) {
        NSString *filePath = [FileUtil filePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                DLog(@"Create file cache folder error:%@", [error localizedDescription]);
            }
        }
    }
    return self;
}

#pragma mark - DataModelProtocol
- (BOOL)requestSiteStats {
    return [self handleFile:@"stats.json"];
}

- (BOOL)requestSiteInfor {
    return [self handleFile:@"info.json"];
}

- (BOOL)requestClientConfig {
    return [self handleFile:@"config.json"];
}

#pragma mark - Private
- (void)getFileError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(fileModel:didFailedWithError:)]) {
        [_delegate fileModel:self didFailedWithError:error];
    }
}

- (void)getFileSuccess:(id)data {
    if ([_delegate respondsToSelector:@selector(fileModel:didFinishWithData:)]) {
        [_delegate fileModel:self didFinishWithData:data];
    }
}

- (BOOL)handleFile:(NSString *)fileName {
    NSString *filePath = [[FileUtil filePath] stringByAppendingPathComponent:fileName];
    if ([FileUtil fileExistORNot:filePath]) {
        NSDate *modDate = [FileUtil fileModifyDate:filePath];
        NSTimeInterval interval = [modDate timeIntervalSinceNow];
        if (interval > -FileExpireTime ) {
            NSDictionary *dic = [FileUtil fileContent:fileName];
            [self getFileSuccess:dic];
            return YES;
        }
    }
    
    return NO;
}
@end
