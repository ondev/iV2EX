//
//  FileModel.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModelProtocol.h"

@class FileModel;

@protocol FileModelDelegate <NSObject>

- (void)fileModel:(FileModel *)fileModel didFinishWithData:(id)data;
- (void)fileModel:(FileModel *)fileModel didFailedWithError:(NSError *)error;

@end

@interface FileModel : NSObject<DataModelProtocol>
@property (nonatomic, weak) id<FileModelDelegate> delegate;
@end
