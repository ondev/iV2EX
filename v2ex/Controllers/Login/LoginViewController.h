//
//  LoginViewController.h
//  v2ex
//
//  Created by Haven on 6/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginSuccess:(LoginViewController *)vc;
- (void)loginFaild:(LoginViewController *)vc;

@end

@interface LoginViewController : UIViewController

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@end
