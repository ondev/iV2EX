//
//  BaseTableViewController.m
//  v2ex
//
//  Created by Haven on 18/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "BaseTableViewController.h"
#import "MemShared.h"
#import "GADBannerView.h"
#import "Utils.h"
#import "TopicsViewController.h"

extern NSString *ShowOrHideAds;

@interface BaseTableViewController ()<GADBannerViewDelegate> {
    GADBannerView *bannerView_;
    BOOL bannerAnimated;
}
@end

@implementation BaseTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self enableRefresh:YES];
    [self enableLoadMore:YES];
    
    UIImage *img = [[UIImage imageNamed:@"head_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgView.image = img;
    self.tableView.backgroundView = imgView;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHideAds) name:ShowOrHideAds object:nil];
}

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

- (void) showHeader:(BOOL)show animated:(BOOL)animated{
    
    CGRect closedFrame = CGRectMake(0, 0, self.view.frame.size.width, 1);
    CGRect newFrame = show ? CGRectMake(0, 0, self.view.frame.size.width, 50) : closedFrame;
    
    if(animated){
        // The UIView animation block handles the animation of our header view
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        // beginUpdates and endUpdates trigger the animation of our cells
        [self.tableView beginUpdates];
    }
    
    bannerView_.frame = newFrame;
    [self.tableView setTableHeaderView:bannerView_];
    
    if(animated){
        [self.tableView endUpdates];
        [UIView commitAnimations];
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

- (void)enableRefresh:(BOOL)enable {
    if (enable) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.view addSubview:view];
        self.refreshHeaderView = view;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            if (self.automaticallyAdjustsScrollViewInsets) {
                _refreshHeaderView.offset = 0;
                if ([self isKindOfClass:[TopicsViewController class]]) {
                    TopicsViewController *vc = (TopicsViewController *)self;
                    if (!vc.nav) {
                        _refreshHeaderView.offset = 64;
                    }
                }
            }
        }
        [_refreshHeaderView refreshLastUpdatedDate];
    }
    else {
        [self.refreshHeaderView removeFromSuperview];
        self.refreshHeaderView = nil;
    }
}

- (void)enableLoadMore:(BOOL)enable {
    if (enable) {
        LoadMoreTableFooterView *view = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, self.tableView.contentSize.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.view addSubview:view];
        self.loadMoreFooterView = view;
    }
    else {
        [self.loadMoreFooterView removeFromSuperview];
        self.loadMoreFooterView = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Methord
- (void)reloadTableViewDataSource {
	_reloading = YES;
}

- (void)doneLoadingTableViewData {
    
	_reloading = NO;
	[_loadMoreFooterView loadMoreScrollViewDataSourceDidFinishedLoading:self.tableView];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_loadMoreFooterView loadMoreScrollViewDidEndDragging:scrollView];
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - LoadMoreTableFooterDelegate
- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view {
    
}


- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view {
    return _reloading;
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ShowOrHideAds object:nil];
}



@end
