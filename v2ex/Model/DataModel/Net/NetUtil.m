//
//  NetClient.m
//  v2ex
//
//  Created by Haven on 10/5/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NetUtil.h"
#import "NetHTTPRequestSerializer.h"
#import "Utils.h"

@implementation NetUtil

static NSInteger requestingCount = 0;

- (id)init {
    self = [super init];
    if (self) {
        self.manager = [AFHTTPSessionManager manager];
    }
    
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Property
- (void)setRequestURL:(NSString *)requestURL {
    _requestURL = requestURL;
    [self setupRequestSerializer];
}

- (void)setHtmlApi:(BOOL)htmlApi {
    _htmlApi = htmlApi;
    if (_htmlApi) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        [responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
        _manager.responseSerializer = responseSerializer;
    }
}

- (BOOL)setupRequestSerializer {
    
    NetHTTPRequestSerializer *requestSerializer = [NetHTTPRequestSerializer serializer];
    if (_htmlApi) {
        [requestSerializer setValue:@"Safari" forHTTPHeaderField:@"User-Agent"];
    }
    else {
        [requestSerializer setValue:UseriOSAgent forHTTPHeaderField:@"User-Agent"];
    }
    _requestURL ? [requestSerializer setValue:_requestURL forHTTPHeaderField:@"Referer"] : nil;
    [_manager setRequestSerializer:requestSerializer];
    
    return YES;
}


#pragma mark - Private
- (NSTimeInterval)checkRequestTime {
    return Request_Time_Interval * requestingCount;
}

#pragma mark - Request Way 1
- (void)generalRequest {
    [self request:_requestURL param:nil success:^(id responseObject) {
        self.responseObj = responseObject;
        [self requestSuccess];
    } failure:^(NSError *error) {
        [self requestError:error];
    } type:HTTP_GET];
}

- (void)generalRequestWithParam:(NSDictionary *)param {
    [self request:_requestURL param:param success:^(id responseObject) {
        self.responseObj = responseObject;
        [self requestSuccess];
    } failure:^(NSError *error) {
        [self requestError:error];
    } type:HTTP_GET];
}

- (void)request:(NSString *)url param:(NSDictionary *)param success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure type:(HTTPType)type {
    //config request interval
    NSTimeInterval interval = [self checkRequestTime];
    if (interval > 0) {
        NSLog(@"Need delay %f second to request.", interval);
        double delayInSeconds = interval;
        __weak typeof (self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf request:url param:param success:success failure:failure type:type];
        });
    }
    else {
        [self startOneRequest];
        switch (type) {
            case HTTP_GET:
                [self get:url param:param success:success failure:failure];
                break;
            case HTTP_POST:
                [self post:url param:param success:success failure:failure];
                break;
            default:
                break;
        }
    }
}

- (void)post:(NSString *)url param:(NSDictionary *)param success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure {
    self.task = [_manager POST:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        self.response = (NSHTTPURLResponse *)task.response;
        [self finishOneRequest];
        
        self.responseObj = responseObject;
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
        [self finishOneRequest];
    }];
}

- (void)get:(NSString *)url param:(NSDictionary *)param success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure {
    self.task = [_manager GET:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        self.response = (NSHTTPURLResponse *)task.response;
        [self finishOneRequest];
        self.responseObj = responseObject;
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
        [self finishOneRequest];
    }];
}

#pragma mark - Request Way 2
- (void)request:(NSURLRequest *)r {
    [self startOneRequest];
    __weak typeof (self) weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:r];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.response = operation.response;
        // code
        @try {
            if (_htmlApi) {
                weakSelf.responseObj = responseObject;
                [weakSelf requestSuccess];
            }
            else {
                NSError *error = nil;
                weakSelf.responseObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
                if (error) {
                    [weakSelf requestError:error];
                }
                else {
                    [weakSelf requestSuccess];
                }
            }
        }
        @catch (NSException *exception) {
            [weakSelf requestError:nil];
        }
        
        [self finishOneRequest];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf requestError:error];
        [self finishOneRequest];
    }
     ];
    [operation start];
}

- (void)request:(NSURLRequest *)r success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    
    [self startOneRequest];
    __weak typeof (self) weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:r];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.response = operation.response;
        // code
        @try {
            if (_htmlApi) {
                weakSelf.responseObj = responseObject;
            }
            else {
                NSError *error = nil;
                weakSelf.responseObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            }
            
            
            success(weakSelf.responseObj);
        }
        @catch (NSException *exception) {
            [weakSelf requestError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }
     ];
    [operation start];
}

