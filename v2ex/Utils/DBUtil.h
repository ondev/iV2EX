//
//  DBUtils.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModelProtocol.h"
#import "MemNode.h"
#import "MemUser.h"
#import "MemTopic.h"
#import "DBUser.h"
#import "DBNode.h"
#import "DBTopic.h"

@interface DBUtil : NSObject

+ (NSDate *)webServiceLastCall:(NSString *)serviceIdentifier;
+ (BOOL)updateLastModify:(NSString *)identifier;
+ (BOOL)saveAllNode:(id)response;
+ (NSInteger)saveTopics:(id)response toNode:(NSString *)nodeName ;
+ (BOOL)saveLatestTopic:(id)response;
+ (BOOL)saveOneNode:(id)response;
+ (BOOL)saveTopicDetail:(id)response;
+ (BOOL)saveTopicReplies:(id)response toTopic:(NSString *)topicId;
+ (BOOL)saveUserGeneralInfor:(id)response;
+ (BOOL)createTopic:(NSString *)topicId money:(NSData *)data;
+ (BOOL)replyTopic:(NSString *)topicId content:(NSString *)content money:(NSData *)data;

+ (BOOL)updatePushSetting:(NSNumber *)type filter:(NSString *)careWord;

+ (NSArray *)loadNodesByIds:(NSArray *)nodeIds;
+ (NSArray *)loadTopicsByIds:(NSArray *)topicIds;
+ (NSArray *)memDataFromDB:(NSArray *)dbData tableName:(NSString *)tableName;
+ (void)cloneDBObj:(id)dbObj toMemObj:(id)memObj;

+ (DBTopic *)loadTopicFromDBById:(NSString *)topicId;
+ (MemTopic *)topicById:(NSString *)topicId;
+ (DBUser *)loadDBUserByName:(NSString *)userName;
+ (MemUser *)loadMemUserByName:(NSString *)userName;
+ (DBUser *)loadDBUser;

#pragma mark - FRP
+ (BOOL)updateOrInsertNode:(MemNode *)node;
+ (DBNode *)getNodeByID:(NSString *)nodeId;
+ (MemNode *)nodeByID:(NSString *)nodeId;
+ (MemNode *)nodeByName:(NSString *)nodeName;

+ (BOOL)updateOrInsertTopic:(MemTopic *)topic;
@end
