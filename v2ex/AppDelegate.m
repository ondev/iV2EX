//
//  AppDelegate.m
//  v2ex
//
//  Created by Haven on 18/11/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import "AppDelegate.h"
#import "MemShared.h"
#import "LoginViewController.h"
#import "UIAlertView+Blocks.h"
#import "DBUser.h"
#import "MemShared.h"
#import "DataModel.h"
#import "DBUtil.h"
#import "Utils.h"
#import "MemUtil.h"
#import "FileUtil.h"
#import "DBTopic.h"
#import "MemTopic.h"
#import "PurchaseViewController.h"
#import "SiteViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TopicViewController.h"
#import <BmobSDK/Bmob.h>

//http://www.appiconsizes.com/

@interface AppDelegate()<LoginViewControllerDelegate, DataModelDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) DataModel *registerModel;
@property (nonatomic, strong) DataModel *onOffLineModel;

//FRP
@property (nonatomic, strong) DataModel *fetchNodes;
@property (nonatomic, strong) DataModel *fetchConfig;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSArray *nodes;
@property (nonatomic) BOOL appFromBackend;
@end

NSString *ShowLoginViewMsg = @"ShowLoginViewMsg";
NSString *ShowOrHideAds = @"ShowOrHideAds";

@implementation AppDelegate

//http://www.cnblogs.com/thefeelingofsimple/archive/2013/01/31/2886915.html
//http://stackoverflow.com/questions/7661254/nsregularexpression-to-extract-text-between-two-xml-tags
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *userName = [MemUtil userName];
    if (!userName) {
        NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
        [dfs setValue:[[MemShared sharedInstance] userName] forKeyPath:UserNameKey];
        [dfs synchronize];
    }
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieJar setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [self registerPushNotification];
    [Utils firstRunAfterInstall];
    [MemShared sharedInstance].fullVersion = [Utils isBuyer];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
//    [self requestAllNodeIfNeeded];
//    [self requestClientConfig];
//    [MemUtil updateUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upgradeFullVersion) name:ShowOrHideAds object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginView) name:ShowLoginViewMsg object:nil];
    
    self.fetchNodes = [DataModel new];
    RAC(self, nodes) = [[[_fetchNodes fetchAllNodes] logError] catchTo:[RACSignal empty]];
    @weakify(self);
    __block int test = 0;
    [[RACObserve(self, nodes) ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        NSArray *data = self.nodes;
        test++;
        NSLog(@"here:%d", test);
    } ];
    
    if (launchOptions) {
    
        NSDictionary* userInfor = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self accessPushNotification:userInfor];
    }
    
    [self askLocation];
    [self requestConfig];
    
    return YES;
}

- (void)requestConfig {
    self.fetchConfig = [DataModel new];
    [[_fetchConfig fetchClientConfig] subscribeNext:^(id x) {
        [MemShared sharedInstance].clientConfig = x;
    }];
}

- (void)askLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"为了获取更精确的分类贴子，请开启Location" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)accessPushNotification:(NSDictionary *)userInfor {
    NSString *s = [NSString stringWithFormat:@"%@", userInfor];
    NSLog(@"s=%@", s);
    if (userInfor) {
        UITabBarController *root = (UITabBarController *)self.window.rootViewController;
        root.delegate = self;
        UINavigationController *nav = (UINavigationController *)root.viewControllers[Site_Tab];
        SiteViewController *siteVC = nav.viewControllers[0];
        [siteVC.navigationController popToRootViewControllerAnimated:NO];
        
        TopicViewController *vc = [TopicViewController new];
        
        NSString *topicId = [NSString stringWithFormat:@"%@", userInfor[@"topicId"]];
        MemTopic *topic = [MemTopic new];
        topic.topicId = topicId;
        vc.viewModel.topic = topic;
        vc.hidesBottomBarWhenPushed = YES;
        [siteVC.navigationController pushViewController:vc animated:YES];
        vc.hidesBottomBarWhenPushed = NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self updateStatus:@(0)];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //执行你的任务
//        
//        
//        // call endBackgroundTask - should be executed back on
//        // main thread
//        __block BOOL finishRequest;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (bgTask != UIBackgroundTaskInvalid)
//            {
//                
//                //退出后台任务
//                [application endBackgroundTask:bgTask];
//                bgTask = UIBackgroundTaskInvalid;
//            }
//        });
//        
//        while(1)
//        {
//            [NSThread sleepForTimeInterval:5];
//            NSLog(@"Time remaining: %f",[application backgroundTimeRemaining]);
//        }
//    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [NetHelper setNetworkActivityIndicatorVisible:NO hide:YES];
    self.appFromBackend = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self updateStatus:@(1)];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)registerPushNotification {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
}