- (void)requestWithCheckFrequency:(NSURLRequest *)r success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    //config request interval
    NSTimeInterval interval = [self checkRequestTime];
    if (interval > 0) {
        NSLog(@"Need delay %f second to request.", interval);
        double delayInSeconds = interval;
        __weak typeof (self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf request:r success:success failure:failure];
        });
    }
    else {
        [self request:r success:success failure:failure];
    }
}

- (void)requestUrl:(NSString *)urlStr param:(NSDictionary *)param {
    
    //config request param
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *paramString = nil;
    if (param) {
        NSMutableString *str = [NSMutableString new];
        NSEnumerator *enumerator = [param keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            [str appendFormat:@"%@=%@", key, [param objectForKey:key]];
        }
        paramString = str;
    }
    if ([paramString length] > 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlStr, paramString]];
    }
    NSDictionary *headers = [Utils getCookies];
    NSMutableURLRequest *r = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [r addValue:@"Safari" forHTTPHeaderField:@"User-Agent"];
    [r setValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
//    [r addValue:urlStr forHTTPHeaderField:@"Referer"];
    [r addValue:@"v2ex.com" forHTTPHeaderField:@"Host"];
    
    //config request interval
    NSTimeInterval interval = [self checkRequestTime];
    if (interval > 0) {
        NSLog(@"Need delay %f second to request.", interval);
        double delayInSeconds = interval;
        __weak typeof (self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf request:r];
        });
    }
    else {
        [self request:r];
    }
}

- (void)requestUrl:(NSString *)urlStr {
    [self requestUrl:urlStr param:nil];
}

#pragma mark - Request End
- (void)requestError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(netUtil:didFailedWithError:)]) {
        [_delegate netUtil:self didFailedWithError:error];
    }
}

- (void)requestSuccess {
    
    if ([_delegate respondsToSelector:@selector(netUtil:didFinishLoadingWithResponse:)]) {
        [_delegate netUtil:self didFinishLoadingWithResponse:_responseObj];
    }
}

- (void)startOneRequest {
    if (!_hideLoadingView) {
        
        [NetHelper setNetworkActivityIndicatorVisible:YES];
        requestingCount++;
        NSLog(@"start net request count= %ld", (long)requestingCount);
    }
}

- (void)finishOneRequest {
    if (!_hideLoadingView) {
        [NetHelper setNetworkActivityIndicatorVisible:NO];
        requestingCount--;
        NSLog(@"end net request count= %ld", (long)requestingCount);
    }
}

#pragma mark - FRP
//way 1
- (RACSignal *)fetchWithAFSessionUrl:(NSString *)urlString param:(NSDictionary *)param type:(HTTPType)type {
    @weakify(self);
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self request:urlString param:param success:^(id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        } type:type];
        
        @weakify(self);
        return [RACDisposable disposableWithBlock:^{
            @strongify(self);
            [self.task cancel];
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
    
}

//way2
- (RACSignal *)fetchWithAFOperationUrl:(NSString *)urlString param:(NSDictionary *)param type:(HTTPType)type {
    @weakify(self);
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSString *paramString = nil;
        if (param) {
            NSMutableString *str = [NSMutableString new];
            NSEnumerator *enumerator = [param keyEnumerator];
            id key;
            while ((key = [enumerator nextObject])) {
                [str appendFormat:@"%@=%@", key, [param objectForKey:key]];
            }
            paramString = str;
        }
        if ([paramString length] > 0) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramString]];
        }
        NSDictionary *headers = [Utils getCookies];
        NSMutableURLRequest *r = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        [r addValue:@"Safari" forHTTPHeaderField:@"User-Agent"];
        [r setValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        [r addValue:@"v2ex.com" forHTTPHeaderField:@"Host"];
        
        @weakify(self);
        [self requestWithCheckFrequency:r success:^(id responseObject) {
            @strongify(self);
            [self finishOneRequest];
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            @strongify(self);
            [self finishOneRequest];
            [subscriber sendError:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }] deliverOn:[RACScheduler mainThreadScheduler]] publish] autoconnect];
}


@end
