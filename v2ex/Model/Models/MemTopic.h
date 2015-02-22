//
//  TopicObject.h
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProtocol.h"

@interface MemTopic : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing, TopicModel>

+ (NSMutableArray *)parse:(NSData *)html;   //parse topic list

//parse topic detail and replay
- (void)parseDetail:(NSArray *)dic;
- (NSArray *)parseReplay:(NSArray *)dic;

//parse latest topic
+ (NSMutableArray *)parseLatest:(NSArray *)array;
@end
