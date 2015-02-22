//
//  NodeObj.m
//  v2ex
//
//  Created by Haven on 18/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import "MemNode.h"
#import "Utils.h"

@implementation MemNode
@synthesize created;
@synthesize nodeId;
@synthesize nodeName;
@synthesize nodeTitle;
@synthesize nodeUrl;
@synthesize topicCount;
@synthesize footer;
@synthesize header;
@synthesize title_alternative;

+ (NSArray *)parse:(NSArray *)arr {
    NSMutableArray *res = [NSMutableArray new];
    for (NSDictionary *dic in arr) {
        MemNode *obj = [MemNode new];
        [obj update:dic];
        [res addObject:obj];
    }
    
    return res;
}

- (void)update:(id)obj {
    NSDictionary *dic = (NSDictionary *)obj;
    self.nodeId = [NSString stringWithFormat:@"%@", [dic valueForKey:@"id"]];
    self.nodeName = [dic valueForKey:@"name"];
    self.nodeUrl = [dic valueForKey:@"url"];
    self.nodeTitle = [dic valueForKey:@"title"];
    self.title_alternative = [dic valueForKey:@"title_alternative"];
    self.topicCount = [NSString stringWithFormat:@"%@", [dic valueForKey:@"topics"]];
    
    //remove html tag
    NSRange r;
    id value = [dic objectForKey:@"header"];
    NSString *h = value == [NSNull null] ? self.nodeTitle : value;
    while ((r = [h rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        h = [h stringByReplacingCharactersInRange:r withString:@""];
    
    
    self.header = h;
    
    value = [dic valueForKey:@"footer"];
    NSString *fooder = value == [NSNull null] ? nil : value;
    self.footer = fooder;
    
    self.created = [NSString stringWithFormat:@"%@", [dic valueForKey:@"created"]];
}

#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"nodeId":@"id", @"nodeName":@"name", @"nodeTitle":@"title", @"nodeUrl":@"url",
             @"topicCount":@"topics"};
}

+ (NSValueTransformer *)nodeIdJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)topicCountJSONTransformer {
    return [Utils numberToString];
}

+ (NSValueTransformer *)createdJSONTransformer {
    return [Utils numberToString];
}

#pragma mark - MTLManagedObjectSerializing
+ (NSString *)managedObjectEntityName {
    return @"DBNode";
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return nil;
}

//保存到数库时，用来查看是否已存在的字段
+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"nodeId"];
}
@end
