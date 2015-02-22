//
//  NodeObj.h
//  v2ex
//
//  Created by Haven on 18/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProtocol.h"

@interface MemNode : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing, NodeModel>

+ (NSArray *)parse:(NSArray *)arr;  //load all nodes
- (void)update:(id)obj;
@end
