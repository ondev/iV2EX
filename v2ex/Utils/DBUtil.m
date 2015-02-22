//
//  DBUtils.m
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "DBUtil.h"
#import "DBConfig.h"
#import "DBNode.h"
#import "TFHpple.h"
#import "DBTopic.h"
#import "DBReply.h"
#import "DBUser.h"
#import "MemUser.h"
#import "MemShared.h"
#import <objc/runtime.h>
#import "NSString+Ext.h"
#import "MemUtil.h"
#import "Utils.h"

@implementation DBUtil

+ (NSDate *)webServiceLastCall:(NSString *)identifier {
    NSString *condition = [NSString stringWithFormat:@"tableOrService == '%@'", identifier];
    NSArray *configs = [DBConfig where:condition];
    NSDate *modDate = nil;
    if (configs.count > 0) {
        DBConfig *c = configs[0];
        modDate = c.lastModifyDate;
    }
    
    return modDate;
}

+ (BOOL)updateLastModify:(NSString *)identifier {
    NSArray *configs = [DBConfig where:@{@"tableOrService":identifier}];
    DBConfig *c = nil;
    if (configs.count > 0) {
        c = configs[0];
    }
    else {
        c = [DBConfig create];
        c.tableOrService = identifier;
    }
    
    c.lastModifyDate = [NSDate date];
    
    return [c save];
}

