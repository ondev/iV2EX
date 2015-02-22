//
//  ViewController.m
//  v2ex
//
//  Created by Haven on 18/11/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import "SiteViewController.h"
#import "NodesViewController.h"
#import <AFNetworking.h>
#import "NSString+Ext.h"
#import "NSURLRequest+Ext.h"
#import "TabViewController.h"
#import "TopicsViewController.h"
#import "MemTopic.h"
#import "GADBannerView.h"
#import "Utils.h"
#import "DataModel.h"
#import "DBUtil.h"
#import "MemShared.h"

extern NSString *ShowOrHideAds;

@interface SiteViewController () <UITableViewDataSource, UITableViewDelegate, DataModelDelegate, GADBannerViewDelegate> {
    GADBannerView *bannerView_;
}

@property (nonatomic, strong) NSDictionary *tags;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSArray *customConstraints;
@end

@implementation SiteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"社区";
    
    
    UIImage *img = [[UIImage imageNamed:@"head_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgView.image = img;
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];
    
    //init tag view
    self.tags = @{@"技术":@{@"程序员":@"programmer", @"Python":@"python", @"iDev":@"idev", @"Linux":@"linux", @"node.js":@"nodejs", @"云计算":@"cloud"}, @"创意":@{@"分享创造":@"create", @"设计":@"design", @"奇思妙想":@"ideas"}, @"好玩":@{@"分享发现":@"share", @"电子游戏":@"games", @"电影":@"movie", @"剧集":@"tv", @"音乐":@"music", @"旅游":@"travel", @"Android ":@"android", @"午夜俱乐部":@"afterdark"}, @"Apple":@{@"Mac OS X":@"macosx", @"iPhone":@"iphone", @"iPad":@"ipad", @"MBP":@"mbp", @"iMac":@"imac", @"Apple":@"apple"}, @"酷工作":@{@"酷工作":@"jobs", @"求职":@"cv", @"外包":@"outsourcing"}, @"交易":@{@"二手交易":@"all4all", @"物物交换":@"exchange", @"免费赠送":@"free", @"域名":@"dn"}, @"城市":@{@"北京":@"beijing", @"上海":@"shanghai", @"深圳":@"shenzhen", @"广州":@"guangzhou", @"杭州":@"hangzhou", @"成都":@"chengdu", @"昆明":@"kunming", @"纽约":@"nyc", @"洛杉矶":@"la"}, @"问与答":@"http://v2ex.com/go/qna", @"最新":@[], @"全部":@[]};
    
    
    [self setupShowView];
    [self showOrHideAds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrHideAds) name:ShowOrHideAds object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL fullVersion = [MemShared sharedInstance].fullVersion;
    if (!fullVersion) {
        [bannerView_ loadRequest:[Utils gadRequest]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showOrHideAds {
    BOOL fullVersion = [MemShared sharedInstance].fullVersion;
    
    [self constraints:!fullVersion];
}

- (void)constraints:(BOOL)showAds {
    if (self.customConstraints) {
        [self.view removeConstraints:self.customConstraints];
    }
    
    NSString *kAdsViewH = nil;
    NSString *kAdsViewV = nil;
    NSString *kTableViewH = nil;
    NSString *kTagleViewV = nil;
    if (showAds) {
            kAdsViewH = @"H:|[bannerView_]|";
            kAdsViewV = @"V:|-(64)-[bannerView_(50)]";
            kTableViewH = @"H:|[_tableView]|";
            kTagleViewV = @"V:[bannerView_][_tableView]|";
    }
    else {
            kAdsViewH = @"H:|[bannerView_]|";
            kAdsViewV = @"V:|-(64)-[bannerView_(0)]";
            kTableViewH = @"H:|[_tableView]|";
            kTagleViewV = @"V:[bannerView_][_tableView]|";
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_tableView, bannerView_);
    NSDictionary *view1Dic = NSDictionaryOfVariableBindings(bannerView_);
    NSDictionary *view2Dic = NSDictionaryOfVariableBindings(_tableView);
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kAdsViewH options:0 metrics:nil views:view1Dic]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kAdsViewV options:0 metrics:nil views:viewsDictionary]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kTableViewH options:0 metrics:nil views:view2Dic]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kTagleViewV options:0 metrics:nil views:viewsDictionary]];
    
    self.customConstraints = [NSArray arrayWithArray:result];
    [self.view addConstraints:result];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];

}

