//
//  NetModel.m
//  v2ex
//
//  Created by Haven on 5/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NetModel.h"
#import "NetHTTPRequestSerializer.h"
#import <AFNetworking.h>
#import "TFHpple.h"
#import "FileUtil.h"
#import "DBUtil.h"
#import "DBNode.h"
#import "DBTopic.h"
#import "DBUser.h"
#import "MemUser.h"
#import "MemReply.h"
#import "MemUtil.h"
#import "Utils.h"
#import "MemShared.h"
#import "UICKeyChainStore.h"
#import <BmobSDK/Bmob.h>


@interface NetModel()
@property (nonatomic, strong) NSDictionary *requestParam;   //webserviceType & needed param
@end

@implementation NetModel
@synthesize requestPolicy;
@synthesize webServiceIdentifier;


#pragma mark - DataModelProtocol
- (BOOL)login:(NSString *)userName passwd:(NSString *)passwd {
    self.htmlApi = YES;
    self.requestURL = LoginApiUrl;
    self.requestParam = @{@"webserviceType":@(Login_ServiceType), @"u":userName, @"p":passwd};
    
    [self.manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        NSInteger statusCode = r.statusCode;
        if (statusCode == 302) {
            NSString *url = [[request URL] absoluteString];
            
            NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieJar cookies]];
            
            NSMutableURLRequest *req1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [req1 setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
            [req1 setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
            [req1 setValue:@"Accept-Language" forHTTPHeaderField:@"en-US,en;q=0.8,zh-CN;q=0.6"];
            [req1 setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
            [req1 setValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
            [req1 setValue:@"http://v2ex.com/signin" forHTTPHeaderField:@"Referer"];
            [req1 setValue:@"v2ex.com" forHTTPHeaderField:@"Host"];
            [req1 setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.137 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
            
            return req1;
        }
        return request;
    }];
    [self request:LoginApiUrl param:nil success:^(id responseObject) {
        
        TFHpple *doc = [[TFHpple alloc]initWithHTMLData:responseObject];
        
        NSString *next = [[doc searchWithXPathQuery:@"//input[@name='next']"][0] objectForKey:@"value"];
        NSString *once = [[doc searchWithXPathQuery:@"//input[@name='once']"][0] objectForKey:@"value"];
        NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:next, @"next", once, @"once", userName, @"u", passwd, @"p", nil];
        
        [self request:LoginApiUrl param:param success:^(id responseObject) {
//            NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//            NSArray *cookies = [cookieJar cookies];
            self.responseObj = responseObject;
            [self requestSuccess];
        } failure:^(NSError *error) {
            [self requestError:error];
        } type:HTTP_POST];
        
    } failure:^(NSError *error) {
        [self requestError:error];
    } type:HTTP_GET];
    
    return YES;
}

- (BOOL)logout {
    self.htmlApi = YES;
    self.requestURL = LogoutApiUrl;
    self.requestParam = @{@"webserviceType":@(Logout_ServiceType)};
    
    [self request:LogoutApiUrl param:nil success:^(id responseObject) {
        self.responseObj = responseObject;
        [self requestSuccess];
    } failure:^(NSError *error) {
        [self requestError:error];
    } type:HTTP_GET];
    
    return YES;
}

- (BOOL)requestDailyBalance {
    self.htmlApi = YES;
    self.hideLoadingView = YES;
    self.requestURL = BalanceDailyUrl;
    [self request:self.requestURL param:nil success:^(id responseObject) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([html rangeOfString:@"每日登录奖励已领取"].location != NSNotFound) {
            DLog(@"每日登录奖励已领取");
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"每日登录奖励已领取"                                                                      forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:NetServerUrl code:1000 userInfo:userInfo];
            [self requestError:error];
        }
        else {
            NSError *error = nil;
            NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"(?<=location.href = ').*(?=')" options:0 error:&error];
            NSTextCheckingResult *firstMatch=[reg firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
            
            if (firstMatch) {
                NSRange resultRange = [firstMatch rangeAtIndex:0];
                
                //从urlString当中截取数据
                NSString *result = [html substringWithRange:resultRange];
                DLog(result, nil);
                
                NSString *url = [NSString stringWithFormat:@"http://www.v2ex.com%@", result];
                self.requestURL = url;
                
                [self generalRequest];
            }
        }
    } failure:^(NSError *error) {
        [self requestError:error];
    } type:HTTP_GET];
    
    return YES;
}