+ (BOOL)saveAllNode:(id)response {
    //remove old first
    NSArray *nodes = [DBNode all];
    for (DBNode *node in nodes) {
        [node delete];
    }
    
    //save data
    for (NSDictionary *dic in response) {
        DBNode *node = [DBNode create];
        node.nodeId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
        node.nodeName = [dic valueForKey:@"name"];
        node.nodeUrl = [dic valueForKey:@"url"];
        node.nodeTitle = [dic valueForKey:@"title"];
        node.topicCount = [NSString stringWithFormat:@"%@", [dic valueForKey:@"topics"]];
        node.created = [NSString stringWithFormat:@"%@", [dic valueForKey:@"created"]];
        NSRange r;
        id value = [dic objectForKey:@"header"];
        NSString *header = value == [NSNull null] ? node.nodeTitle : value;
        while ((r = [header rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
            header = [header stringByReplacingCharactersInRange:r withString:@""];
        
        
        node.header = header;
        
        value = [dic valueForKey:@"footer"];
        NSString *footer = value == [NSNull null] ? nil : value;
        node.footer = footer;
    }
    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return error ? NO : YES;
}

+ (NSInteger)saveTopics:(id)response toNode:(NSString *)nodeName {
//    NSString *s = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    TFHpple *htmlParse = [[TFHpple alloc] initWithHTMLData:response];
    NSArray *lists = [htmlParse searchWithXPathQuery:@"//html/body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@id='TopicsNode']/div"];
    for (TFHppleElement *element in lists) {
    
        NSString *topicAuthorImgUrl = nil;
        NSString *topicId = nil;
        NSString *topicRepliesCount = nil;
        NSString *topicTitle = nil;
        NSString *topicUrl = nil;
        NSString *topicAuthorName = nil;
        NSDate *topicCreateDate = nil;
        
        NSArray *tds = [element searchWithXPathQuery:@"//table/tr/td"];
        int i = 0;
        for (TFHppleElement *td in tds) {
            
            //image avatar
            if ([[td objectForKey:@"width"] isEqualToString:@"48"]) {
                TFHppleElement *a = [td firstChild];
                TFHppleElement *img = [a firstChild];
                NSString *url = [img objectForKey:@"src"];
                topicAuthorImgUrl = [url checkAvatarUrl];
            }
            
            //title
            if ([[td objectForKey:@"width"] isEqualToString:@"auto"]) {
                TFHppleElement *span = [td firstChild];
                TFHppleElement *a = [span firstChild];
                NSString *urlValue = [a objectForKey:@"href"];
                NSRange r = [urlValue rangeOfString:@"#"];
                NSString *url = [urlValue substringToIndex:r.location];
                NSString *tid = [url substringFromIndex:3];
                NSString *replays = [urlValue substringFromIndex:r.location+1];
                NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                NSString *replaysCount = [replays stringByTrimmingCharactersInSet:nonDigits];
                NSString *title = [[a firstChild] content];
                
                topicId = tid;
                topicRepliesCount = replaysCount;
                topicTitle = title;
                topicUrl = [@"http://www.v2ex.com" stringByAppendingString:url];
                
                //author name
                TFHppleElement *span3 = [td children][4];
                TFHppleElement *strong = [span3 firstChild];
                TFHppleElement *a3 = [strong firstChild];
                topicAuthorName = [a3 text];
                
                NSArray *spans = [td searchWithXPathQuery:@"//span"];
                if (spans.count) {
                    span = spans[1];
                    TFHppleElement *text = [span children][1];
                    
                    NSString *formatTime = [text content];
                    topicCreateDate = [MemUtil estimateDateFromString:formatTime estime:i];
                }
            }
            
            i++;
        }
        
        
        DBTopic *obj = [DBUtil loadTopicFromDBById:topicId];
        assert(obj);
        
        obj.nodeName = nodeName;
        obj.cacheDate = [NSDate date];
        obj.topicAuthorImgUrl = topicAuthorImgUrl;
        obj.topicId = topicId;
        obj.topicRepliesCount = topicRepliesCount;
        obj.topicTitle = topicTitle;
        obj.topicUrl = topicUrl;
        obj.topicAuthorName = topicAuthorName;
        NSTimeInterval interval = [topicCreateDate timeIntervalSince1970];
        obj.topicCreated = [NSString stringWithFormat:@"%f", interval];// [Utils stringFromDate:topicCreateDate];
    }
    
    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return lists.count;
}

+ (BOOL)saveLatestTopic:(id)response {
    //remove old lastest topic
    NSArray *resutls = [DBTopic where:@{@"type": @(Latest_Topic_Type)}];
    for (id obj in resutls) {
        [obj delete];
    }
    
    for (NSDictionary *dic in response) {
        NSString *topicId = [NSString stringWithFormat:@"%@", dic[@"id"]];
        DBTopic *obj = [DBUtil loadTopicFromDBById:topicId];
        assert(obj);
        
        obj.topicId = topicId;
        obj.type = @(Latest_Topic_Type);
        obj.cacheDate = [NSDate date];
        obj.topicTitle = dic[@"title"];
        obj.topicUrl = dic[@"url"];
        obj.topicContent = dic[@"content"];
        obj.topicRepliesCount = [NSString stringWithFormat:@"%@", dic[@"replies"]];
        obj.topicCreated = [NSString stringWithFormat:@"%@", dic[@"created"]];
        obj.topicLast_modified = [NSString stringWithFormat:@"%@", dic[@"last_modified"]];
        obj.topicAuthorName = dic[@"member"][@"username"];
        obj.nodeName = dic[@"node"][@"name"];
        NSString *url = dic[@"member"][@"avatar_mini"];
        obj.topicAuthorImgUrl = [url checkAvatarUrl];
    }
    

    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return error ? NO : YES;
}

+ (BOOL)saveOneNode:(id)response {
    NSString *nodeId = [NSString stringWithFormat:@"%@", response[@"id"]];
    DBNode *node = [DBUtil loadNodeFromDBById:nodeId];
    assert(node);
    
    node.nodeId = [NSString stringWithFormat:@"%@", response[@"id"]];
    node.nodeName = response[@"name"];
    node.nodeUrl = response[@"url"];
    node.nodeTitle = response[@"title"];
    node.title_alternative = response[@"title_alternative"];
    node.topicCount = [NSString stringWithFormat:@"%@", response[@"topics"]];
    
    //remove html tag
    NSRange r;
    id value = response[@"header"];
    NSString *h = value == [NSNull null] ? node.nodeTitle : value;
    while ((r = [h rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        h = [h stringByReplacingCharactersInRange:r withString:@""];
    
    
    node.header = h;
    
    value = response[@"footer"];
    NSString *fooder = value == [NSNull null] ? nil : value;
    node.footer = fooder;
    
    node.created = [NSString stringWithFormat:@"%@", response[@"created"]];
    
    
    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return error ? NO : YES;
}

+ (BOOL)saveTopicDetail:(id)response {
    NSDictionary *dic = [response count] > 0 ? response[0] : nil;
    if (dic) {
        NSString *topicId = [NSString stringWithFormat:@"%@", dic[@"id"]];
        DBTopic *topic = [DBUtil loadTopicFromDBById:topicId];
        assert(topic);
        
        topic.topicId = topicId;
        topic.topicTitle = dic[@"title"];
        topic.topicUrl = dic[@"url"];
        topic.topicContent = dic[@"content"];
        topic.topicRepliesCount = [NSString stringWithFormat:@"%@", dic[@"replies"]];
        topic.nodeName = dic[@"node"][@"name"];
        topic.topicLast_modified = [NSString stringWithFormat:@"%@", dic[@"last_modified"]];
        topic.topicCreated = [NSString stringWithFormat:@"%@", dic[@"created"]];
        topic.cacheDate = [NSDate date];
        
        NSString *url = dic[@"member"][@"avatar_mini"];
        topic.topicAuthorImgUrl = [url checkAvatarUrl];
        topic.topicAuthorName = dic[@"member"][@"username"];
    }
    
    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return error ? NO : YES;
}

+ (BOOL)saveTopicReplies:(id)response toTopic:(NSString *)topicId {
    DBTopic *topic = [DBUtil loadTopicFromDBById:topicId];
    assert(topic);
    
    topic.topicId = topicId;
    for (DBReply *reply in topic.replies) {
        [reply delete];
    }
    topic.replies = nil;
    
    NSMutableSet *replies = [NSMutableSet new];
    for (id obj in response) {
        DBReply *reply = [DBReply create];
        
        reply.thanks   = [NSString stringWithFormat:@"%@", obj[@"thanks"]];
        reply.content  = obj[@"content"];
        
        id member = obj[@"member"];
        reply.userName = member[@"username"];
        reply.userId   = [NSString stringWithFormat:@"%@", member[@"id"]];
        reply.tagline  = member[@"tagline"];
        reply.avatar_normal = [member[@"avatar_normal"] checkAvatarUrl];
        reply.avatar_mini = [member[@"avatar_mini"] checkAvatarUrl];
        reply.avatar_large = [member[@"avatar_large"] checkAvatarUrl];
        
        
        reply.replyId = [NSString stringWithFormat:@"%@", obj[@"id"]];
        reply.last_modified = [NSString stringWithFormat:@"%@", obj[@"last_modified"]];
        reply.created = [NSString stringWithFormat:@"%@", obj[@"created"]];
        
        [replies addObject:reply];
    }
    
    topic.replies = replies;
    
    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return error ? NO : YES;
}

+ (BOOL)saveUserGeneralInfor:(id)response {
    NSDictionary *obj = (NSDictionary *)response;
    NSString *status = obj[@"status"];
    if ([status isEqualToString:@"found"]) {
        NSString *userName = obj[@"username"];
        DBUser *user = [DBUtil loadDBUserByName:userName];
        
        user.userId = [NSString stringWithFormat:@"%@", obj[@"id"]];
        user.homepage = obj[@"url"];
        user.website = obj[@"website"];
        user.twitter = obj[@"twitter"];
        user.location = obj[@"location"];
        user.tagline = obj[@"tagline"];
        user.bio = obj[@"bio"];
        user.cacheInforDate = [NSDate date];
        
        user.avatar_s = [obj[@"avatar_mini"] checkAvatarUrl];
        user.avatar_m = [obj[@"avatar_normal"] checkAvatarUrl];
        user.avatar_l = [obj[@"avatar_large"] checkAvatarUrl];
        user.created = [NSString stringWithFormat:@"%@", obj[@"created"]];
    }
    
    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return error ? NO : YES;
}



+ (NSArray *)moneyParse:(NSData *)data {
    
    TFHpple *htmlParse = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *lists = [htmlParse searchWithXPathQuery:@"//a"];
    
    NSMutableArray *moneyArray = [NSMutableArray new];
    for (TFHppleElement *element in lists) {
        NSArray *eles = [element children];
        NSInteger count = eles.count;
        for (int i = 0; i < count;) {
            NSString *m = [eles[i] content];
            [moneyArray addObject:m];
            i = i + 2;
        }
    }
    
    return moneyArray;
}

+ (BOOL)createTopic:(NSString *)topicId  money:(NSData *)data {
    NSArray *moneyArray = [self moneyParse:data];
    DBUser *user = [DBUtil loadLoginUserFromDB];
    
    return [user save];
}

+ (BOOL)replyTopic:(NSString *)topicId content:(NSString *)content money:(NSData *)data {
    assert(topicId);
    assert(content);
    NSArray *moneyArray = [self moneyParse:data];
    DBUser *user = [DBUtil loadLoginUserFromDB];
    DBTopic *topic = [DBUtil loadTopicFromDBById:topicId];
    assert(topic);
    assert(user);
    
    NSMutableSet *replies = [NSMutableSet setWithSet:topic.replies];
    topic.topicRepliesCount = [NSString stringWithFormat:@"%d", [topic.topicRepliesCount integerValue] + 1];
    topic.replies = nil;
    DBReply *reply = [DBReply create];
    reply.userId = user.userId;
    reply.userName = user.userName;
    reply.avatar_mini = user.avatar_s;
    reply.content = content;
    [replies addObject:reply];
    topic.replies = replies;
    
    NSError *error = nil;
    [[NSManagedObjectContext defaultContext] save:&error];
    
    return error ? NO : YES;
}

+ (BOOL)updatePushSetting:(NSNumber *)type filter:(NSString *)careWord {
    DBUser *user = [DBUtil loadLoginUserFromDB];
    user.pushType = type;
    user.careWord = careWord;
    
    return [user save];
}

#pragma mark - DB Queue
+ (DBUser *)loadLoginUserFromDB {
    NSString *userName = [[MemShared sharedInstance] userName];
    assert(userName);
    DBUser *user = [DBUtil loadDBUserByName:userName];
    
    return user;
}

+ (DBTopic *)loadTopicFromDBById:(NSString *)topicId {
    DBTopic *topic = nil;
    NSArray *objs = [DBTopic where:@{@"topicId" : topicId}];
    if (objs.count) {
        topic = objs[0];
    }
    else {
        topic = [DBTopic create];
        topic.topicId = topicId;
    }
    
    return topic;
}

+ (DBNode *)loadNodeFromDBById:(NSString *)nodeId {
    DBNode *node = nil;
    NSArray *nodes = [DBNode where:@{@"nodeId": nodeId}];
    if (nodes.count) {
        node = nodes[0];
    }
    else {
        node = [DBNode create];
        node.nodeId = nodeId;
    }
    
    return node;
}

+ (NSArray *)loadNodesByIds:(NSArray *)nodeIds {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeId IN %@", nodeIds];
    NSArray *dbNodes = [DBNode where:predicate];
    NSArray *memNodes = [DBUtil memDataFromDB:dbNodes tableName:@"DBNode"];
    
    return memNodes;
}

+ (NSArray *)loadTopicsByIds:(NSArray *)topicIds {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"topicId IN %@", topicIds];
    NSArray *dbTopics = [DBTopic where:predicate];
    NSArray *memTopics = [DBUtil memDataFromDB:dbTopics tableName:@"DBTopic"];
    
    return memTopics;
}

#pragma mark - NSManagedObject to Memory Object
+ (NSArray *)memDataFromDB:(NSArray *)dbData tableName:(NSString *)tableName {
    NSMutableArray *rets = [NSMutableArray new];
    
    //eg. DBNode to MemNode
    NSString *dataModelType = [tableName substringFromIndex:2];
    NSString *className = [@"Mem" stringByAppendingString:dataModelType];
    
    for (id dbObj in dbData) {
        id memObj = [[NSClassFromString(className) alloc] init];
        [DBUtil cloneDBObj:dbObj toMemObj:memObj];
        [rets addObject:memObj];
    }
    
    return rets;
}

+ (void)cloneDBObj:(id)dbObj toMemObj:(id)memObj {
    NSString *entityName = [[dbObj entity] name];
    
    //attributes
    NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:[dbObj managedObjectContext]] attributesByName];
    for (NSString *attr in attributes) {
        NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                               [[attr substringToIndex:1] capitalizedString],
                               [attr substringFromIndex:1]];
        
        if ([memObj respondsToSelector:NSSelectorFromString(setterStr)]) {
            [memObj setValue:[dbObj valueForKey:attr] forKey:attr];
        }
    }
    
    //relation ship
    NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:[dbObj managedObjectContext]] relationshipsByName];
    for (NSRelationshipDescription *rel in relationships) {
        NSString *keyName = [NSString stringWithFormat:@"%@", rel];
        NSRelationshipDescription *relDesc = [relationships objectForKey:keyName];
        if ([relDesc isToMany]) {
            
            //get a set of all objects in the relationship
            NSMutableSet *sourceSet = [dbObj mutableSetValueForKey:keyName];
            NSMutableSet *clonedSet = [[NSMutableSet alloc] init];
            NSEnumerator *e = [sourceSet objectEnumerator];
            NSManagedObject *relatedObject;
            
            
            while ( relatedObject = [e nextObject]){
                NSString *entityName = [[relatedObject entity] name];
                NSString *dataModelType = [entityName substringFromIndex:2];
                NSString *className = [@"Mem" stringByAppendingString:dataModelType];
                id relatedMemObj = [[NSClassFromString(className) alloc] init];
                [DBUtil cloneDBObj:relatedObject toMemObj:relatedMemObj];
                
                [clonedSet addObject:relatedMemObj];
            }
            
            [memObj setValue:clonedSet forKeyPath:keyName];
        }
        else{
            id relatedDBObj = [dbObj valueForKey:keyName];
            NSString *entityName = [[relatedDBObj entity] name];
            NSString *dataModelType = [entityName substringFromIndex:2];
            NSString *className = [@"Mem" stringByAppendingString:dataModelType];
            id relatedMemObj = [[NSClassFromString(className) alloc] init];
            
            [DBUtil cloneDBObj:relatedDBObj toMemObj:relatedMemObj];
            [memObj setValue:relatedMemObj forKeyPath:keyName];
        }
    }
}

