//
//  NetClient.h
//  v2ex
//
//  Created by Haven on 10/5/14.
//  Copyright (c) 2014 LF. All rights reserved.
//
//http://hayageek.com/ios-nsurlsession-example/
//http://www.objc.io/issue-5/multitasking.html

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef NS_ENUM(NSInteger, HTTPType) {
    HTTP_GET,
    HTTP_POST
};

@class NetUtil;
@protocol NetUtilDelegate <NSObject>

- (void)netUtil:(NetUtil *)c didFinishLoadingWithResponse:(id)response;
- (void)netUtil:(NetUtil *)c didFailedWithError:(NSError *)error;

@end

@interface NetUtil : NSObject
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) id responseObj; //nsarray or nsdictionary or nsdata
@property (nonatomic) BOOL htmlApi;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, weak) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSString *requestURL;
@property (nonatomic) BOOL hideLoadingView;   //有些不需要显示loading view,  default is NO;

//way 1
- (void)generalRequest;
- (void)generalRequestWithParam:(NSDictionary *)param;
- (void)request:(NSString *)url param:(NSDictionary *)param success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure type:(HTTPType)type;

//way 2
- (void)request:(NSURLRequest *)r;
- (void)request:(NSURLRequest *)r success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)requestUrl:(NSString *)urlStr;
- (void)requestUrl:(NSString *)urlStr param:(NSDictionary *)param;

- (void)requestError:(NSError *)error;
- (void)requestSuccess;

//FRP
- (RACSignal *)fetchWithAFSessionUrl:(NSString *)urlString param:(NSDictionary *)param type:(HTTPType)type;
- (RACSignal *)fetchWithAFOperationUrl:(NSString *)urlString param:(NSDictionary *)param type:(HTTPType)type;
@end
