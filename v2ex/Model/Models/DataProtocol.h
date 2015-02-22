//
//  DataObject.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserModel <NSObject>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *twitter;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *avatar_s;
@property (nonatomic, strong) NSString *avatar_m;
@property (nonatomic, strong) NSString *avatar_l;
@property (nonatomic, strong) NSString *created;

@property (nonatomic, retain) NSString *careWord;
@property (nonatomic, retain) NSNumber *pushType;
@property (nonatomic, retain) id collections;
@end

@protocol NodeModel <NSObject>

@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSString * nodeId;
@property (nonatomic, retain) NSString * nodeName;
@property (nonatomic, retain) NSString * nodeTitle;
@property (nonatomic, retain) NSString * nodeUrl;
@property (nonatomic, retain) NSString * topicCount;
@property (nonatomic, retain) NSString * footer;
@property (nonatomic, retain) NSString * header;
@property (nonatomic, retain) NSString * title_alternative;

@end

@protocol TopicModel <NSObject>

@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSString *nodeTitle;
@property (nonatomic, strong) NSString *nodeName;
@property (nonatomic, strong) NSString *topicTitle;
@property (nonatomic, strong) NSString *topicUrl;
@property (nonatomic, strong) NSString *topicContent ;
@property (nonatomic, strong) NSString *topicHtmlContent;
@property (nonatomic, strong) NSString *topicRepliesCount;
@property (nonatomic, strong) NSString *topicCreated;
@property (nonatomic, strong) NSString *topicLast_modified;
@property (nonatomic, strong) NSString *topicAuthorName;
@property (nonatomic, strong) NSString *topicAuthorImgUrl;
@property (nonatomic, strong) NSSet *replies;
@property (nonatomic, strong) NSNumber *readed;

@end

@protocol ReplyModel <NSObject>

@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *thanks;  //被感谢次数
//member
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *avatar_mini;
@property (nonatomic, strong) NSString *avatar_normal;
@property (nonatomic, strong) NSString *avatar_large;

@property (nonatomic, strong) NSString *replyId;
@property (nonatomic, strong) NSString *last_modified;
@property (nonatomic, strong) NSString *created;

@end
