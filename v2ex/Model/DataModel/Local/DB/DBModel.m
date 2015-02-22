//
//  DBModel.m
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "DBModel.h"
#import "DBUtil.h"
#import "DBNode.h"
#import "DBTopic.h"
#import "DBUser.h"
#import "MemShared.h"
#import "MemReply.h"
#import "NSArray+MTLManipulationAdditions.h"

@interface DBModel ()
@property (nonatomic, strong)  NSDictionary *requestParam;
@end

@implementation DBModel
@synthesize webServiceIdentifier;

- (BOOL)requestAllNodes {
    return [self handleWebService:self.webServiceIdentifier dbTable:@"DBNode" where:nil offset:nil order:nil limit:nil expire:DBExpireTime2];
}

- (BOOL)requestNodeInforByID:(NSString *)nodeId {
    NSString *condition = [NSString stringWithFormat:@"nodeId == '%@'", nodeId];
    return [self handleWebService:self.webServiceIdentifier dbTable:@"DBNode" where:condition];
}

- (BOOL)requestNodeInforByName:(NSString *)nodeName {
    NSString *condition = [NSString stringWithFormat:@"nodeName == '%@'", nodeName];
    return [self handleWebService:self.webServiceIdentifier dbTable:@"DBNode" where:condition];
}

- (BOOL)requestLatestTopic {
    NSString *condition = [NSString stringWithFormat:@"type == '%d'", Latest_Topic_Type];
    return [self handleWebService:self.webServiceIdentifier dbTable:@"DBTopic" where:condition];
}

- (BOOL)requestTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit {
    NSString *nodeName = [nodeUrl lastPathComponent];
    NSString *condition = [NSString stringWithFormat:@"nodeName == '%@'", nodeName];
    NSNumber *offset = @(([page integerValue] - 1) * 20);
    NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"topicCreated" ascending:NO];
    return [self handleWebService:self.webServiceIdentifier dbTable:@"DBTopic" where:condition offset:offset order:sortByTime limit:limit];
}

- (BOOL)requestTopicDetail:(NSString *)topicId {
    NSString *condition = [NSString stringWithFormat:@"topicId == '%@'", topicId];
    return [self handleTopicDetail:condition];
}

- (BOOL)requestTopicReplay:(NSString *)topicId {
    NSString *condition = [NSString stringWithFormat:@"topicId == '%@'", topicId];
    
    return [self handleTopicReplies:condition];
}

- (BOOL)requestMemberInforById:(NSString *)userId {
    NSString *condition = [NSString stringWithFormat:@"userId == '%@'", userId];
    return [self handleUserInfor:condition];
}

- (BOOL)requestMemberInforByName:(NSString *)username {
    NSString *condition = [NSString stringWithFormat:@"userName == '%@'", username];
    return [self handleUserInfor:condition];
}

#pragma mark - Private
- (void)getDBError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(dbModel:didFailedWithError:)]) {
        [_delegate dbModel:self didFailedWithError:error];
    }
}

- (void)getDBSuccess:(id)data {
    if ([_delegate respondsToSelector:@selector(dbModel:didFinishWithData:)]) {
        [_delegate dbModel:self didFinishWithData:data];
    }
}

