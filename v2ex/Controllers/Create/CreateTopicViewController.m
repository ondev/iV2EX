//
//  CreateTopicViewController.m
//  v2ex
//
//  Created by Haven on 4/11/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "CreateTopicViewController.h"
#import "GCPlaceholderTextView.h"
#import "UIViewController+V2ex.h"
#import "DataModel.h"
#import "UIAlertView+Blocks.h"
#import "MemShared.h"
#import "Utils.h"

@interface CreateTopicViewController ()<DataModelDelegate>

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *topicContentView;
@property (weak, nonatomic) IBOutlet UITextField *topicTitleView;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) DataModel *createTopicModel;
@end

@implementation CreateTopicViewController

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
    self.title = @"发布主题";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(send:)];
    self.view.backgroundColor = ThemeColor;
    
    if (!IS_IPHONE5) {
        self.sendBtn.hidden = YES;
    }
    
    self.topicTitleView.layer.borderWidth = 1;
    self.topicTitleView.layer.masksToBounds = YES;
    self.topicTitleView.layer.cornerRadius = 5;
    self.topicContentView.layer.borderWidth = 1;
    self.topicContentView.layer.masksToBounds = YES;
    self.topicContentView.layer.cornerRadius = 5;
    self.topicContentView.placeholder = @"在此输入您要发布的内容";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender {
    if ([[MemShared sharedInstance] isLogin]) {
        
        NSString *title = self.topicTitleView.text;
        NSString *content = self.topicContentView.text;
        NSString *nodeName = self.nodeName;
        if (!title || !content || !nodeName) {
            [Utils showMessage:@"所有的都必须填写!请匆灌水,违者封号!!"];
            return;
        }
        
        assert(title);
        assert(content);
        assert(nodeName);
        
        self.createTopicModel = [DataModel new];
        _createTopicModel.delegate = self;
        [_createTopicModel createTopic:title toNode:nodeName content:content];
    }
    else {
        [Utils showMessage:@"还未登录，请先登录"];
    }
    
//    [self createTopic:title content:content toNodeURL:nodeURL];
}

#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
    if (_createTopicModel == model) {
        
        [UIAlertView showWithTitle:nil message:@"发布成功" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == [alertView cancelButtonIndex]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    
}

@end
