//
//  DataModel.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModelProtocol.h"

@class DataModel;

@protocol DataModelDelegate <NSObject>

- (void)dataModel:(DataModel *)model didFinishWithData:(id)data;
- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error;

@end

@interface DataModel : NSObject<DataModelProtocol>

@property (nonatomic, weak) id<DataModelDelegate> delegate;

@end
