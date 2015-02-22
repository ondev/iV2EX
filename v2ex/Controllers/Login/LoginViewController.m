//
//  LoginViewController.m
//  v2ex
//
//  Created by Haven on 6/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "LoginViewController.h"
#import "AFNetworking.h"
#import "NSURLRequest+Ext.h"
#import "MemShared.h"
#import "Utils.h"
#import "TFHpple.h"
#import "DataModel.h"
#import "ASTextField.h"
#import "CBButton.h"

@interface LoginViewController ()<DataModelDelegate>
- (IBAction)touchBG:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passWordField;
@property (weak, nonatomic) IBOutlet UIView *loginPanel;
@property (nonatomic) BOOL loginPanelMoved;

@property (weak, nonatomic) IBOutlet CBButton *remPasswdBtn;
@property (weak, nonatomic) IBOutlet CBButton *autoLoginBtn;

@property (nonatomic, strong) DataModel *loginModel;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:233/255.0 green:232/255.0 blue:227/255.0 alpha:1.0];
    self.title = @"登陆";
    
    self.remPasswdBtn.sideString = @"记住密码";
    self.autoLoginBtn.sideString = @"自动登录";
    
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    BOOL remPasswd = [dfs boolForKey:RemPasswdKey];
    BOOL autoLogin = [dfs boolForKey:AutoLoginKey];
    self.remPasswdBtn.selected = remPasswd;
    self.autoLoginBtn.selected = autoLogin;
    
    [_userNameField setupTextFieldWithIconName:@"user_name_icon"];
    [_passWordField setupTextFieldWithIconName:@"password_icon"];
    
    NSString *userName = [MemUtil userName];
    _userNameField.text = userName;
    
    if (remPasswd) {
        _passWordField.text = [Utils getPasswdOfUser:userName];
    }
    
    if (autoLogin) {
        [self performSelector:@selector(startLogin:) withObject:nil afterDelay:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)checkBoxTrigger:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    if (btn == _autoLoginBtn) {
        if (btn.selected) {
            _remPasswdBtn.selected = YES;
        }
        
        [dfs setBool:btn.selected forKey:AutoLoginKey];
        [dfs setBool:btn.selected forKey:RemPasswdKey];
    }
    else if (btn == _remPasswdBtn) {
        [dfs setBool:btn.selected forKey:RemPasswdKey];
    }
    
    [dfs synchronize];
}

- (IBAction)touchBG:(id)sender {
    [self.userNameField resignFirstResponder];
    [self.passWordField resignFirstResponder];
    if (!IS_IPHONE5 && _loginPanelMoved) {
        self.loginPanelMoved = NO;
        CGRect r = self.loginPanel.frame;
        r.origin.y += 30;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.loginPanel.frame = r;
        } completion:^(BOOL finished) {
            self.loginPanel.frame = r;
        }];
    }
}


- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startLogin:(id)sender {
    if (self.userNameField.text.length <= 3 || self.passWordField.text.length <= 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户名密码必须填写。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    self.loginModel = [DataModel new];
    _loginModel.delegate = self;
    [_loginModel login:self.userNameField.text passwd:self.passWordField.text];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _userNameField) {
        [_passWordField becomeFirstResponder];
    }
    else {
        [self startLogin:nil];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!IS_IPHONE5 && !_loginPanelMoved) {
        self.loginPanelMoved = YES;
        CGRect r = self.loginPanel.frame;
        r.origin.y -= 30;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.loginPanel.frame = r;
        } completion:^(BOOL finished) {
            self.loginPanel.frame = r;
        }];
    }
}

#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
    if ([MemShared sharedInstance].isLogin) {
        if (self.remPasswdBtn.selected) {
            [Utils saveUser:self.userNameField.text passwd:self.passWordField.text];
        }
        
        if ([_delegate respondsToSelector:@selector(loginSuccess:)]) {
            [_delegate loginSuccess:self];
        }
    }
    }

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    
}

@end
