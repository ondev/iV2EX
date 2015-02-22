//
//  TabViewController.m
//  v2ex
//
//  Created by Haven on 8/3/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "TabViewController.h"
#import "HMSegmentedControl.h"
#import "CreateTopicViewController.h"
#import "TopicsViewController.h"
#import "DBUtil.h"
#import "MemShared.h"
#import "GADBannerView.h"
#import "Utils.h"
#import "UIAlertView+Blocks.h"

extern NSString *ShowLoginViewMsg;
extern NSString *ShowOrHideAds;

@interface TabViewController ()<GADBannerViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    
    GADBannerView *bannerView_;
}
@property(nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *customConstraints;
@property (nonatomic, strong) TopicsViewController *currentVC;

@end

@implementation TabViewController

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

    self.view.backgroundColor = ThemeColor;
    
    NSArray *names = [self.segs allKeys];
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:names];
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
    
    //add pageview controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @(30)}];
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageViewController.doubleSided = YES;
    self.pageViewController.view.clipsToBounds = YES;
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    self.currentVC = (TopicsViewController *)[self topicsViewControllerForIndex:0];
    [self.pageViewController setViewControllers:@[_currentVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    if (!bannerView_) {
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        bannerView_.translatesAutoresizingMaskIntoConstraints = NO;
        bannerView_.adUnitID = GoogleAdsId;
        bannerView_.rootViewController = self;
//        bannerView_.delegate = self;
        [self.view addSubview:bannerView_];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHideAds) name:ShowOrHideAds object:nil];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发贴" style:UIBarButtonItemStylePlain target:self action:@selector(createTopic)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self showOrHideAds];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect f = self.view.frame;
//    NSLog(@"tw=%f, th=%f", f.size.width, f.size.height);
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.view removeConstraints:self.view.constraints];
    [self constraints:!YES];
}

- (void)showOrHideAds {
    BOOL fullVersion = [MemShared sharedInstance].fullVersion;
    if (!fullVersion) {
        [bannerView_ loadRequest:[Utils gadRequest]];
    }
    
    [self constraints:!YES];
}

- (void)constraints:(BOOL)showAds {
    if (self.customConstraints) {
        [self.view removeConstraints:self.customConstraints];
    }
    
    UIView *pageView = self.pageViewController.view;
    NSString *kAdsH = @"H:|[bannerView_]|";
    NSString *kAdsV = @"V:|-(14)-[bannerView_(50)]";
    NSString *kSegmentH = @"H:|[_segmentedControl]|";
    NSString *kSegmentV = @"V:[bannerView_][_segmentedControl(40)]";
    NSString *kPageH = @"H:|[pageView]|";
    NSString *kPageV = @"V:[_segmentedControl][pageView]|";
    if (showAds) {
        kAdsH = @"H:|[bannerView_]|";
        kAdsV = @"V:|-(64)-[bannerView_(50)]";
        kSegmentH = @"H:|[_segmentedControl]|";
        kSegmentV = @"V:[bannerView_][_segmentedControl(40)]";
        kPageH = @"H:|[pageView]|";
        kPageV = @"V:[_segmentedControl][pageView]|";
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_segmentedControl, pageView, bannerView_);
    NSDictionary *view1Dic = NSDictionaryOfVariableBindings(_segmentedControl);
    NSDictionary *view2Dic = NSDictionaryOfVariableBindings(pageView);
    NSDictionary *view3Dic = NSDictionaryOfVariableBindings(bannerView_);
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kAdsH options:0 metrics:nil views:view3Dic]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kAdsV options:0 metrics:nil views:viewsDictionary]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kSegmentH options:0 metrics:nil views:view1Dic]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kSegmentV options:0 metrics:nil views:viewsDictionary]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kPageH options:0 metrics:nil views:view2Dic]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kPageV options:0 metrics:nil views:viewsDictionary]];
    
    self.customConstraints = [NSArray arrayWithArray:result];
    [self.view addConstraints:result];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view layoutIfNeeded];
//    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [self constraints:YES];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    [self constraints:NO];
}

#pragma mark - HMSegmentedControlEvent
- (void)segmentedControlChangedValue:(HMSegmentedControl *)sender {
//    _paginatorView.currentPageIndex = sender.selectedSegmentIndex;
    TopicsViewController *vc = (TopicsViewController *)[self topicsViewControllerForIndex:sender.selectedSegmentIndex];    
    [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.currentVC = vc;
    
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(TopicsViewController *)viewController {
    if (viewController == _currentVC) {
        NSUInteger index = [viewController tabIndex];
        if (index == 0) {
            return nil;
        }
        return [self topicsViewControllerForIndex:index - 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(TopicsViewController *)viewController {
    if (viewController == _currentVC) {
        
        NSUInteger index = [viewController tabIndex];
        if (index == [self.segs count]) {
            return nil;
        }
        return [self topicsViewControllerForIndex:index + 1];
    }
    
    return nil;
}


#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)topicsViewControllerForIndex:(NSInteger)index {
    NSArray *names = [self.segs allKeys];
    if (index >= 0 && index < names.count) {
        
        TopicsViewController *topicVC = [TopicsViewController new];
        NSString *key = [names objectAtIndex:index];
        NSString *value = [self.segs objectForKey:key];
        
        MemNode *node = [DBUtil nodeByName:value];
        topicVC.viewModel.apiLoading = NO;
        topicVC.viewModel.node = node;
        topicVC.tabIndex = index;
        topicVC.nav = self.navigationController;
        
        return topicVC;
    }
    
    return nil;
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.currentVC = (TopicsViewController *)[pageViewController.viewControllers objectAtIndex:0];
    _segmentedControl.selectedSegmentIndex = _currentVC.tabIndex;
}



#pragma mark - Action
- (void)createTopic {
    if ([self checkPrivilege]) {
        if (![MemShared sharedInstance].isLogin) {
            
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
    //        [[NSNotificationCenter defaultCenter] postNotificationName:ShowLoginViewMsg object:nil];
            return;
        }
        NSInteger currentNodeIndex = _currentVC.tabIndex;
        NSArray *names = [self.segs allKeys];
        NSString *key = [names objectAtIndex:currentNodeIndex];
        NSString *value = [self.segs objectForKey:key];
        
        CreateTopicViewController *createVC = [[CreateTopicViewController alloc] init];
        createVC.nodeName = value;
        createVC.nodeURL = [NSString stringWithFormat:@"http://v2ex.com/new/%@", value];;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:createVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ShowOrHideAds object:nil];
}
@end
