//
//  ReplayObject.h
//  v2ex
//
//  Created by Haven on 16/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProtocol.h"

@interface MemReply : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing, ReplyModel>

+ (NSArray *)parse:(NSArray *)objs;

@end