- (BOOL)requestSiteStats {
    self.requestURL = SiteApiUrl;
    self.requestParam = @{@"webserviceType":@(SiteStats_ServiceType)};
    
    [self generalRequest];
    
    return YES;
}

- (BOOL)requestSiteInfor {
    self.requestURL = InfoApiUrl;
    self.requestParam = @{@"webserviceType":@(SiteInfor_ServiceType)};
    
    [self generalRequest];
    
    return YES;
}

- (BOOL)requestAllNodes {
    self.requestURL = NodesApiUrl;
    self.requestParam = @{@"webserviceType":@(AllNode_ServiceType)};
    
    [self generalRequest];
    
    return YES;
}

- (BOOL)requestNodeInforByID:(NSString *)nodeId {
    self.requestURL = ShowNodeApiUrl;
    self.requestParam = @{@"webserviceType":@(NodeInfor_ServiceType), @"nodeId":nodeId};
    
    NSDictionary *param = @{@"id":nodeId};
    [self requestUrl:ShowNodeApiUrl param:param];
    
    return YES;
}

- (BOOL)requestNodeInforByName:(NSString *)nodeName {
    self.requestURL = ShowNodeApiUrl;
    self.requestParam = @{@"webserviceType":@(NodeInfor_ServiceType), @"nodeName":nodeName};
    
    NSDictionary *param = @{@"name":nodeName};
    [self requestUrl:ShowNodeApiUrl param:param];
    return YES;
}

- (BOOL)requestLatestTopic {
    self.requestURL = LatestTopicsApiUrl;
    self.requestParam = @{@"webserviceType": @(LatestTopic_ServiceType)};
    
    [self requestUrl:self.requestURL];
    return YES;
}

- (BOOL)requestTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit {
    self.htmlApi = YES;
    self.requestURL = nodeUrl;
    
    NSString *nodeName = [nodeUrl lastPathComponent];
    self.requestParam = @{@"webserviceType":@(TopicList_ServiceType), @"nodeName":nodeName, @"p":page, @"limit":limit};
    
    NSDictionary *param = @{@"p":page};
    [self requestUrl:nodeUrl param:param];
    
    return YES;
}

- (BOOL)requestTopicDetail:(NSString *)topicId {
    self.requestURL = ShowTopicApiUrl;
    self.requestParam = @{@"webserviceType": @(TopicDetail_ServiceType), @"topicId":topicId};
    
    NSDictionary *param = @{@"id":topicId};
    [self requestUrl:self.requestURL param:param];
    return YES;
}

- (BOOL)requestTopicReplay:(NSString *)topicId {
    self.requestURL = ShowTopicReplayApiUrl;
    self.requestParam = @{@"webserviceType": @(TopicReplies_ServiceType), @"topicId":topicId};
    
    NSDictionary *param = @{@"topic_id":topicId};
    [self requestUrl:self.requestURL param:param];
    return YES;
}

- (BOOL)requestMemberInforById:(NSString *)userId {
    self.requestURL = ShowMemberInforApiUrl;
    self.requestParam = @{@"webserviceType": @(UserInfor_ServiceType)};
    
    NSDictionary *param = @{@"id":userId};
    [self requestUrl:self.requestURL param:param];
    return YES;
}

- (BOOL)requestMemberInforByName:(NSString *)username {
    self.requestURL = ShowMemberInforApiUrl;
    self.requestParam = @{@"webserviceType": @(UserInfor_ServiceType)};
    
    NSDictionary *param = @{@"username":username};
    [self requestUrl:self.requestURL param:param];
    return YES;
}


