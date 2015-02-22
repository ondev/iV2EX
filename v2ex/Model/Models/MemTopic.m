//
//  TopicObject.m
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import "MemTopic.h"
#import "TFHpple.h"
#import "MemReply.h"
#import "Utils.h"

@implementation MemTopic
@synthesize topicAuthorImgUrl;
@synthesize topicAuthorName;
@synthesize topicCreated;
@synthesize readed;
@synthesize topicId;
@synthesize topicTitle;
@synthesize topicUrl;
@synthesize topicContent;
@synthesize topicHtmlContent;
@synthesize topicRepliesCount;
@synthesize topicLast_modified;
@synthesize replies;
@synthesize nodeName;
@synthesize nodeTitle;


+ (NSMutableArray *)parse:(NSData *)html {
    NSMutableArray *ret = [NSMutableArray new];
//    NSString *s = [[NSString alloc] initWithData:html encoding:NSUTF8StringEncoding];
    
    TFHpple *htmlParse = [[TFHpple alloc] initWithHTMLData:html];
    NSArray *lists = [htmlParse searchWithXPathQuery:@"//html/body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@id='TopicsNode']/div"];
    for (TFHppleElement *element in lists) {
        MemTopic *obj = [MemTopic new];
        NSArray *tds = [element searchWithXPathQuery:@"//table/tr/td"];
        for (TFHppleElement *td in tds) {
            
            //image avatar
            if ([[td objectForKey:@"width"] isEqualToString:@"48"]) {
                TFHppleElement *a = [td firstChild];
                TFHppleElement *img = [a firstChild];
                NSString *url = [img objectForKey:@"src"];
                obj.topicAuthorImgUrl = [url checkAvatarUrl];
            }
            
            //title
            if ([[td objectForKey:@"width"] isEqualToString:@"auto"]) {
                TFHppleElement *span = [td firstChild];
                TFHppleElement *a = [span firstChild];
                NSString *urlValue = [a objectForKey:@"href"];
                NSRange r = [urlValue rangeOfString:@"#"];
                NSString *url = [urlValue substringToIndex:r.location];
                NSString *topicId = [url substringFromIndex:3];
                NSString *replays = [urlValue substringFromIndex:r.location+1];
                NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                NSString *replaysCount = [replays stringByTrimmingCharactersInSet:nonDigits];
                NSString *title = [[a firstChild] content];
                
                obj.topicId = topicId;
                obj.topicRepliesCount = replaysCount;
                obj.topicTitle = title;
                obj.topicUrl = [@"http://www.v2ex.com" stringByAppendingString:url];
                
                //author name
                TFHppleElement *span3 = [td children][4];
                TFHppleElement *strong = [span3 firstChild];
                TFHppleElement *a3 = [strong firstChild];
                NSString *authorName = [a3 text];
                obj.topicAuthorName = authorName;
            }
        }
        [ret addObject:obj];
    }
    return ret;
}

- (void)parseDetail:(NSArray *)dic {
    id obj = dic.count > 0 ? dic[0] : nil;
    if (obj) {
        NSString *content = obj[@"content"];
        self.topicContent = content;   //\u000D\u000A\u000D\u000A
        self.topicCreated = obj[@"last_touched"];
    }
}

- (NSArray *)parseReplay:(NSArray *)array {
    return [MemReply parse:array];
}

+ (NSMutableArray *)parseLatest:(NSArray *)array {
    NSMutableArray *rets = [NSMutableArray new];
    for (NSDictionary *dic in array) {
        MemTopic *obj = [MemTopic new];
        obj.topicId = [NSString stringWithFormat:@"%@", dic[@"id"]];
        obj.topicTitle = dic[@"title"];
        obj.topicUrl = dic[@"url"];
        obj.topicContent = dic[@"content"];
        obj.topicRepliesCount = [NSString stringWithFormat:@"%@", dic[@"replies"]];
        obj.topicCreated = dic[@"created"];
        obj.topicLast_modified = dic[@"last_modified"];
        obj.topicAuthorName = dic[@"member"][@"username"];
        NSString *url = dic[@"member"][@"avatar_mini"];
        obj.topicAuthorImgUrl = [url checkAvatarUrl];
        
        [rets addObject:obj];
    }
    
    return rets;
}

#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"topicId":@"id", @"topicTitle":@"title", @"topicUrl":@"url",
             @"topicContent":@"content", @"topicHtmlContent":@"content_rendered",
             @"topicRepliesCount":@"replies", @"topicCreated":@"created",
             @"topicLast_modified":@"last_modified",@"topicAuthorName":@"member.username",
             @"topicAuthorImgUrl":@"member.avatar_mini", @"replies":NSNull.null};
}

+ (NSValueTransformer *)topicIdJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)topicRepliesCountJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)topicCreatedJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)topicLast_modifiedJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)topicAuthorImgUrlJSONTransformer {
    return [Utils avatarUrlCheck];
}

#pragma mark - MTLManagedObjectSerializing
+ (NSString *)managedObjectEntityName {
    return @"DBTopic";
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return nil;
}

//保存到数库时，用来查看是否已存在的字段
+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"topicId"];
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey {
    return @{@"replies"  : [MemReply class]};
}
@end