//根据数库自身判断
- (BOOL)handleTopicDetail:(NSString *)condition {
    NSArray *topics = [DBTopic where:condition];
    if (topics.count) {
        DBTopic *topic = topics[0];
        if (topic.topicContent) {
            NSDate *modDate = topic.cacheDate;
            if (modDate) {
                NSTimeInterval interval = [modDate timeIntervalSinceNow];
                if (interval > -DBExpireTime ) {
                    NSArray *rets = [DBUtil memDataFromDB:topics tableName:@"DBTopic"];
                    [self getDBSuccess:rets[0]];
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)handleTopicReplies:(NSString *)condition {
    NSArray *topics = [DBTopic where:condition];
    if (topics.count) {
        DBTopic *topic = topics[0];
        if ([topic.replies count] > 0) {
            NSDate *modDate = topic.cacheDate;
            if (modDate) {
                NSTimeInterval interval = [modDate timeIntervalSinceNow];
                if (interval > -DBExpireTime ) {
                    NSArray *rets = [DBUtil memDataFromDB:topics tableName:@"DBTopic"];
                    [self getDBSuccess:rets[0]];
                    return YES;
                }
            }
        }
        
        if ([topic.topicRepliesCount integerValue] == 0) {
            NSArray *rets = [DBUtil memDataFromDB:topics tableName:@"DBTopic"];
            [self getDBSuccess:rets[0]];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)handleUserInfor:(NSString *)condition {
    NSArray *users = [DBUser where:condition];
    if (users.count) {
        DBUser *user = users[0];
        NSDate *modDate = user.cacheInforDate;
        if (modDate) {
            NSTimeInterval interval = [modDate timeIntervalSinceNow];
            if (interval > -DBExpireTime ) {
                NSArray *rets = [DBUtil memDataFromDB:users tableName:@"DBUser"];
                [self getDBSuccess:rets[0]];
                return YES;
            }
        }
    }
    
    return NO;
}

//根据webservice来判断是否过期
- (BOOL)handleWebService:(NSString *)identifier dbTable:(NSString *)tableName where:(id)condition {
    return [self handleWebService:identifier dbTable:tableName where:condition offset:nil order:nil limit:nil];
}

- (BOOL)handleWebService:(NSString *)identifier dbTable:(NSString *)tableName where:(id)condition offset:(NSNumber *)offset order:(id)order limit:(NSNumber *)limit {
    return [self handleWebService:identifier dbTable:tableName where:condition offset:offset order:order limit:limit expire:DBExpireTime];
}

- (BOOL)handleWebService:(NSString *)identifier dbTable:(NSString *)tableName where:(id)condition offset:(NSNumber *)offset order:(id)order limit:(NSNumber *)limit expire:(NSInteger)expire {
    NSDate *modDate = [DBUtil webServiceLastCall:identifier];
    if (modDate) {
        NSTimeInterval interval = [modDate timeIntervalSinceNow];
        if (interval > -expire ) {
            NSArray *results = nil;
            if (condition) {
                results = [NSClassFromString(tableName) where:condition offset:offset order:order limit:limit];
            }
            else {
                results = [NSClassFromString(tableName) all];
            }
            
            results = [DBUtil memDataFromDB:results tableName:tableName];
            if (results.count >= [limit integerValue]) {
                [self getDBSuccess:results];
                return YES;
            }
        }
        
    }
    
    return NO;
}

- (RACSignal *)fetchModel:(NSString *)modelName where:(id)condition offset:(NSNumber *)offset order:(id)order limit:(NSNumber *)limit cacheCheck:(NSString *)service expire:(NSInteger)expire {

    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSDate *modifyDate = [DBUtil webServiceLastCall:service];
        if (modifyDate) {
            NSTimeInterval interval = [modifyDate timeIntervalSinceNow];
            if (interval > -expire) {
                NSArray * results = nil;
                Class modelClass = NSClassFromString(modelName);
                NSString *tableName = [modelClass managedObjectEntityName];
                if (condition) {
                    results = [NSClassFromString(tableName) where:condition offset:offset order:order limit:limit];
                }
                else {
                    results = [NSClassFromString(tableName) all];
                }
                
                //NSManagedObject to Memory Object
                NSArray *models = [[[results rac_sequence] map:^id(id value) {
                    NSError *error = nil;
                    id memObj = [MTLManagedObjectAdapter modelOfClass:modelClass fromManagedObject:value error:&error];
                    return memObj;
                }] array];
            
                if (models.count > 0) {
                    [subscriber sendNext:models];
                }
                else {
                    [subscriber sendNext:nil];
                }
            }
            else {
                [subscriber sendNext:nil];
            }
        }
        else {
            [subscriber sendNext:nil];
        }
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
}

#pragma mark - FRP
- (RACSignal *)fetchAllNodes {
    return [self fetchModel:@"MemNode" where:nil offset:nil order:nil limit:nil cacheCheck:self.webServiceIdentifier expire:DBExpireTime2];
}

- (RACSignal *)fetchNodeByID:(NSString *)nodeId {
    return [[self fetchModel:@"MemNode" where:@{@"nodeId": nodeId} offset:nil order:nil limit:@(1) cacheCheck:self.webServiceIdentifier expire:DBExpireTime] map:^id(id value) {
        return ((NSArray *)value).mtl_firstObject;
    }];
}

- (RACSignal *)fetchNodeByName:(NSString *)nodeName {
    return [[self fetchModel:@"MemNode" where:@{@"nodeName": nodeName} offset:nil order:nil limit:@(1) cacheCheck:self.webServiceIdentifier expire:DBExpireTime] map:^id(id value) {
        return ((NSArray *)value).mtl_firstObject;
    }];
}

- (RACSignal *)fetchTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit {
    NSString *nodeName = [nodeUrl lastPathComponent];
    NSString *condition = [NSString stringWithFormat:@"nodeName == '%@'", nodeName];
    NSNumber *offset = @(([page integerValue] - 1) * 20);
    NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"topicCreated" ascending:NO];
    return [self fetchModel:@"MemTopic" where:condition offset:offset order:sortByTime limit:limit cacheCheck:self.webServiceIdentifier expire:DBExpireTime];
}

- (RACSignal *)fetchTopicDetail:(NSString *)topicId {
    NSString *condition = [NSString stringWithFormat:@"topicId == '%@'", topicId];
    return [[self fetchModel:@"MemTopic" where:condition offset:nil order:nil limit:nil cacheCheck:self.webServiceIdentifier expire:DBExpireTime] map:^id(id value) {
        if ([value count] > 0) {
            return value[0];
        }
        
        return nil;
    }];
}

//请求主题回复列表  ShowTopicReplayApiUrl
- (RACSignal *)fetchTopicReplay:(NSString *)topicId {
    NSString *condition = [NSString stringWithFormat:@"topicId == '%@'", topicId];
    return [[self fetchModel:@"MemTopic" where:condition offset:nil order:nil limit:nil cacheCheck:self.webServiceIdentifier expire:DBExpireTime] map:^id(id value) {
        if (value && [value count] > 0) {
            MemTopic *topic = value[0];
            NSArray *replies = [[topic replies] allObjects];
            return replies;
        }
        return nil;
    }];
}

//请求个人资料  ShowMemberInforApiUrl
- (RACSignal *)fetchMemberInforById:(NSString *)userId {
    NSString *condition = [NSString stringWithFormat:@"userId == '%@'", userId];
    return [self fetchModel:@"MemUser" where:condition offset:nil order:nil limit:nil cacheCheck:self.webServiceIdentifier expire:DBExpireTime];
}

//请求个人资料  ShowMemberInforApiUrl
- (RACSignal *)fetchMemberInforByName:(NSString *)username {
    NSString *condition = [NSString stringWithFormat:@"userName == '%@'", username];
    return [self fetchModel:@"MemUser" where:condition offset:nil order:nil limit:nil cacheCheck:self.webServiceIdentifier expire:DBExpireTime];
}

@end
