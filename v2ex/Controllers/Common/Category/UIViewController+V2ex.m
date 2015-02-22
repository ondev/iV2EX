//
//  UIViewController+V2ex.m
//  v2ex
//
//  Created by Haven on 4/11/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "UIViewController+V2ex.h"
#import <AFNetworking.h>
#import "NSURLRequest+Ext.h"
#import "NSString+Ext.h"
#import "UIAlertView+Blocks.h"
#import "Utils.h"
#import "IAPShare.h"
#import "UICKeyChainStore.h"
#import "UIAlertView+Blocks.h"
#import "PurchaseViewController.h"
#import "AppDelegate.h"
#import "MemShared.h"
#import "DBUtil.h"

extern NSString *ShowOrHideAds;

@implementation UIViewController (V2ex)
- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
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

//- (void)createTopic:(NSString *)title content:(NSString *)content toNodeURL:(NSString *)nodeURL {
//    //    http://v2ex.com/new/programmer
////    NSMutableURLRequest *req = [NSURLRequest v2exGet:@"http://v2ex.com/new/programmer"];
//    NSMutableURLRequest *req = [NSURLRequest v2exGet:nodeURL];
//    NSURLResponse *res = nil;
//    NSError *error = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
//    
//    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSRange range = [html rangeOfString:@"<input type=\"hidden\" value=\"(\\d+)\" name=\"once\" />" options:NSRegularExpressionSearch];
//    NSString *s1 = [html substringWithRange:range];
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray *arr = [regex matchesInString:s1 options:NSMatchingReportProgress range:NSMakeRange(0, s1.length)];
//    NSTextCheckingResult *result = [arr count] > 0 ? arr[0] : nil;
//    NSString *once = [s1 substringWithRange:result.range];
//    
//    NSDictionary *postDict = @{@"title":title, @"content": content, @"once":once};
//    NSMutableURLRequest *r = [NSURLRequest v2exPost:nodeURL parameters:postDict];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:r];
//    //    __weak typeof (self) weakSelf = self;
//    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
//        NSInteger statusCode = ((NSHTTPURLResponse *)redirectResponse).statusCode;
//        return request;
//    }];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
////        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSInteger statusCode = operation.response.statusCode;
//        if (statusCode == 200) {
//            [UIAlertView showWithTitle:nil message:@"发布成功" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if (buttonIndex == [alertView cancelButtonIndex]) {
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                }
//            }];
//            NSString *lastPathComponent = [[[operation.response URL] absoluteString] lastPathComponent];
//            NSRange range = [lastPathComponent rangeOfString:@"#"];
//            NSInteger location = range.location != NSNotFound ? range.location : lastPathComponent.length;
//            NSString *topicId = [lastPathComponent substringToIndex:location];
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error");
//    }
//     ];
//    [operation start];
//}
//
//- (void)replyTopic:(NSString *)content toTopicURL:(NSString *)topicURL {
//    NSMutableURLRequest *req = [NSURLRequest v2exGet:topicURL];
//    NSURLResponse *res = nil;
//    NSError *error = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
//    
//    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSRange range = [html rangeOfString:@"<input type=\"hidden\" value=\"(\\d+)\" name=\"once\" />" options:NSRegularExpressionSearch];
//    NSString *s1 = [html substringWithRange:range];
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray *arr = [regex matchesInString:s1 options:NSMatchingReportProgress range:NSMakeRange(0, s1.length)];
//    NSTextCheckingResult *result = [arr count] > 0 ? arr[0] : nil;
//    NSString *once = [s1 substringWithRange:result.range];
//    
//    NSDictionary *postDict = @{@"content": content, @"once":once};
//    NSMutableURLRequest *r = [NSURLRequest v2exPost:topicURL parameters:postDict];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:r];
//    //    __weak typeof (self) weakSelf = self;
//    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
//        NSInteger statusCode = ((NSHTTPURLResponse *)redirectResponse).statusCode;
//        return request;
//    }];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSInteger statusCode = operation.response.statusCode;
//        if (statusCode == 200) {
//            [UIAlertView showWithTitle:nil message:@"回复成功" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if (buttonIndex == [alertView cancelButtonIndex]) {
//                    [self dismissViewControllerAnimated:YES completion:nil];
//                }
//            }];
//            
//            NSString *lastPathComponent = [[[operation.response URL] absoluteString] lastPathComponent];
//            NSRange range = [lastPathComponent rangeOfString:@"#"];
//            NSInteger location = range.location != NSNotFound ? range.location : lastPathComponent.length;
//            NSString *topicId = [lastPathComponent substringToIndex:location];
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error");
//    }
//     ];
//    [operation start];
//}


