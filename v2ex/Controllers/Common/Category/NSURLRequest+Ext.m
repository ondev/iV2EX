//
//  NSURLRequest+Ext.m
//  v2ex
//
//  Created by Haven City on 28/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NSURLRequest+Ext.h"
#import "NSString+Ext.h"
#import "Utils.h"

@implementation NSURLRequest (Ext)
+ (NSMutableURLRequest *)postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters {
    
    NSMutableString *body = [NSMutableString string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"Safari" forHTTPHeaderField:@"User-Agent"];
    
    for (NSString *key in parameters) {
        NSString *val = [parameters objectForKey:key];
        if ([body length])
            [body appendString:@"&"];
        [body appendFormat:@"%@=%@", [key urlEncodedUTF8String], [val urlEncodedUTF8String]];
    }
    
    NSData *postData = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    return request;
}

+ (NSData *)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] urlEncodedUTF8String];
        NSString *encodedKey = [key urlEncodedUTF8String];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSMutableURLRequest *)v2exPost:(NSString *)url  parameters:(NSDictionary *)parameters {
    
//    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSDictionary *h1 = [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieJar cookies]];
    
    NSDictionary *headers = [Utils getCookies];
    NSData *postData = [[self class] encodeDictionary:parameters];
    
    NSURL *u = [NSURL URLWithString:url];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:u];
    [req addValue:UseriOSAgent forHTTPHeaderField:@"User-Agent"];
    [req addValue:@"www.v2ex.com" forHTTPHeaderField:@"Host"];
    [req addValue:@"http://www.v2ex.com" forHTTPHeaderField:@"Origin"];
    [req addValue:url forHTTPHeaderField:@"Referer"];
    [req addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [req addValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    [req setHTTPMethod:@"POST"];
    [req setValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    [req setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:postData];
    
    return req;
}

+ (NSMutableURLRequest *)v2exGet:(NSString *)url {
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieJar cookies]];
    NSURL *u = [NSURL URLWithString:url];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:u];
    [req setValue:@"Safari" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"v2ex.com" forHTTPHeaderField:@"Host"];
//    [req setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
//    [req setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    [req setValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    
    return req;
}

//+ (NSMutableURLRequest *)v2exGet:(NSString *)url {
//    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieJar cookies]];
//    
////    NSDictionary *headers = [Utils getCookies];
//    NSURL *u = [NSURL URLWithString:url];
//    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:u];
//    [req setHTTPMethod:@"GET"];
//    [req addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//    [req addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
//    [req addValue:@"en-US,en;q=0.8,zh-CN;q=0.6" forHTTPHeaderField:@"Accept-Language"];
//    [req addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
//    [req addValue:[headers objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
//    [req addValue:@"v2ex.com" forHTTPHeaderField:@"Host"];
//    [req addValue:@"http://v2ex.com/mission/daily" forHTTPHeaderField:@"Referer"];
//    [req addValue:@"Safari" forHTTPHeaderField:@"User-Agent"];
////    [req addValue:@"http://www.v2ex.com" forHTTPHeaderField:@"Origin"];
////    [req addValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
//    
//    return req;
//}

@end