//创建主题
- (BOOL)createTopic:(NSString *)topicTitle toNode:(NSString *)nodeName content:(NSString *)content {
    assert(topicTitle);
    assert(nodeName);
    assert(content);
    
    self.htmlApi = YES;
    self.requestURL = [NSString stringWithFormat:@"%@/new/%@", NetServerUrl, nodeName];
    self.requestParam = @{@"webserviceType": @(CreateTopic_ServiceType), @"nodeName": nodeName, @"c": content, @"t": topicTitle};
    
    __weak __typeof(self)weakSelf = self;
    [self.manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        NSInteger statusCode = r.statusCode;
        if (statusCode == 302) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            NSString *url = strongSelf.requestURL;
            
//            NSDictionary *fields = [r allHeaderFields];
//            NSString *location = [fields valueForKey:@"Location"];
            
            NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieJar cookies]];
            
            NSMutableURLRequest *req1 = [NSMutableURLRequest requestWithURL:[request URL]];
            [req1 setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
            [req1 setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
            [req1 setValue:@"Accept-Language" forHTTPHeaderField:@"en-US,en;q=0.8,zh-CN;q=0.6"];
            [req1 setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
            [req1 setValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
            [req1 setValue:url forHTTPHeaderField:@"Referer"];
            [req1 setValue:@"v2ex.com" forHTTPHeaderField:@"Host"];
            [req1 setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.137 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
            
            return req1;
        }
        return request;
    }];

    
    [self request:self.requestURL param:nil success:^(id responseObject) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRange range = [html rangeOfString:@"<input type=\"hidden\" value=\"(\\d+)\" name=\"once\" />" options:NSRegularExpressionSearch];
        NSString *s1 = [html substringWithRange:range];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *arr = [regex matchesInString:s1 options:NSMatchingReportProgress range:NSMakeRange(0, s1.length)];
        NSTextCheckingResult *result = [arr count] > 0 ? arr[0] : nil;
        NSString *once = [s1 substringWithRange:result.range];
        
        NSDictionary *postDict = @{@"title":topicTitle, @"content": content, @"once":once};

        [self request:self.requestURL param:postDict success:^(id responseObject) {
            self.responseObj = responseObject;
            [self requestSuccess];
        } failure:^(NSError *error) {
            [self requestError:error];
        } type:HTTP_POST];
        
    } failure:^(NSError *error) {
        [self requestError:error];
    } type:HTTP_GET];
    
    return YES;
}

- (BOOL)replyTopic:(NSString *)topicId content:(NSString *)content {
    assert(topicId);
    assert(content);
    
    self.htmlApi = YES;
    self.requestURL = [NSString stringWithFormat:@"%@/t/%@", NetServerUrl, topicId];
    self.requestParam = @{@"webserviceType": @(ReplyTopic_ServiceType), @"topicId": topicId, @"content": content};
    
    [self request:self.requestURL param:nil success:^(id responseObject) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRange range = [html rangeOfString:@"<input type=\"hidden\" value=\"(\\d+)\" name=\"once\" />" options:NSRegularExpressionSearch];
        NSString *s1 = [html substringWithRange:range];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *arr = [regex matchesInString:s1 options:NSMatchingReportProgress range:NSMakeRange(0, s1.length)];
        NSTextCheckingResult *result = [arr count] > 0 ? arr[0] : nil;
        NSString *once = [s1 substringWithRange:result.range];
        
        NSDictionary *postDict = @{@"content": content, @"once":once};
        
        [self request:self.requestURL param:postDict success:^(id responseObject) {
            self.responseObj = responseObject;
            [self requestSuccess];
        } failure:^(NSError *error) {
            [self requestError:error];
        } type:HTTP_POST];
    } failure:^(NSError *error) {
        [self requestError:error];
    } type:HTTP_GET];
    
    return YES;
}

#pragma mark - Backend Server
- (BOOL)registerToken:(NSString *)token {
    assert(token);
    
    NSString *formatStr = BackendServer@"/api/register?token=%@";
    self.requestURL = [NSString stringWithFormat:formatStr, token];

    self.requestParam = @{@"webserviceType": @(RegisterUser_ServiceType)};
    
    [self generalRequest];
    
    return YES;
}

