//
//  NSString+Ext.m
//  v2ex
//
//  Created by Haven on 18/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NSString+Ext.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Ext)
- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font {
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        expectedLabelSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    else {
        expectedLabelSize = [self sizeWithFont:font
                                       constrainedToSize:size
                                           lineBreakMode:NSLineBreakByWordWrapping];
    }

    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}

- (NSString *)urlEncodedUTF8String {
    return (__bridge_transfer id)CFURLCreateStringByAddingPercentEscapes(0, (CFStringRef)self, 0,
                                                       (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8);
}

-(NSString*)stringByTrimmingLeadingWhitespace {
    NSInteger i = 0;
    
    while ((i < [self length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    return [self substringFromIndex:i];
}

- (NSString *)checkAvatarUrl {
    NSString *result = nil;
    if (([self rangeOfString:@"uxengine"].location == NSNotFound) && ([self rangeOfString:@"gravatar"].location == NSNotFound)) {
        
        result = [NSString stringWithFormat:@"http:%@", self];
    }
    else {
        result = @"http://cdn.v2ex.com/static/img/avatar_normal.png";
    }
    
    return result;
}

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
