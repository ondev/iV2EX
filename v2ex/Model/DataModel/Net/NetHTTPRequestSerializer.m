//
//  NetHTTPRequestSerializer.m
//  v2ex
//
//  Created by Haven on 4/30/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NetHTTPRequestSerializer.h"

@implementation NetHTTPRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:headers];
    [request setTimeoutInterval:10];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    return request;
}
@end
