//
//  MoreViewController.m
//  v2ex
//
//  Created by Haven on 7/4/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "MoreViewController.h"
#import "AboutViewController.h"
#import "PushSettingViewController.h"
#import "MemShared.h"
#import "Utils.h"
#import <MessageUI/MessageUI.h>
#import <PurchaseViewController.h>
#import <CoreDataManager.h>
#import <UICKeyChainStore.h>
#import "UIAlertView+Blocks.h"
#import "DataModel.h"
#import "DBUtil.h"


extern NSString *ShowOrHideAds;
extern NSString *ShowLoginViewMsg;

@interface MoreViewController () <MFMailComposeViewControllerDelegate, DataModelDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) DataModel *resetModel;
@end

@implementation MoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableData = [@[@"推荐给朋友", @"升级完整版", @"意见反馈", @"检查新版本", @"关于我们", @"推送设置", @"抹掉所有数据"] mutableCopy];
    [self enableLoadMore:NO];
    [self enableRefresh:NO];
    
    [self showOrHideAds];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MemUtil updateUser];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _tableData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *title = [_tableData objectAtIndex:indexPath.row];
    if ([title isEqualToString:@"推荐给朋友"]) {
        cell = [self makeInviteCell];
    }
    else if ([title isEqualToString:@"升级完整版"]) {
        cell = [self makeRedeemCell];
    }
    else if ([title isEqualToString:@"意见反馈"]) {
        cell = [self makeFeedbackCell];
    }
    else if ([title isEqualToString:@"检查新版本"]) {
        cell = [self makeCheckVersionCell];
        cell.detailTextLabel.text = @"当前版本v1.1";
    }
    else if ([title isEqualToString:@"关于我们"]) {
        cell = [self makeAboutCell];
    }
    else if ([title isEqualToString:@"推送设置"]) {
        cell = [self makePushCell];
        MemUser *user = [MemShared sharedInstance].user;
        cell.detailTextLabel.text = [user.pushType intValue] == 0 ? @"关闭" : @"8:00-21:00";
    }
    else if ([title isEqualToString:@"抹掉所有数据"]) {
        cell = [self makeResetCell];
    }
    

    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [_tableData objectAtIndex:indexPath.row];
    if ([title isEqualToString:@"推荐给朋友"]) {
        [self showInvite];
    }
    else if ([title isEqualToString:@"升级完整版"]) {
        if (![Utils isBuyer]) {
            [self showPurchase];
        }
        else {
            [Utils showMessage:@"您已经是完整版本，无需升级"];
        }
    }
    else if ([title isEqualToString:@"意见反馈"]) {
        [self sendFeedBack];
    }
    else if ([title isEqualToString:@"检查新版本"]) {
        [self checkVersion];
    }
    else if ([title isEqualToString:@"关于我们"]) {
        AboutViewController *aboutVC = [AboutViewController new];
        aboutVC.title = title;
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
    else if ([title isEqualToString:@"推送设置"]) {
        if ([self checkPrivilege]) {
            PushSettingViewController *pushVC = [PushSettingViewController new];
            pushVC.title = title;
            [self.navigationController pushViewController:pushVC animated:YES];
        }
    }
    else if ([title isEqualToString:@"抹掉所有数据"]) {
        [[CoreDataManager sharedManager] resetCoreData];
        [UICKeyChainStore setString:@"0" forKey:FullVersionKey];
        
        NSString *userName = [MemUtil userName];
        
        if (userName) {
            [UICKeyChainStore setString:@"" forKey:userName];
        }
        NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
        [dfs setObject:nil forKey:UserNameKey];
        [dfs setObject:nil forKey:RemPasswdKey];
        [dfs setObject:nil forKey:AutoLoginKey];
        
        [[MemShared sharedInstance] logout];
        [MemShared sharedInstance].fullVersion = [Utils isBuyer];
        [[NSNotificationCenter defaultCenter] postNotificationName:ShowOrHideAds object:nil userInfo:nil];
        
        DBUser *user = [DBUtil loadDBUserByName:[MemShared sharedInstance].userName];
        user.pushType = @0;
        [user save];
        
        self.resetModel = [DataModel new];
        if ([MemShared sharedInstance].token) {
            
            [[_resetModel resetPush:[MemShared sharedInstance].token] subscribeNext:^(id x) {
                
                [Utils showMessage:@"成功抹掉所有数据"];
                [MemUtil updateUser];
                [self.tableView reloadData];
            }];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI Action
- (void)sendFeedBack {
    // Email Subject
    NSString *emailTitle = @"意见反馈";
    // Email Content
    NSString *messageBody = @"我建意：";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"v2exclub@163.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)checkVersion {
    [Utils showMessage:@"当前版本已是最新版本"];
}

- (void)showInvite {
    NSString *message = [MemShared sharedInstance].clientConfig[@"share"] ?: @"V2EX社区Native App V2EX Club问世了，还在用那费流量的Web App吗？ 何不来试一试功能强大的V2EX Club. 下载地址:http://www.sohoin.com";
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:message, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                             initWithActivityItems: arrayOfActivityItems applicationActivities:nil];
    [self presentViewController:activityVC  animated:YES completion:nil];
}



- (void)showPurchase {
    
    PurchaseViewController *vc = [PurchaseViewController new];
    vc.title = @"升级完整版";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
    if (model == _resetModel) {
        if (0 == [data[@"result"] integerValue]) {
        }
    }
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Config Cell
- (void)setupSepareteLineForCell:(UITableViewCell *)cell {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(15, 43, 290, 1)];
    v.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1];
    v.tag = 2;
    [cell.contentView addSubview:v];
}

- (UITableViewCell *)makeInviteCell {
    static NSString *cellIdentifier = @"InviteCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupSepareteLineForCell:cell];
    }
    
    return cell;
}

- (UITableViewCell *)makeRedeemCell {
    static NSString *cellIdentifier = @"RedeemCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupSepareteLineForCell:cell];
    }
    
    return cell;
}

- (UITableViewCell *)makeFeedbackCell {
    static NSString *cellIdentifier = @"FeedbackCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupSepareteLineForCell:cell];
    }
    
    return cell;
}

- (UITableViewCell *)makeCheckVersionCell {
    static NSString *cellIdentifier = @"CheckVersionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        [self setupSepareteLineForCell:cell];
    }
    
    return cell;
}

- (UITableViewCell *)makeAboutCell {
    static NSString *cellIdentifier = @"AboutCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupSepareteLineForCell:cell];
    }
    
    return cell;
}


- (UITableViewCell *)makePushCell {
    static NSString *cellIdentifier = @"PushSettingCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupSepareteLineForCell:cell];
    }
    
    return cell;
}

- (UITableViewCell *)makeResetCell {
    static NSString *cellIdentifier = @"ResetCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (UITableViewCell *)makeCleanCacheCell {
    static NSString *cellIdentifier = @"FeedbackCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 120, 44)];
        cacheLabel.tag = 1;
        cacheLabel.textAlignment = NSTextAlignmentRight;
        cacheLabel.textColor = [UIColor grayColor];
        [cell.contentView addSubview:cacheLabel];
    }
    
    UILabel *l = (UILabel *)[cell viewWithTag:1];
    if (l) {
        l.text = @"1.2M";
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
