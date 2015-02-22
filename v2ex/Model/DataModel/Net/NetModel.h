//
//  NetModel.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModelProtocol.h"
#import "NetUtil.h"

@class NetModel;

@protocol NetModelDelegate <NSObject>

- (void)netModel:(NetModel *)netModel didFinishWithData:(id)data;
- (void)netModel:(NetModel *)netModel didFailedWithError:(NSError *)error;

@end

@interface NetModel : NetUtil<DataModelProtocol>
@end