- (BOOL)updatePushSetting:(NSNumber *)type token:(NSString *)token filter:(NSString *)careWord {
    assert(token);
    assert(careWord);
    
    NSString *formatStr = BackendServer@"/api/pushSetting?token=%@&careWord=%@&pushType=%@";
    self.requestURL = [NSString stringWithFormat:formatStr, token, careWord, type];
    self.requestParam = @{@"webserviceType": @(PushSettingUpdate_ServiceType), @"w": careWord, @"t": type};
    
    [self generalRequest];
    
    return YES;
}

- (BOOL)updateStatus:(NSString *)token status:(NSNumber *)status {
    
    
    NSString *formatStr = BackendServer@"/api/onOffLine?token=%@&onOffLine=%@";
    self.requestURL = [NSString stringWithFormat:formatStr, token, status];
    self.requestParam = @{@"webserviceType": @(RegisterUser_ServiceType)};
    self.hideLoadingView = YES;
    
    [self generalRequest];
    
    return YES;
}

- (BOOL)requestClientConfig {
    self.requestURL = BackendServer@"/api/clientSetting";
    self.requestParam = @{@"webserviceType": @(ClientConfig_ServiceType)};
    
    [self generalRequest];
    return YES;
}

- (BOOL)resetData:(NSString *)token {
    assert(token);
    NSString *formatStr = BackendServer"/api/clientReset?token=%@";
    self.requestURL = [NSString stringWithFormat:formatStr, token];
    self.requestParam = @{@"webserviceType": @(ClientReset_ServiceType)};
    
    [self generalRequest];
    return YES;
}

#pragma mark - RefreshMoney
- (NSData *)refreshMoney {
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieJar cookies]];
    
    NSURL *u = [NSURL URLWithString:@"http://v2ex.com/ajax/money"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:u];
    [req addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.137 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req addValue:@"www.v2ex.com" forHTTPHeaderField:@"Host"];
    [req addValue:@"http://www.v2ex.com" forHTTPHeaderField:@"Origin"];
    [req addValue:@"http://v2ex.com/mission/daily" forHTTPHeaderField:@"Referer"];
    [req addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [req addValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    [req setHTTPMethod:@"POST"];
    [req setValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:&error];
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:&error];
//    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return data;
}

#pragma mark - Request End
- (void)requestError:(NSError *)error {
    [super requestError:error];
    
    if ([self.delegate respondsToSelector:@selector(netModel:didFailedWithError:)]) {
        [self.delegate netModel:self didFailedWithError:error];
    }
}

- (void)requestSuccess {
    [super requestSuccess];
    
    //cache response data
    [self updateCacheData];
    [self updateMemoryData];
    
    if ([self.delegate respondsToSelector:@selector(netModel:didFinishWithData:)]) {
        [self.delegate netModel:self didFinishWithData:self.responseObj];
    }
}
//
//- (void)startOneRequest {
//    requestingCount++;
//}
//
//- (void)finishOneRequest {
//    requestingCount--;
//}

