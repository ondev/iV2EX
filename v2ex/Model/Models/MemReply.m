//
//  ReplayObject.m
//  v2ex
//
//  Created by Haven on 16/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "MemReply.h"
#import "Utils.h"

@implementation MemReply
@synthesize content, thanks, userName, userId, tagline, avatar_mini, avatar_normal, avatar_large, replyId, last_modified, created, topicId;


+ (NSArray *)parse:(NSArray *)objs {
    NSMutableArray *replays = [NSMutableArray new];
    
    for (id obj in objs) {
        MemReply *replay = [MemReply new];
        
        replay.thanks   = obj[@"thanks"];
        replay.content  = obj[@"content"];
        
        id member = obj[@"member"];
        replay.userName = member[@"username"];
        replay.userId   = member[@"id"];
        replay.tagline  = member[@"tagline"];
        replay.avatar_normal = [member[@"avatar_normal"] checkAvatarUrl];
        replay.avatar_mini = [member[@"avatar_mini"] checkAvatarUrl];
        replay.avatar_large = [member[@"avatar_large"] checkAvatarUrl];
        
        
        replay.replyId = obj[@"id"];
        replay.last_modified = obj[@"last_modified"];
        replay.created = obj[@"created"];
        
        [replays addObject:replay];
    }
    
    return replays;
}

#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"replyId":@"id", @"userName":@"member.username", @"userId":@"member.id", @"tagline":@"member.tagline", @"avatar_mini":@"member.avatar_mini", @"avatar_normal":@"member.avatar_normal",
             @"avatar_large":@"member.avatar_large"};
}

+ (NSValueTransformer *)replyIdJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)thanksJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)userIdJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)createdJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)last_modifiedJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)avatar_miniJSONTransformer {
    return [Utils avatarUrlCheck];
}

+ (NSValueTransformer *)avatar_normalJSONTransformer {
    return [Utils avatarUrlCheck];
}

+ (NSValueTransformer *)avatar_largeJSONTransformer {
    return [Utils avatarUrlCheck];
}

#pragma mark - MTLManagedObjectSerializing
+ (NSString *)managedObjectEntityName {
    return @"DBReply";
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return nil;
}

//保存到数库时，用来查看是否已存在的字段
+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"replyId"];
}
@end
