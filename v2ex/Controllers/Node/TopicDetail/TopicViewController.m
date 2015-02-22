//
//  TopicViewController.m
//  v2ex
//
//  Created by Haven on 8/25/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicContentCell.h"
#import "Utils.h"
#import "NSDate+TimeAgo.h"
#import "GADBannerView.h"
#import "MemShared.h"
#import "UIAlertView+Blocks.h"
#import "DataModel.h"

extern NSString *ShowOrHideAds;
extern NSString *ShowLoginViewMsg;

@interface TopicViewController ()<JSMessagesViewDelegate, JSMessagesViewDataSource, GADBannerViewDelegate, DataModelDelegate> {
    GADBannerView *bannerView_;
    BOOL bannerAnimated;
}
@property (nonatomic, strong) TopicContentCell *contentPrototypeCell;
@property (nonatomic, strong) DataModel *replyTopicModel;
@end

@implementation TopicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.viewModel = [TopicViewModel new];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"TopicContentCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"TopicContentCell"];
    self.contentPrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"TopicContentCell"];
    
    @weakify(self);
    RAC(self, title) = [[RACObserve(self.viewModel, topic.topicRepliesCount) ignore:nil] map:^id(id value) {
        return [NSString stringWithFormat:@"%@个回复", value];
    }];
    
    [[RACObserve(self.viewModel, topic.replies) skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    
//    [[NSBundle mainBundle] loadNibNamed:@"TopicContentView" owner:self options:nil];
    [[RACObserve(self, viewModel.topic) ignore:nil] subscribeNext:^(MemTopic * x) {
        @strongify(self);
        [self.tableView reloadData];
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

    [self enableRefresh:YES];
    //drag down refresh
    [[self.refreshHeaderView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self reloadTableViewDataSource];
        [self.viewModel fetchRefresh];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHideAds) name:ShowOrHideAds object:nil];
    
    
    [self showOrHideAds];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"回贴" style:UIBarButtonItemStylePlain target:self action:@selector(replayTopic)];
    
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

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ShowOrHideAds object:nil];
}

#pragma mark - Action
- (void)replayTopic {
    [self finishSend];
}

#pragma mark - ADS
- (void)showOrHideAds {
    [self showAdsWithAnimated:YES];
}

- (void)showAdsWithAnimated:(BOOL)animated {
    bannerAnimated = animated;
    if (![MemShared sharedInstance].fullVersion) {
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        if (animated) {
            bannerView_.frame = CGRectMake(0, 0, 320, 1);
        }
        else {
            bannerView_.frame = CGRectMake(0, 0, 320, 50);
        }
        
        // Specify the ad unit ID.
        bannerView_.adUnitID = GoogleAdsId;
        
        // Let the runtime know which UIViewController to restore after taking
        // the user wherever the ad goes and add it to the view hierarchy.
        bannerView_.rootViewController = self;
        self.tableView.tableHeaderView = bannerView_;
        
        // Initiate a generic request to load it with an ad.
        bannerView_.delegate = self;
        [bannerView_ loadRequest:[Utils gadRequest]];
    }
    else {
        self.tableView.tableHeaderView = nil;
    }
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view {
    if (bannerAnimated) {
        [self.tableView beginUpdates];
        [self.tableView setTableHeaderView:view];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            bannerView_.frame = CGRectMake(0, 0, 320, 50);
        } completion:^(BOOL finished) {
        }];
        [self.tableView endUpdates];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.viewModel.sortedReplies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TopicContentCell *tcCell = (TopicContentCell *)[tableView dequeueReusableCellWithIdentifier:@"TopicContentCell"];
        tcCell.topicTitle.text = self.viewModel.topic.topicTitle;
        tcCell.contentLabel.text = self.viewModel.topic.topicContent;
        tcCell.topicAuthorLabel.text = self.viewModel.topic.topicAuthorName;
        tcCell.topicReplayCountLabel.text = self.viewModel.topic.topicRepliesCount;
        tcCell.userIcon.layer.masksToBounds = YES;
        tcCell.userIcon.layer.cornerRadius = 15;
        
        NSString *timestamp = self.viewModel.topic.topicCreated;
        if (timestamp) {
            NSTimeInterval _interve = [timestamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interve];
            tcCell.topicTimeLabel.text = [date timeAgo];
        }
        else {
            tcCell.topicTimeLabel.text = @"NA";
        }
        
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:tcCell.userIcon];
        tcCell.userIcon.imageURL = [NSURL URLWithString:self.viewModel.topic.topicAuthorImgUrl];
        
        return tcCell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TopicContentCell *tcCell = self.contentPrototypeCell;
        tcCell.topicTitle.text = self.viewModel.topic.topicTitle;
        tcCell.contentLabel.text = self.viewModel.topic.topicContent;
        CGSize s = [tcCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return s.height+1;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - JSMessagesViewDelegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    if ([self checkPrivilege]) {
        [self finishSend];
        if ([[MemShared sharedInstance] isLogin]) {
            
            NSString *content = text;
            NSString *topicId = self.viewModel.topic.topicId;
            if (!content || !topicId) {
                return;
            }
            
            assert(content);
            assert(topicId);
            
            self.replyTopicModel = [DataModel new];
            _replyTopicModel.delegate  = self;
            [_replyTopicModel replyTopic:topicId content:content];
        }
        else {
            [UIAlertView showWithTitle:nil message:@"还未登录，请先登录" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                switch (buttonIndex) {
                    case 0:
                        [[NSNotificationCenter defaultCenter] postNotificationName:ShowLoginViewMsg object:nil];
                        break;
                    case 1:
                        break;
                    default:
                        break;
                }
            }];
        }
    }
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MemReply *reply = [self replyByIndexPath:indexPath];
    if ([[MemShared sharedInstance].userName isEqualToString:reply.userName]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    return JSBubbleMediaTypeText;
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyCustom;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyCustom;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleCircle;
}

- (JSInputBarStyle)inputBarStyle
{
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
- (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - JSMessagesViewDataSource
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemReply *reply = [self replyByIndexPath:indexPath];
    return reply.content;
}

- (NSString *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemReply *reply = [self replyByIndexPath:indexPath];
    NSTimeInterval _interve = [reply.created doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interve];
    NSString *ret = [NSString stringWithFormat:@"%ld#  %@回复于%@", (long)indexPath.row, reply.userName,  [date timeAgo]];
    return ret;

}

- (NSString *)avatarUrlForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemReply *reply = [self replyByIndexPath:indexPath];
    return reply.avatar_large;
}

- (MemReply *)replyByIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel.sortedReplies objectAtIndex:indexPath.row];
}

#pragma mark - Refresh
- (void)enableRefresh:(BOOL)enable {
    if (enable) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        self.refreshHeaderView = view;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            if (self.automaticallyAdjustsScrollViewInsets) {
                _refreshHeaderView.offset = 64;
            }
        }
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    else {
        [self.refreshHeaderView removeFromSuperview];
        self.refreshHeaderView = nil;
    }

}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return self.reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)reloadTableViewDataSource {
	_reloading = YES;
}

- (void)doneLoadingTableViewData {
    
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
    if (model == _replyTopicModel) {
        [self.refreshHeaderView showRefreshEffect:self.tableView];
    }
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    
}
@end