- (NSString *)parseTopicToken {
    NSString *html = [[NSString alloc] initWithData:self.responseObj encoding:NSUTF8StringEncoding];
    NSString *parten = @"(?<=csrfToken = \").*(?=\")";
    
    NSError* error = NULL;
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
    NSTextCheckingResult *firstMatch=[reg firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
    
    if (firstMatch) {
        NSRange resultRange = [firstMatch rangeAtIndex:0];
        NSString *csrfToken = [html substringWithRange:resultRange];
        
        return csrfToken;
    }
    
    return nil;
}



#pragma mark - Cache Response

- (void)updateCacheData {
    NSInteger webserviceType = [_requestParam[@"webserviceType"] integerValue];
    switch (webserviceType) {
        case Login_ServiceType:
        {
            
            //Save last login username;
            NSString *userName = _requestParam[@"u"];
            if (userName) {
                NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
                [dfs setObject:userName forKey:UserNameKey];
                [dfs synchronize];
            }
        }
            break;
        case Logout_ServiceType:
            break;
        case SiteInfor_ServiceType:
            [FileUtil save:self.responseObj toFile:@"info.json"];
            break;
        case SiteStats_ServiceType:
            [FileUtil save:self.responseObj toFile:@"stats.json"];
            break;
        case ClientConfig_ServiceType:
            [FileUtil save:self.responseObj toFile:@"config.json"];
            break;
        case AllNode_ServiceType:
            [DBUtil saveAllNode:self.responseObj];
            [DBUtil updateLastModify:self.webServiceIdentifier];
            break;
        case TopicList_ServiceType:
            [DBUtil saveTopics:self.responseObj toNode:_requestParam[@"nodeName"]];
            [DBUtil updateLastModify:self.webServiceIdentifier];
            break;
        case LatestTopic_ServiceType:
            [DBUtil saveLatestTopic:self.responseObj];
            [DBUtil updateLastModify:self.webServiceIdentifier];
            break;
        case NodeInfor_ServiceType:
            [DBUtil saveOneNode:self.responseObj];
            break;
        case TopicDetail_ServiceType:
            [DBUtil saveTopicDetail:self.responseObj];
            break;
        case TopicReplies_ServiceType:
            [DBUtil saveTopicReplies:self.responseObj toTopic:_requestParam[@"topicId"]];
            break;
        case UserInfor_ServiceType:
            [DBUtil saveUserGeneralInfor:self.responseObj];
            break;
        case CreateTopic_ServiceType:
        {
            NSString *lastPathComponent = [[[self.response URL] absoluteString] lastPathComponent];
            NSRange range = [lastPathComponent rangeOfString:@"#"];
            if (range.location != NSNotFound) {
                
                NSInteger location = range.location;
                NSString *topicId = [lastPathComponent substringToIndex:location];
                if (topicId) {
                    
                    DBTopic *obj = [DBUtil loadTopicFromDBById:topicId];
                    assert(obj);
                    
                    obj.nodeName = _requestParam[@"nodeName"];
                    obj.cacheDate = [NSDate date];
                    obj.topicAuthorImgUrl = [MemShared sharedInstance].user.avatar_m;
                    obj.topicId = topicId;
                    obj.topicRepliesCount = @"0";
                    obj.topicTitle = _requestParam[@"t"];
                    obj.topicUrl = [[self.response URL] absoluteString];
                    obj.topicAuthorName = [MemShared sharedInstance].user.userName;
                    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                    obj.topicCreated = [NSString stringWithFormat:@"%f", interval];
                    [obj save];
                    
                    NSData *moneyData = [self refreshMoney];
                    [DBUtil createTopic:topicId money:moneyData];
                }
            }
        }
            break;
        case ReplyTopic_ServiceType:
        {
//            NSString *content = _requestParam[@"content"];
//            NSString *topicId = _requestParam[@"topicId"];
//            NSData *moneyData = [self refreshMoney];
//            [DBUtil replyTopic:topicId content:content money:moneyData];
        }
            break;
        case PushSettingUpdate_ServiceType:
        {
            NSNumber *pushType = _requestParam[@"t"];
            NSString *careWord = _requestParam[@"w"];
            [DBUtil updatePushSetting:pushType filter:careWord];
        }
            break;
        default:
            break;
    }
}

- (void)updateMemoryData {
    NSInteger webserviceType = [_requestParam[@"webserviceType"] integerValue];
    switch (webserviceType) {
        case Login_ServiceType:
            
            break;
        case Logout_ServiceType:
            [[MemShared sharedInstance] logout];
            break;
        case SiteInfor_ServiceType:
            break;
        case SiteStats_ServiceType:
            break;
        case AllNode_ServiceType:
            self.responseObj = [DBUtil memDataFromDB:[DBNode all] tableName:@"DBNode"];
            break;
        case TopicList_ServiceType:
        {
            NSNumber *limit = _requestParam[@"limit"];
            NSInteger page = [_requestParam[@"p"] integerValue];
            NSString *nodeName = _requestParam[@"nodeName"];
            NSString *condition = [NSString stringWithFormat:@"nodeName == '%@'", nodeName];
            NSNumber *offset = @((page - 1) * 20);
            NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"topicCreated" ascending:NO];
            self.responseObj = [DBUtil memDataFromDB:[DBTopic where:condition offset:offset order:sortByTime limit:limit] tableName:@"DBTopic"];
        }
            break;
        case LatestTopic_ServiceType:
        {
            NSString *condition = [NSString stringWithFormat:@"type == '%lu'", (unsigned long)Latest_Topic_Type];
            self.responseObj = [DBUtil memDataFromDB:[DBTopic where:condition] tableName:@"DBTopic"];
        }
            break;
        case NodeInfor_ServiceType:
        {
            NSString *nodeId = _requestParam[@"nodeId"];
            NSString *nodeName = _requestParam[@"nodeName"];
            id condition = nil;
            if (nodeId) {
                condition = @{@"nodeId":nodeId};
            }
            else if (nodeName) {
                condition = @{@"nodeName": nodeName};
            }
            if (condition) {
                self.responseObj = [DBUtil memDataFromDB:[DBNode where:condition] tableName:@"DBNode"];
            }
            else {
                self.responseObj = nil;
            }
        }
            break;
        case TopicDetail_ServiceType:
        case TopicReplies_ServiceType:
        {
            id condition = @{@"topicId": _requestParam[@"topicId"]};
            self.responseObj = [DBUtil memDataFromDB:[DBTopic where:condition] tableName:@"DBTopic"][0];
        }
            break;
        case UserInfor_ServiceType:
        {
            NSString *userName = [MemUtil userName];
            assert(userName);
            id condition = @{@"userName": userName};
            self.responseObj = [DBUtil memDataFromDB:[DBUser where:condition] tableName:@"DBUser"];
        }
            break;
        case CreateTopic_ServiceType:
            [MemUtil updateUser];
            break;
        case ReplyTopic_ServiceType:
        {
//            NSString *topicId = _requestParam[@"topicId"];
//            id condition = @{@"topicId": topicId};
//            NSArray *results = [DBTopic where:condition];
//            self.responseObj = [[[results rac_sequence] map:^id(id value) {
//                MemReply *oneReply = [MTLJSONAdapter modelOfClass:[MemReply class] fromJSONDictionary:value error:nil];
//                return oneReply;
//            }] array];
////            self.responseObj = [DBUtil memDataFromDB:[DBTopic where:condition] tableName:@"DBTopic"][0];
//            [MemUtil updateUser];
        }
            break;
        default:
            break;
    }
}

