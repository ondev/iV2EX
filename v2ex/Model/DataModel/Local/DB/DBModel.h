//
//  DBModel.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModelProtocol.h"

@class DBModel;

@protocol DBModelDelegate <NSObject>

- (void)dbModel:(DBModel *)dbModel didFinishWithData:(id)data;
- (void)dbModel:(DBModel *)dbModel didFailedWithError:(NSError *)error;

@end

@interface DBModel : NSObject <DataModelProtocol>
@property (nonatomic, weak) id<DBModelDelegate> delegate;
@end