- (void)setupShowView {
    if (!_tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = YES;
        [self.view addSubview:_tableView];
    }
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (!bannerView_) {
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        bannerView_.translatesAutoresizingMaskIntoConstraints = NO;
        bannerView_.adUnitID = GoogleAdsId;
        bannerView_.rootViewController = self;
        bannerView_.delegate = self;
        [self.view addSubview:bannerView_];
    }
}


#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view {

}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    
}

#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    
}


- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] urlEncodedUTF8String];
        NSString *encodedKey = [key urlEncodedUTF8String];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

//http://cutecoder.org/programming/implementing-cookie-storage/
//http://blog.sina.com.cn/s/blog_708663ad01018ox4.html
//http://stackoverflow.com/questions/18555848/how-to-use-afnetworking-to-save-cookies-permanently-forever-until-the-app-is-de
//http://blog.csdn.net/justinjing0612/article/details/16182749
//http://hi.baidu.com/ncudlz/item/32df5de08796e70d560f1d06
//http://blog.csdn.net/crayondeng/article/details/16991579
- (BOOL)checkLogin {
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieJar cookies];
    for (NSHTTPCookie*cookie in cookies) {
        if([[cookie domain] rangeOfString:@"v2ex"].location != NSNotFound)
        {
            NSString *name = cookie.name;
            if ([name isEqualToString:@"auth"]) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdeitifier = @"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdeitifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdeitifier];
    }
    
    NSArray *keys = [self.tags allKeys];
    NSString *text = keys.count > indexPath.row ? [keys objectAtIndex:indexPath.row] : nil;
    cell.textLabel.text = text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.backgroundColor = [UIColor clearColor];
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private
- (void)didSelectIndex:(NSInteger)index {
    NSArray *keys = [self.tags allKeys];
    if (keys.count > index) {
        NSString *title = keys.count > index ? [keys objectAtIndex:index] : nil;
        if ([title isEqualToString:@"全部"]) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            NodesViewController *vc = (NodesViewController *)[sb instantiateViewControllerWithIdentifier:@"NodesViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if ([title isEqualToString:@"最新"]) {
            TopicsViewController *vc = [TopicsViewController new];
            vc.viewModel.nodeTitle = title;
            vc.viewModel.apiLoading = YES;
            [self.navigationController pushViewController:vc animated:YES];
            [vc showOrHideAds];
            
        }
        else if ([title isEqualToString:@"问与答"]) {
            
            TopicsViewController *vc = [[TopicsViewController alloc] init];
            vc.viewModel.apiLoading = NO;
            vc.viewModel.nodeTitle = title;
            MemNode *node = [DBUtil nodeByName:@"qna"];
            vc.viewModel.node = node;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            NSDictionary *segs = [self.tags objectForKey:title];
            TabViewController *vc = [TabViewController new];
            vc.title = title;
            vc.segs = segs;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ShowOrHideAds object:nil];
}

@end

//http://v2ex.com/follow/57095?t=1393661966  加好友, 57095为好友id,  t为帐号创建时间
//http://v2ex.com/unfollow/57095?t=1393661966  删好友  get
//http://v2ex.com/unblock/57095?t=1393661966   unblock
//http://v2ex.com/block/57095?t=1393661966   block
//http://v2ex.com/favorite/node/18?t=1393661966  收node, t为用户创建时间
//http://v2ex.com/favorite/topic/102249?t=dtbnumdmiegtolatcmchksakbepqndbm  收主题  GET, t为token
//http://v2ex.com/thank/reply/977406?t=umhryyqwcpmtutipbmdafqrtxpsghnsy  感谢回复，POST reply为回复ID
//http://v2ex.com/ajax/money  post