#pragma mark - FRP


- (RACSignal *)fetchAllNodes {
    self.requestURL = NodesApiUrl;
    self.requestParam = @{@"webserviceType":@(AllNode_ServiceType)};
    @weakify(self);
    RACSignal *signal = [[[[self fetchWithAFSessionUrl:self.requestURL param:nil type:HTTP_GET] doNext:^(id x) {
        //Delete old from DB
        NSArray *nodes = [DBNode all];
        for (DBNode *node in nodes) {
            [node delete];
        }
        [[CoreDataManager sharedManager] saveContext];
    }] map:^id(id value) {
        return [[[value rac_sequence] map:^id(id value) {
            MemNode *oneNode = [MTLJSONAdapter modelOfClass:[MemNode class] fromJSONDictionary:value error:nil];
            
            //Update to db
            [DBUtil updateOrInsertNode:oneNode];
            
            return oneNode;
        }] array];
    }] doNext:^(id x) {
        //update cache date
        @strongify(self);
        [DBUtil updateLastModify:self.webServiceIdentifier];
    }];
    return signal;
}

- (RACSignal *)fetchNodeByID:(NSString *)nodeId {
    self.requestURL = ShowNodeApiUrl;
    self.requestParam = @{@"webserviceType":@(NodeInfor_ServiceType), @"nodeId":nodeId};
    NSDictionary *param = @{@"id":nodeId};
    return [[self fetchWithAFOperationUrl:self.requestURL param:param type:HTTP_GET] map:^id(id value) {
        MemNode *oneNode = [MTLJSONAdapter modelOfClass:[MemNode class] fromJSONDictionary:value error:nil];
        //Update or insert to DB
        [DBUtil updateOrInsertNode:oneNode];
        return oneNode;
    }];
}

