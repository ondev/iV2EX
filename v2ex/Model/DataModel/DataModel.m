//
//  DataModel.m
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "DataModel.h"
#import "DBModel.h"
#import "NetModel.h"
#import "FileModel.h"
#import <objc/message.h>
#import <NSInvocation+RACTypeParsing.h>

@interface DataModel ()<DBModelDelegate, NetModelDelegate, FileModelDelegate>
@property (nonatomic, strong) DBModel *dbModel;
@property (nonatomic, strong) NetModel *netModel;
@property (nonatomic, strong) FileModel *fileModel;
@property (nonatomic, strong) NSDate *startRequestDate;
@end

@implementation DataModel
@synthesize requestPolicy;

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.dbModel = [DBModel new];
//        _dbModel.delegate = self;
//        self.netModel = [NetModel new];
//        _netModel.delegate = self;
//        self.fileModel = [FileModel new];
//        _fileModel.delegate = self;
    }
    
    return self;
}

- (void)dealloc {
    
}

#pragma mark - DataModelProtocol
- (BOOL)login:(NSString *)userName passwd:(NSString *)passwd {
    return [self requestWithSelector:_cmd, userName, passwd, nil];
}

- (BOOL)logout {
    return [self requestWithSelector:_cmd, nil];
}

- (BOOL)requestDailyBalance {
    return [self requestWithSelector:_cmd, nil];
}

- (BOOL)requestSiteStats {
    return [self requestWithSelector:_cmd, nil];
}

- (BOOL)requestSiteInfor {
    return [self requestWithSelector:_cmd, nil];
}

//请求所有节点 NodesApiUrl
- (BOOL)requestAllNodes {
    return [self requestWithSelector:_cmd, nil];
}

//请求节点概要
- (BOOL)requestNodeInforByID:(NSString *)nodeId {
    return [self requestWithSelector:_cmd, nodeId, nil];
}

- (BOOL)requestNodeInforByName:(NSString *)nodeName {
    return [self requestWithSelector:_cmd, nodeName, nil];

}

//请求最新主题列表
- (BOOL)requestLatestTopic {
    return [self requestWithSelector:_cmd, nil];
}

//请求节点主题列表 parse html
- (BOOL)requestTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit {
    return [self requestWithSelector:_cmd, nodeUrl, page, limit, nil];
}

//请求主题内容    ShowTopicApiUrl
- (BOOL)requestTopicDetail:(NSString *)topicId {
    return [self requestWithSelector:_cmd, topicId, nil];
}

//请求主题回复列表  ShowTopicReplayApiUrl
- (BOOL)requestTopicReplay:(NSString *)topicId {
    return [self requestWithSelector:_cmd, topicId, nil];
}

//请求个人资料  ShowMemberInforApiUrl
- (BOOL)requestMemberInforById:(NSString *)userId {
    return [self requestWithSelector:_cmd, userId, nil];
}

//请求个人资料  ShowMemberInforApiUrl
- (BOOL)requestMemberInforByName:(NSString *)username {
    return [self requestWithSelector:_cmd, username, nil];
}


//创建主题
- (BOOL)createTopic:(NSString *)topicTitle toNode:(NSString *)nodeName content:(NSString *)content {
    return [self requestWithSelector:_cmd, topicTitle, nodeName, content, nil];
}

- (BOOL)replyTopic:(NSString *)topicId content:(NSString *)content {
    return [self requestWithSelector:_cmd, topicId, content, nil];
}

#pragma mark - Backend Server
- (BOOL)registerToken:(NSString *)token {
    return [self requestWithSelector:_cmd, token, nil];
}

- (BOOL)updatePushSetting:(NSNumber *)type token:(NSString *)token filter:(NSString *)careWord {
    return [self requestWithSelector:_cmd, type, token, careWord, nil];
}

- (BOOL)updateStatus:(NSString *)token status:(NSNumber *)status {
    return [self requestWithSelector:_cmd, token, status, nil];
}

- (BOOL)requestClientConfig {
    return [self requestWithSelector:_cmd, nil];
}

- (BOOL)resetData:(NSString *)token {
    return [self requestWithSelector:_cmd, token, nil];
}

#pragma mark - Dispatch Message
//http://justsee.iteye.com/blog/1931346
- (BOOL)requestWithSelector:(SEL)selector, ... {
    [self startOneRequest];
    
    NSMutableArray *argsArray = [[NSMutableArray alloc] init];
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, selector);
    id arg = nil;
    while ((arg = va_arg(list, id)))
    {
        [argsArray addObject:arg];
    }
    //结束可变参数的获取
    va_end(list);
    
    switch (self.requestPolicy) {
        case RequestReturnCacheDataElseLoad:
            return [self careCacheRequestSelector:selector param:argsArray];
        case RequestReloadIgnoringCacheData:
            return [self ignoreCacheRequestSelector:selector param:argsArray];
        default:
            break;
    }
    
    return NO;
}

