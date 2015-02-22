//
//  DataModelProtocol.h
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>
//所有网络请求接口


typedef NS_ENUM(NSInteger, WebServiceType) {
    Login_ServiceType,
    Logout_ServiceType,
    SiteInfor_ServiceType,
    SiteStats_ServiceType,
    AllNode_ServiceType,
    TopicList_ServiceType,
    LatestTopic_ServiceType,
    NodeInfor_ServiceType,
    TopicDetail_ServiceType,
    TopicReplies_ServiceType,
    
    //同步用户数据接口
    UserInfor_ServiceType,
    
    CreateTopic_ServiceType,
    ReplyTopic_ServiceType,
    
    //Backend Server
    RegisterUser_ServiceType,
    PushSettingUpdate_ServiceType,
    ClientConfig_ServiceType, //服务器同步配置信息
    ClientReset_ServiceType
};

//where to get data
typedef NS_ENUM(NSInteger, RequestPolicy) {
    RequestReturnCacheDataElseLoad,
    RequestReloadIgnoringCacheData
};

@protocol DataModelProtocol <NSObject>

@optional
@property (nonatomic) RequestPolicy requestPolicy;
@property (nonatomic, strong) NSString *webServiceIdentifier;
//纯获取数据接口
- (BOOL)login:(NSString *)userName passwd:(NSString *)passwd;
- (BOOL)logout;

- (BOOL)requestDailyBalance;

- (BOOL)requestSiteStats;
- (BOOL)requestSiteInfor;
- (BOOL)requestAllNodes;                      //请求所有节点 NodesApiUrl
- (BOOL)requestNodeInforByID:(NSString *)nodeId;                       //请求节点概要
- (BOOL)requestNodeInforByName:(NSString *)nodeName;
- (BOOL)requestLatestTopic;                                        //请求最新主题列表
- (BOOL)requestTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit;    //请求节点主题列表 parse html
- (BOOL)requestTopicDetail:(NSString *)topicId;                    //请求主题内容    ShowTopicApiUrl
- (BOOL)requestTopicReplay:(NSString *)topicId;                    //请求主题回复列表  ShowTopicReplayApiUrl
- (BOOL)requestMemberInforById:(NSString *)userId;                 //请求个人资料  ShowMemberInforApiUrl
- (BOOL)requestMemberInforByName:(NSString *)username;             //请求个人资料  ShowMemberInforApiUrl

//更改数据接口
- (BOOL)createTopic:(NSString *)topicTitle toNode:(NSString *)nodeName content:(NSString *)content; //创建主题
- (BOOL)replyTopic:(NSString *)topicId content:(NSString *)content;  //回复主题

//后台服务器通信
- (BOOL)registerToken:(NSString *)token;
- (BOOL)updatePushSetting:(NSNumber *)type token:(NSString *)token filter:(NSString *)careWord;
- (BOOL)updateStatus:(NSString *)token status:(NSNumber *)status;
- (BOOL)requestClientConfig;
- (BOOL)resetData:(NSString *)token;

//FRP
- (RACSignal *)fetchAllNodes;
- (RACSignal *)fetchNodeByID:(NSString *)nodeId;
- (RACSignal *)fetchNodeByName:(NSString *)nodeName;
- (RACSignal *)fetchLatestTopics;
- (RACSignal *)fetchTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit;
- (RACSignal *)fetchTopicDetail:(NSString *)topicId;
- (RACSignal *)fetchTopicReplay:(NSString *)topicId;                    //请求主题回复列表  ShowTopicReplayApiUrl
- (RACSignal *)fetchMemberInforById:(NSString *)userId;                 //请求个人资料  ShowMemberInforApiUrl
- (RACSignal *)fetchMemberInforByName:(NSString *)username;             //请求个人资料  ShowMemberInforApiUrl

- (RACSignal *)registerPush:(NSString *)token;
- (RACSignal *)updatePush:(NSString *)pushSlot token:(NSString *)token;
- (RACSignal *)fetchClientConfig; //服务器对客户端的一些配置，如正式iap地址
- (RACSignal *)resetPush:(NSString *)token;
- (RACSignal *)updateOnline:(NSString *)online token:(NSString *)token;
@end

