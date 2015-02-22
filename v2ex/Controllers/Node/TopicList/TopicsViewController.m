//
//  TopicsViewController.m
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import "TopicsViewController.h"
#import "CreateTopicViewController.h"
#import "MemTopic.h"
#import "TopicCell.h"
#import "AsyncImageView.h"
#import "CRToast.h"
#import "NSDate+TimeAgo.h"
#import "MemShared.h"
#import "DataModel.h"
#import "Utils.h"
#import "TopicViewController.h"

extern NSString *ShowLoginViewMsg;

@interface TopicsViewController ()<DataModelDelegate>

@property (nonatomic, strong) TopicCell *contentPrototypeCell;

@end

@implementation TopicsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.viewModel = [TopicsViewModel new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Create a tap gesture with the method to call when tap gesture has been detected
    @weakify(self);
    [[[RACObserve(self.viewModel, topics) skip:1] ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
        NSInteger count = self.viewModel.topics.count;
        if (count > 20) {
            NSInteger insert = count % 20 ?: 20;
            NSInteger row = count - insert ;
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self.tableView flashScrollIndicators];
        }
    }];
    
    [[RACObserve(self.viewModel, loading) skip:1] subscribeNext:^(NSNumber *loading){
        @strongify(self);
        if (loading.boolValue) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
        } else {
            [SVProgressHUD dismiss];
            [self doneLoadingTableViewData];
        }
    }];
    
    //drag down refresh
    [[self.refreshHeaderView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel fetchRefresh];
    }];
    
    //drag up load more
    [[self.loadMoreFooterView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel fetchMoreWithPolicy:RequestReturnCacheDataElseLoad];
    }];
    
    RAC(self, title) = RACObserve(self.viewModel.node, nodeTitle);
    
    //register cell
    static NSString *CellIdentifier = @"TopicCell";
    UINib *nib = [UINib nibWithNibName:@"TopicCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    self.contentPrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"TopicCell"];
    
    nib =[UINib nibWithNibName:@"TestTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TestTableViewCell"];
    
    if (self.viewModel.node) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发贴" style:UIBarButtonItemStylePlain target:self action:@selector(createTopic)];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewModel.active = NO;
    self.viewModel.loading = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    CGRect f = self.view.frame;
//    NSLog(@"w=%f,h=%f", f.size.width, f.size.height);
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - Action
- (void)createTopic {
    if ([self checkPrivilege]) {
        if (![MemShared sharedInstance].isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ShowLoginViewMsg object:nil];
            return;
        }
        NSString *nodeName = self.viewModel.node.nodeName;
        CreateTopicViewController *createVC = [[CreateTopicViewController alloc] init];
        createVC.nodeName = nodeName;
        createVC.nodeURL = [NSString stringWithFormat:@"http://v2ex.com/new/%@", nodeName];;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:createVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _viewModel.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopicCell";
    TopicCell *cell = (TopicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    MemTopic *topic = _viewModel.topics.count > indexPath.row ? [_viewModel.topics objectAtIndex:indexPath.row] : nil;
    cell.topic = topic;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemTopic *topic = [_viewModel.topics objectAtIndex:indexPath.row];
    TopicCell *tcCell = self.contentPrototypeCell;
    CGFloat height = [tcCell calculateWithData:topic];
//    NSLog(@"height=%f", height);
    return height;
}



// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MemTopic *topic = [_viewModel.topics objectAtIndex:indexPath.row];
    
    TopicViewController *topicVC = [TopicViewController new];
    topicVC.viewModel.topic = topic;
    
    topicVC.hidesBottomBarWhenPushed = YES;
    if (self.automaticallyAdjustsScrollViewInsets) {
        [self.navigationController pushViewController:topicVC animated:YES];
    }
    else {
        [self.nav pushViewController:topicVC animated:YES];
    }
    topicVC.hidesBottomBarWhenPushed = NO;
}


#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    [self doneLoadingTableViewData];
    
    CRToastInteractionResponder *tapResponder = [CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap automaticallyDismiss:YES block:^(CRToastInteractionType interactionType) {
        NSLog(@"Tap Toast.");
    }];
    
    NSDictionary *options = @{kCRToastTextKey : @"您的网速太不给力了，请换一个快一点的网速再试吧。",
                              kCRToastNotificationTypeKey: @(CRToastTypeNavigationBar),
                              kCRToastTimeIntervalKey  : @(3.0),
                              kCRToastInteractionRespondersKey : @[tapResponder],
                              kCRToastImageKey         : [UIImage imageNamed:@"alert_icon.png"],
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor redColor],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)};
    [CRToastManager showNotificationWithOptions:options completionBlock:^{
        NSLog(@"Completed");
    }];
}


#pragma mark - LoadMoreTableFooterDelegate

- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view {
	return self.reloading;
}

- (BOOL)loadMoreTableFooterCanTrigger:(LoadMoreTableFooterView *)view {
    return [self.viewModel.node.topicCount integerValue] > self.viewModel.topics.count;
}

@end