- (BOOL)careCacheRequestSelector:(SEL)selector param:(NSArray *)param {
    
    if ([self getFromFile:selector param:param]) {
        return YES;
    }
    else if ([self getFromDB:selector param:param]) {
        return YES;
    }
    else {
        return [self getFromNet:selector param:param];
    }
    
    return NO;
}

- (BOOL)ignoreCacheRequestSelector:(SEL)selector param:(NSArray *)param {
    
    return [self getFromNet:selector param:param];
}

- (BOOL)getFromFile:(SEL)selector param:(NSArray *)param {
    if (!_fileModel) {
        self.fileModel = [FileModel new];
        _fileModel.delegate = self;
    }
    return [self object:_fileModel performSelector:selector withObjects:param];
}

- (BOOL)getFromDB:(SEL)selector param:(NSArray *)param {
    if (!_dbModel) {
        self.dbModel = [DBModel new];
        _dbModel.delegate = self;
    }
    
    return [self object:_dbModel performSelector:selector withObjects:param];
}

- (BOOL)getFromNet:(SEL)selector param:(NSArray *)param {
    if (!_netModel) {
        self.netModel = [NetModel new];
        _netModel.delegate = self;
    }
    
    return [self object:_netModel performSelector:selector withObjects:param];
}

- (BOOL)object:(id)object performSelector:(SEL)selector withObjects:(NSArray *)objects {
    if ([object respondsToSelector:selector]) {
        
        NSMethodSignature *signature = [object methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:object];
        [invocation setSelector:selector];
        
        NSUInteger i = 1;
        for (id object in objects) {
            [invocation setArgument:(void *)&object atIndex:++i];
        }
        
        [invocation invoke];
        if ([signature methodReturnLength]) {
            BOOL ret;
            [invocation getReturnValue:&ret];
            return ret;
        }
    }
    return NO;
}

#pragma mark - DBModelDelegate
- (void)dbModel:(DBModel *)dbModel didFinishWithData:(id)data {
    [self finishLoading:data];
}

- (void)dbModel:(DBModel *)dbModel didFailedWithError:(NSError *)error {
    [self failedLoading:error];
}

#pragma mark - NetModelDelegate
- (void)netModel:(NetModel *)netModel didFinishWithData:(id)data {
    [self finishLoading:data];
}

- (void)netModel:(NetModel *)netModel didFailedWithError:(NSError *)error {
    [self failedLoading:error];
}

#pragma mark - FileModelDelegate
- (void)fileModel:(FileModel *)fileModel didFinishWithData:(id)data {
    [self finishLoading:data];
}

- (void)fileModel:(FileModel *)fileModel didFailedWithError:(NSError *)error {
    [self failedLoading:error];
}

#pragma mark - Loading Result
- (void)finishLoading:(id)data {
    //下拉刷新，防止网速过快，没有动画效果
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startRequestDate];
    if (interval > 1) {
        [self callSuccessDelegate:data];
    }
    else {
        double delayInSeconds = interval;
        __weak typeof (self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf callSuccessDelegate:data];
        });
    }
}

- (void)failedLoading:(NSError *)error {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startRequestDate];
    if (interval > 1) {
        [self callErrorDelegate:error];
    }
    else {
        double delayInSeconds = interval;
        __weak typeof (self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf callErrorDelegate:error];
        });
    }
}

#pragma mark - Request Time Assign
- (void)callSuccessDelegate:(id)data {
    [self endOneRequest];
    if ([_delegate respondsToSelector:@selector(dataModel:didFinishWithData:)]) {
        [_delegate dataModel:self didFinishWithData:data];
    }
}

- (void)callErrorDelegate:(NSError *)error {
    [self endOneRequest];
    if ([_delegate respondsToSelector:@selector(dataModel:didFailWithError:)]) {
        [_delegate dataModel:self didFailWithError:error];
    }
}

- (void)startOneRequest {
    self.startRequestDate = [NSDate date];
}

- (void)endOneRequest {
}


#pragma mark - FRP
- (RACSignal *)fetchAllNodes {
    return [self fetchWithSelector:_cmd, nil];
}

- (RACSignal *)fetchNodeByID:(NSString *)nodeId {
    return [self fetchWithSelector:_cmd, nodeId, nil];
}

- (RACSignal *)fetchNodeByName:(NSString *)nodeName {
    return [self fetchWithSelector:_cmd, nodeName, nil];
}

- (RACSignal *)fetchLatestTopics {
    return [self fetchWithSelector:_cmd, nil];
}

- (RACSignal *)fetchTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit {
    return [self fetchWithSelector:_cmd, nodeUrl, page, limit, nil];
}

- (RACSignal *)fetchTopicDetail:(NSString *)topicId {
    return [self fetchWithSelector:_cmd, topicId, nil];
}

- (RACSignal *)fetchTopicReplay:(NSString *)topicId {
    return [self fetchWithSelector:_cmd, topicId, nil];
}

- (RACSignal *)fetchMemberInforById:(NSString *)userId {
    return [self fetchWithSelector:_cmd, userId, nil];
}