+ (MemTopic *)topicById:(NSString *)topicId {
    assert(topicId);
    
    DBTopic *dbTopic = [DBUtil loadTopicFromDBById:topicId];
    if (dbTopic) {
        
        MemTopic *memTopic = [MemTopic new];
        [DBUtil cloneDBObj:dbTopic toMemObj:memTopic];
        
        
        return memTopic;
    }
    
    return nil;
}


+ (DBUser *)loadDBUserByName:(NSString *)userName {
    assert(userName);
    
    NSString *sql = [NSString stringWithFormat:@"userName == '%@'", userName];
    NSArray *users = [DBUser where:sql];
    DBUser *user = nil;
    if (users.count) {
        user = users[0];
        
    }
    else {
        user = [DBUser create];
        user.userName = userName;
        
        [[NSManagedObjectContext defaultContext] save:nil];
    }
    
    return user;
}

+ (MemUser *)loadMemUserByName:(NSString *)userName {
    assert(userName);
    
    DBUser *user = [DBUtil loadDBUserByName:userName];
    assert(user);
    
    MemUser *mUser = [MemUser new];
    [DBUtil cloneDBObj:user toMemObj:mUser];
    
    return mUser;
}

+ (DBUser *)loadDBUser {
    NSString *userName = [MemShared sharedInstance].userName;
    NSString *sql = [NSString stringWithFormat:@"userName == '%@'", userName];
    NSArray *users = [DBUser where:sql];
    DBUser *user = nil;
    if (users.count) {
        user = users[0];
        
    }
    else {
        user = [DBUser create];
        user.userName = userName;
        [[NSManagedObjectContext defaultContext] save:nil];
    }
    
    return user;
}

