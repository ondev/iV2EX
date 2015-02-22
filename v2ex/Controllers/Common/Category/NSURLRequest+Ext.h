//
//  NSURLRequest+Ext.h
//  v2ex
//
//  Created by Haven City on 28/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Ext)
+ (NSMutableURLRequest *)postRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters;
+ (NSMutableURLRequest *)v2exPost:(NSString *)url  parameters:(NSDictionary *)parameters;
+ (NSMutableURLRequest *)v2exGet:(NSString *)url;
@end