- (RACSignal *)fetchMemberInforByName:(NSString *)username {
    return [self fetchWithSelector:_cmd, username, nil];
}

//与后台服务器通信
- (RACSignal *)registerPush:(NSString *)token {
    return [self fetchWithSelector:_cmd, token, nil];
}

- (RACSignal *)updatePush:(NSString *)pushSlot token:(NSString *)token {
    return [self fetchWithSelector:_cmd, pushSlot, token, nil];
}

//服务器对客户端的一些配置，如正式iap地址
- (RACSignal *)fetchClientConfig {
    return [self fetchWithSelector:_cmd, nil];
}

- (RACSignal *)resetPush:(NSString *)token {
    return [self fetchWithSelector:_cmd, token, nil];
}

- (RACSignal *)updateOnline:(NSString *)online token:(NSString *)token {
    return [self fetchWithSelector:_cmd, online, token, nil];
}

#pragma mark - Common
- (RACSignal *)fetchWithSelector:(SEL)selector, ... {
    [self startOneRequest];
    
    NSMutableArray *argsArray = [[NSMutableArray alloc] init];
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, selector);
    id arg = nil;
    while ((arg = va_arg(list, id)))
    {
        [argsArray addObject:arg];
    }
    //结束可变参数的获取
    va_end(list);
    
    switch (self.requestPolicy) {
        case RequestReturnCacheDataElseLoad:
            return [self careCacheFetchSelector:selector param:argsArray];
        case RequestReloadIgnoringCacheData:
            return [self ignoreCacheFetchSelector:selector param:argsArray];
        default:
            break;
    }
    
    return nil;
}

- (RACSignal *)careCacheFetchSelector:(SEL)selector param:(NSArray *)param {
    RACSignal *s = [self fetchFromLocal:selector param:param];
    if (s) {
        @weakify(self);
        return [s flattenMap:^RACStream *(id value) {
            if (value) {
                return [RACSignal return:value];
            }
            else {
                @strongify(self);
                return [self fetchFromNet:selector param:param];
            }
        }];
    }
    
    return [self fetchFromNet:selector param:param];
}

- (RACSignal *)ignoreCacheFetchSelector:(SEL)selector param:(NSArray *)param {
    
    return [self fetchFromNet:selector param:param];
}

- (RACSignal *)fetchFromFile:(SEL)selector param:(NSArray *)param {
    if (!_fileModel) {
        self.fileModel = [FileModel new];
        _fileModel.delegate = self;
    }
    return [self object:_fileModel fetchSelector:selector withObjects:param];
}

- (RACSignal *)fetchFromDB:(SEL)selector param:(NSArray *)param {
    if (!_dbModel) {
        self.dbModel = [DBModel new];
        _dbModel.delegate = self;
    }
    _dbModel.webServiceIdentifier = [self retrieveIdentifier:selector param:param];
    return [self object:_dbModel fetchSelector:selector withObjects:param];
}

- (RACSignal *)fetchFromLocal:(SEL)selector param:(NSArray *)param {
    RACSignal *s = [self fetchFromFile:selector param:param];
    if (s) {
        return [s flattenMap:^RACStream *(id value) {
            if (value) {
                return [RACSignal return:value];
            }
            else {
                return [self fetchFromDB:selector param:param];
            }
        }];
    }
    
    return [self fetchFromDB:selector param:param];
}

- (RACSignal *)fetchFromNet:(SEL)selector param:(NSArray *)param {
    if (!_netModel) {
        self.netModel = [NetModel new];
        _netModel.delegate = self;
    }
    _netModel.webServiceIdentifier = [self retrieveIdentifier:selector param:param];
    _netModel.requestPolicy = self.requestPolicy;
    return [self object:_netModel fetchSelector:selector withObjects:param];
}

- (NSString *)retrieveIdentifier:(SEL)selector param:(NSArray *)param {
    NSMutableString *result = [NSMutableString new];
    [result appendString:NSStringFromSelector(selector)];
    for (id obj in param) {
        [result appendFormat:@"%@", obj];
    }
    
    return result;
}

- (RACSignal *)object:(id)object fetchSelector:(SEL)selector withObjects:(NSArray *)objects {
    if ([object respondsToSelector:selector]) {
        
        NSMethodSignature *signature = [object methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:object];
        [invocation setSelector:selector];
        
#define WAY1 1
        NSUInteger i = 1;
        for (id object in objects) {
            
            if (WAY1) {
                [invocation rac_setArgument:object atIndex:++i];
            }
            else {
                [invocation setArgument:(void *)&object atIndex:++i];
            }
        }
        
        [invocation invoke];
        
        //way 1
        if (WAY1) {
            RACSignal *signal = [invocation rac_returnValue];
            return signal;
        }
        else {
        
            //way 2
            if ([signature methodReturnLength]) {
                __autoreleasing RACSignal *ret = nil;
                [invocation getReturnValue:&ret];
                return [ret replayLazily];
            }
        }
#undef WAY1
    }
    return nil;
}

@end
