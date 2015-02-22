//
//  DBTopic.h
//  v2ex
//
//  Created by Haven on 5/5/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataProtocol.h"
#import "DBReply.h"

@interface DBTopic : NSManagedObject<TopicModel>
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * cacheDate;
@end

@interface DBTopic (CoreDataGeneratedAccessors)

- (void)addRepliesObject:(DBReply *)value;
- (void)removeRepliesObject:(DBReply *)value;
- (void)addReplies:(NSSet *)values;
- (void)removeReplies:(NSSet *)values;

@end