- (RACSignal *)fetchNodeByName:(NSString *)nodeName {
    self.requestURL = ShowNodeApiUrl;
    self.requestParam = @{@"webserviceType":@(NodeInfor_ServiceType), @"nodeName":nodeName};
    NSDictionary *param = @{@"name":nodeName};
    return [[self fetchWithAFOperationUrl:self.requestURL param:param type:HTTP_GET] map:^id(id value) {
        MemNode *oneNode = [MTLJSONAdapter modelOfClass:[MemNode class] fromJSONDictionary:value error:nil];
        //Update or insert to DB
        [DBUtil updateOrInsertNode:oneNode];
        return oneNode;
    }];
}

- (RACSignal *)fetchLatestTopics {
    self.requestURL = LatestTopicsApiUrl;
    self.requestParam = @{@"webserviceType": @(LatestTopic_ServiceType)};
    
    return [[self fetchWithAFOperationUrl:self.requestURL param:nil type:HTTP_GET] map:^id(id value) {
        return [[[value rac_sequence] map:^id(id value) {
            MemTopic *oneTopic = [MTLJSONAdapter modelOfClass:[MemTopic class] fromJSONDictionary:value error:nil];
            
            return oneTopic;
        }] array];
    }];
}

- (RACSignal *)fetchTopics:(NSString *)nodeUrl page:(NSNumber *)page limit:(NSNumber *)limit {
    self.htmlApi = YES;
    self.requestURL = nodeUrl;
    
    NSString *nodeName = [nodeUrl lastPathComponent];
    self.requestParam = @{@"webserviceType":@(TopicList_ServiceType), @"nodeName":nodeName, @"p":page, @"limit":limit};
    
    return [[self fetchWithAFOperationUrl:self.requestURL param:@{@"p":page} type:HTTP_GET] map:^id(id value) {
        
        //Delete old from DB
        if (self.requestPolicy == RequestReloadIgnoringCacheData) {
            NSArray *topics = [DBTopic where:@{@"nodeName": nodeName}];
            for (DBTopic *topic in topics) {
                [topic delete];
            }
            [[CoreDataManager sharedManager] saveContext];
        }
        
        NSInteger responseCount = [DBUtil saveTopics:value toNode:_requestParam[@"nodeName"]];
        [DBUtil updateLastModify:self.webServiceIdentifier];
        
        responseCount += ([page integerValue] - 1) * 20;
        NSString *condition = [NSString stringWithFormat:@"nodeName == '%@'", nodeName];
        NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"topicCreated" ascending:NO];
        
        NSArray *dbTopics = [DBTopic where:condition offset:nil order:sortByTime limit:@(responseCount)];
        return [[[dbTopics rac_sequence] map:^id(id value) {
            NSError *error = nil;
            id topic = [MTLManagedObjectAdapter modelOfClass:NSClassFromString(@"MemTopic") fromManagedObject:value error:&error];
            return topic;
        }] array];
    }];
}

//请求主题回复列表  ShowTopicReplayApiUrl
- (RACSignal *)fetchTopicDetail:(NSString *)topicId {
    
    self.requestURL = ShowTopicApiUrl;
    self.requestParam = @{@"webserviceType": @(TopicDetail_ServiceType), @"topicId":topicId};
    @weakify(self);
    return [[[self fetchWithAFOperationUrl:self.requestURL param:@{@"id":topicId} type:HTTP_GET] map:^id(id value) {
        if ([value count] > 0) {
            DBTopic *topic = [DBUtil loadTopicFromDBById:topicId];
            MemTopic *oneTopic = [MTLJSONAdapter modelOfClass:[MemTopic class] fromJSONDictionary:value[0] error:nil];
            oneTopic.readed = [NSNumber numberWithBool:YES];
            oneTopic.nodeName = [topic.nodeName copy];
            [DBUtil updateOrInsertTopic:oneTopic];
            return oneTopic;
            
        }
        return nil;
    }] doNext:^(id x) {
        @strongify(self);
        [DBUtil updateLastModify:self.webServiceIdentifier];
    }];
}

