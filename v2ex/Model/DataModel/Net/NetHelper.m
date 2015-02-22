//
//  NetHelper.m
//  OneMap
//
//  Created by Haven on 24/1/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NetHelper.h"
#import "SVProgressHUD.h"

@implementation NetHelper
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    [NetHelper setNetworkActivityIndicatorVisible:setVisible hide:NO];
}


+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible hide:(BOOL)hide {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (!hide) {
        if (setVisible)
            NumberOfCallsToSetVisible++;
        else
            NumberOfCallsToSetVisible--;
    }
    else {
        NumberOfCallsToSetVisible = 0;
    }
    
    
    NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    NSLog(@"NumberOfCallsToSetVisible=%ld", (long)NumberOfCallsToSetVisible);
    // Display the indicator as long as our static counter is > 0.
    if (NumberOfCallsToSetVisible > 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeNone];
    }
    else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [SVProgressHUD dismiss];
    }
}
@end
