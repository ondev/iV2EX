
//  main.m
//  v2ex
//
//  Created by Haven on 18/11/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [Bmob registerWithAppKey:@"a1ab67d65a3f6cd6aa3f9ae38fc7bfe5"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