//https://github.com/evands/iap_validation
//https://github.com/saturngod/IAPHelper
//http://blog.devtang.com/blog/2012/12/09/in-app-purchase-check-list/
//http://www.himigame.com/iphone-cocos2d/550.html
- (void)upgradeToFullVersion {
    [self startNetWork];
    
    [self initIAP];
    
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         if(response.products.count > 0 ) {
             SKProduct* product =[[IAPShare sharedHelper].iap.products objectAtIndex:0];
             
             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans){
                                            
                                            if(trans.error)
                                            {
                                                [self endNetWorkWithError:trans.error];
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                                                
                                                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                                                    // iOS 6.1 or earlier.
                                                    // Use SKPaymentTransaction's transactionReceipt.
                                                    
                                                } else {
                                                    // iOS 7 or later.
                                                    
                                                    NSURL *receiptFileURL = nil;
                                                    NSBundle *bundle = [NSBundle mainBundle];
                                                    if ([bundle respondsToSelector:@selector(appStoreReceiptURL)]) {
                                                        
                                                        // Get the transaction receipt file path location in the app bundle.
                                                        receiptFileURL = [bundle appStoreReceiptURL];
                                                        
                                                        // Read in the contents of the transaction file.
                                                        [NSData dataWithContentsOfURL:receiptFileURL];
                                                        
                                                    } else {
                                                        // Fall back to deprecated transaction receipt,
                                                        // which is still available in iOS 7.
                                                        
                                                        // Use SKPaymentTransaction's transactionReceipt.
                                                    }
                                                    
                                                }
                                                
                                                [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:@"4ee0276f8c8644f59d4e8186a1e3c778" onCompletion:^(NSString *response, NSError *error) {
                                                    
                                                    //Convert JSON String to NSDictionary
                                                    if (response) {
                                                        
                                                        NSDictionary* rec = [IAPShare toJSON:response];
                                                        
                                                        if([rec[@"status"] integerValue]==0)
                                                        {
                                                            NSString *productIdentifier = trans.payment.productIdentifier;
                                                            [[IAPShare sharedHelper].iap provideContent:productIdentifier];
                                                            //                                                        NSLog(@"SUCCESS %@",response);
                                                            //                                                        NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                                            [MemShared sharedInstance].fullVersion = YES;
                                                            [self savePurchase];
                                                            [self endNetWork];
                                                        }
                                                        else {
                                                            //                                                        NSLog(@"Fail");
                                                            [self endNetWorkWithNotify:@"验证票据失败"];
                                                        }
                                                    }
                                                    else {
                                                        [self endNetWorkWithNotify:@"验证接口错误,请切换到Sandbox接口"];
                                                    }
                                                }];
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStateFailed) {
//                                                NSLog(@"Fail");
                                                [self endNetWorkWithNotify:@"支付失败"];
                                            }
                                        }];//end of buy product
         }
     }];
}

- (void)restorePurchase {
    [self startNetWork];
    
    [self initIAP];
    
    [[IAPShare sharedHelper].iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        
        //check with SKPaymentQueue
        
        // number of restore count
//        int numberOfTransactions = payment.transactions.count;
        if (error) {
            [self endNetWorkWithError:error];
        }
        else {
            BOOL success = NO;
            for (SKPaymentTransaction *transaction in payment.transactions)
            {
                NSString *purchased = transaction.payment.productIdentifier;
                if([purchased isEqualToString:UpgradeIAPId])
                {
                    //enable the prodcut here
                    [MemShared sharedInstance].fullVersion = YES;
                    [self savePurchase];
                    success = YES;
                }
            }
            if (success) {
                [self endNetWork];
            }
            else {
                [self endNetWorkWithNotify:@"你从未购买过该产品，不能恢复，请购买!"];
            }
        }
        
    }];
}

- (void)initIAP {
    if(![IAPShare sharedHelper].iap) {
        NSSet* dataSet = [[NSSet alloc] initWithObjects:UpgradeIAPId, nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }

    if ([[MemShared sharedInstance].clientConfig[@"product"] isEqualToString:@"1"]) {
        [IAPShare sharedHelper].iap.production = YES;
    }
    else {
        [IAPShare sharedHelper].iap.production = NO;
    }
}

- (void)startNetWork {
    
    [NetHelper setNetworkActivityIndicatorVisible:YES];
}

- (void)endNetWork {
    
    [NetHelper setNetworkActivityIndicatorVisible:NO];
}

- (void)endNetWorkWithError:(NSError *)error {
    [self endNetWork];
    
    [UIAlertView showWithTitle:@"升级失败" message:[error localizedDescription] cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    }];
}

- (void)endNetWorkWithNotify:(NSString *)msg {
    [self endNetWork];
    
    [UIAlertView showWithTitle:@"升级失败" message:msg cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    }];
}

- (BOOL)savePurchase {
    [UIAlertView showWithTitle:nil message:@"已成功升级，你现在可以使用完整版功能了。" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:nil];
    BOOL ret = [UICKeyChainStore setString:@"1" forKey:FullVersionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ShowOrHideAds object:nil userInfo:nil];
    
    //update push setting
    DBUser *user = [DBUtil loadDBUserByName:[MemShared sharedInstance].userName];
    user.pushType = @1;
    [user save];
    
    return ret;
}

#pragma mark - Privilege

- (BOOL)checkPrivilege {
    BOOL privilege = [Utils isBuyer];
    if (!privilege) {
        [UIAlertView showWithTitle:nil message:UpgradeMsg cancelButtonTitle:@"不升级" otherButtonTitles:@[@"升级"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 0:
                    
                    break;
                case 1:
                    [self showPurchase];
                    break;
                default:
                    break;
            }
        }];
    }
    
    return privilege;
}

- (void)showPurchase {
    
    PurchaseViewController *vc = [PurchaseViewController new];
    vc.title = @"升级完整版";
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootVC = delegate.window.rootViewController;
    [rootVC presentViewController:nav animated:YES completion:nil];
    
}

@end