#pragma mark - MultiTasking
//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    MemUser *user = [MemShared sharedInstance].user;
//    if (user.autoBalance && ![user.daiyBalanceRecved boolValue]) {
//        self.dailyMissionModel = [DataModel new];
//        _dailyMissionModel.delegate  = self;
//        [_dailyMissionModel requestDailyBalance];
//        completionHandler(UIBackgroundFetchResultNewData);
//    }
//}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval interval = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    if (interval < 3) {
        [MemShared sharedInstance].coord = newLocation.coordinate;
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
}

#pragma mark - Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (deviceToken) {
        NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        [MemShared sharedInstance].token = token;
        [MemShared sharedInstance].tokenData = deviceToken;
        
        [self registerToBackendServer:deviceToken];
        
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog([error localizedDescription], nil);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (userInfo && _appFromBackend) {
        _appFromBackend = NO;
        [self accessPushNotification:userInfo];
    }
}


#pragma mark - NSNotificationCenter
- (void)showLoginView {
    
    LoginViewController *vc = [LoginViewController new];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController *rootVC = self.window.rootViewController;
    [rootVC presentViewController:nav animated:YES completion:nil];
}

- (void)showPurchaseView {
    PurchaseViewController *vc = [PurchaseViewController new];
    vc.title = @"升级完整版";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController *rootVC = self.window.rootViewController;
    [rootVC presentViewController:nav animated:YES completion:nil];
}

- (BOOL)checkPrivilege {
    BOOL privilege = [Utils isBuyer];
    if (!privilege) {
        [UIAlertView showWithTitle:nil message:UpgradeMsg cancelButtonTitle:@"不升级" otherButtonTitles:@[@"升级"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 0:
                    
                    break;
                case 1:
                    [self showPurchaseView];
                    break;
                default:
                    break;
            }
        }];
    }
    
    return privilege;
}

- (void)registerToBackendServer:(NSData *)tokenData {
    if (tokenData && [Utils isBuyer]) {
        self.registerModel = [DataModel new];
        
        
        BmobInstallation  *currentIntallation = [BmobInstallation currentInstallation];
        //设置token
        [currentIntallation setDeviceTokenFromData:tokenData];
        //设置订阅渠道
        [currentIntallation subsccribeToChannels:@[@"V2EX"]];
        //保存数据
        [currentIntallation saveInBackground];
        
        //因为上面如果是第一次插入数据，下面是改变表，所以要等服务器创建成功后才能更新。
        [self performSelector:@selector(enableServerPush) withObject:nil afterDelay:1];
    }
}

- (void)enableServerPush {
    
    //enable push
    NSString *token = [MemShared sharedInstance].token;
    [[_registerModel updatePush:@"1" token:token] subscribeNext:^(id x) {
        
    }];
    
    [self updateStatus:@(1)];
}

- (void)upgradeFullVersion {
    NSData *tokenData = [MemShared sharedInstance].tokenData;
    [self registerToBackendServer:tokenData];
}

- (void)updateStatus:(NSNumber *)status {
    if ([Utils isBuyer])
    {
        
        self.onOffLineModel = [DataModel new];
        
        NSString *token = [[MemShared sharedInstance] token];
        if (token) {
            [[_onOffLineModel updateOnline:[status stringValue] token:token] subscribeNext:^(id x) {
                DLog(@"Update online end");
            }];
        }
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    if (![MemShared sharedInstance].isLogin) {
//        if ([[tabBarController viewControllers] indexOfObject:viewController] == Profile_Tag) {
//            if ([self checkPrivilege]) {
//                [self showLoginView];
//            }
//            
//            return NO;
//        }
//    }
//    
//    if ([[tabBarController viewControllers] indexOfObject:viewController] == Profile_Tag) {
//        if ([MemShared sharedInstance].isLogin) {
//            UINavigationController *nav = (UINavigationController *)viewController;
//            ProfileViewController *profileVC = [nav viewControllers][0];
//            profileVC.delegate = self;
//        }
//    }
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewControlle {
    
}

#pragma mark - LoginViewControllerDelegate
- (void)loginSuccess:(LoginViewController *)vc {
    
    if ([MemShared sharedInstance].isLogin) {
        DBUser *loginUser = [DBUtil loadDBUserByName:[[MemShared sharedInstance] userName]];
        loginUser.pushType = @1;
        [loginUser save];
        [MemUtil updateUser];
    }
    
    [vc dismissViewControllerAnimated:YES completion:^{
//        UITabBarController *barVC = (UITabBarController *)self.window.rootViewController;
//        [barVC setSelectedIndex:Profile_Tag];
    }];
}

- (void)loginFaild:(LoginViewController *)vc {
    
}

#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
//    if (model == _clientConfig) {
//        [MemShared sharedInstance].clientConfig = data;
//    }
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    
}

@end