#pragma mark - FRP
+ (BOOL)updateOrInsertNode:(MemNode *)node {
    NSError *error = nil;
    NSManagedObject *managedObject = [MTLManagedObjectAdapter managedObjectFromModel:node insertingIntoContext:[[CoreDataManager sharedManager] managedObjectContext] error:&error];
    
    return [managedObject save];
}

+ (DBNode *)getNodeByID:(NSString *)nodeId {
    DBNode *node = nil;
    NSArray *nodes = [DBNode where:@{@"nodeId": nodeId}];
    if (nodes.count) {
        node = nodes[0];
    }
    
    return node;
}

+ (MemNode *)nodeByID:(NSString *)nodeId {
    assert(nodeId);
    DBNode *node = [DBUtil getNodeByID:nodeId];
    MemNode *oneNode = [MemNode new];
    if (node) {
        [DBUtil cloneDBObj:node toMemObj:oneNode];
    }
    else {
        node.nodeId = nodeId;
    }
    
    return oneNode;
}


+ (MemNode *)nodeByName:(NSString *)nodeName {
    assert(nodeName);
    NSArray *nodes = [DBNode where:@{@"nodeName":nodeName}];
    MemNode *node = nil;
    if (nodes.count) {
        node = [MemNode new];
        [DBUtil cloneDBObj:nodes[0] toMemObj:node];
    }
    else {
        node = [MemNode new];
        node.nodeName = nodeName;
    }
    return node;
}

+ (BOOL)updateOrInsertTopic:(MemTopic *)topic {
    NSError *error = nil;
    NSManagedObject *managedObject = [MTLManagedObjectAdapter managedObjectFromModel:topic insertingIntoContext:[[CoreDataManager sharedManager] managedObjectContext] error:&error];
    
    return [managedObject save];
}

@end