- (RACSignal *)fetchTopicReplay:(NSString *)topicId {
    self.requestURL = ShowTopicReplayApiUrl;
    self.requestParam = @{@"webserviceType": @(TopicReplies_ServiceType), @"topicId":topicId};
    
    @weakify(self);
    return [[[self fetchWithAFOperationUrl:self.requestURL param:@{@"topic_id":topicId} type:HTTP_GET] map:^id(id value) {
        return [[[value rac_sequence] map:^id(id value) {
            MemReply *oneReply = [MTLJSONAdapter modelOfClass:[MemReply class] fromJSONDictionary:value error:nil];
            return oneReply;
        }] array];
    }] doNext:^(id x) {
        @strongify(self);
        DBTopic *topic = [DBUtil loadTopicFromDBById:topicId];
        assert(topic);
        for (DBReply *reply in topic.replies) {
            [reply delete];
        }
        topic.replies = nil;
        
        NSMutableArray *replies = [NSMutableArray new];
        for (MemReply *reply in x) {
            NSError *error = nil;
            reply.topicId = topicId;
            NSManagedObject *managedObject = [MTLManagedObjectAdapter managedObjectFromModel:reply insertingIntoContext:[[CoreDataManager sharedManager] managedObjectContext] error:&error];
            [replies addObject:managedObject];
        }
        topic.replies = [NSSet setWithArray:replies];
        
        [[CoreDataManager sharedManager] saveContext];
        
        [DBUtil updateLastModify:self.webServiceIdentifier];
    }];

}

//请求个人资料  ShowMemberInforApiUrl
- (RACSignal *)fetchMemberInforById:(NSString *)userId {
    self.requestURL = ShowMemberInforApiUrl;
    self.requestParam = @{@"webserviceType": @(UserInfor_ServiceType)};
    NSDictionary *param = @{@"id":userId};
    
    return [[self fetchWithAFOperationUrl:self.requestURL param:param type:HTTP_GET] map:^id(id value) {
        return nil;
    }];
}

//请求个人资料  ShowMemberInforApiUrl
- (RACSignal *)fetchMemberInforByName:(NSString *)username {
    self.requestURL = ShowMemberInforApiUrl;
    self.requestParam = @{@"webserviceType": @(UserInfor_ServiceType)};
    NSDictionary *param = @{@"username":username};
    return [[self fetchWithAFOperationUrl:self.requestURL param:param type:HTTP_GET] map:^id(id value) {
        return nil;
    }];
}


//与后台服务器通信
- (RACSignal *)registerPush:(NSString *)token {
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [BmobCloud callFunctionInBackground:@"registerPush" withParameters:@{@"token": token} block:^(id object, NSError *error) {
            if (error) {
                
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }] ;
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
}

- (RACSignal *)updatePush:(NSString *)pushSlot token:(NSString *)token {
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [BmobCloud callFunctionInBackground:@"updatePush" withParameters:@{@"pushSlot": pushSlot, @"token": token} block:^(id object, NSError *error) {
            if (error) {
                
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }] ;
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
}

- (RACSignal *)updateOnline:(NSString *)online token:(NSString *)token {
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [BmobCloud callFunctionInBackground:@"updateOnline" withParameters:@{@"online": online, @"token": token} block:^(id object, NSError *error) {
            if (error) {
                
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }] ;
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
}

//服务器对客户端的一些配置，如正式iap地址
- (RACSignal *)fetchClientConfig {
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [BmobCloud callFunctionInBackground:@"clientConfig" withParameters:nil block:^(id object, NSError *error) {
            if (error) {
                
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }] ;
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
}

- (RACSignal *)resetPush:(NSString *)token {
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [BmobCloud callFunctionInBackground:@"resetPush" withParameters:@{@"token": token} block:^(id object, NSError *error) {
            if (error) {
                
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }] ;
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
}

@end
