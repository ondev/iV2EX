//
//  UIViewController+V2ex.h
//  v2ex
//
//  Created by Haven on 4/11/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (V2ex)
//- (void)createTopic:(NSString *)title content:(NSString *)content toNodeURL:(NSString *)nodeURL;
//- (void)replyTopic:(NSString *)content toTopicURL:(NSString *)topicURL;
- (void)upgradeToFullVersion;
- (void)restorePurchase;
- (BOOL)checkPrivilege;
@end
