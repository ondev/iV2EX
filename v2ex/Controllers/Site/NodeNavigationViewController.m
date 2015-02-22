//
//  NodeNavigationViewController.m
//  v2ex
//
//  Created by Haven on 8/28/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import "NodeNavigationViewController.h"
#import "NodeNavigationTableViewCell.h"
#import "MemShared.h"
#import "DBUser.h"
#import "DBUtil.h"
#import "Utils.h"

extern NSString *ShowLoginViewMsg;

@interface NodeNavigationViewController () <DataModelDelegate>
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *rowHeights;
@property (nonatomic, strong) NodeNavigationTableViewCell *prototypeCell;
@end

@implementation NodeNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"社区";
    
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"navi.json"];
    path = [[NSBundle mainBundle] pathForResource:@"navi" ofType:@"json"];

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    self.navigations = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    self.sectionTitles = [NSMutableArray new];
    for (NSDictionary *section in _navigations) {
        [self.sectionTitles addObject:[section allKeys][0]];
    }
    
    static NSString *CellIdentifier = @"NodeNavigationTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"NodeNavigationTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"NodeNavigationTableViewCell"];
    self.prototypeCell.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self enableRefresh:NO];
    [self enableLoadMore:NO];
    
    
    NodeNavigationTableViewCell *cell = self.prototypeCell;
    self.rowHeights = [NSMutableArray new];
    NSInteger count = _sectionTitles.count;
    for (int index = 0; index < count; index++) {
        NSArray *values = [[_navigations objectAtIndex:index] allValues][0];
        if (index == 0) {
            
            DBUser *user = [DBUtil loadDBUser];
            values = user.collections;
        }
        [cell.adapteView reset];
        cell.adapteView.data = values;
        NSInteger height = values.count > 0 ? [cell cacluateHeight] : 50;
        [_rowHeights addObject:@(height)];
    }
    
    [self showOrHideAds];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkLogin];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)checkLogin {
    if (![MemShared sharedInstance].isLogin) {
        UIBarButtonItem *loginItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(login)];
        self.navigationItem.rightBarButtonItem = loginItem;
    }
    else {
        UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"登出" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
        self.navigationItem.rightBarButtonItem = logoutItem;
    }
}

- (void)login {
    if ([self checkPrivilege]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ShowLoginViewMsg object:nil];
    }
}

- (void)logout {
    self.logoutModel = [DataModel new];
    self.logoutModel.delegate = self;
    [self.logoutModel logout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *nodeCellIdentifier = @"NodeNavigationTableViewCell";
    NodeNavigationTableViewCell *cell = (NodeNavigationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:nodeCellIdentifier];
    NSArray *values = [[_navigations objectAtIndex:indexPath.section] allValues][0];
    
    if (indexPath.section == 0) {
        
        DBUser *user = [DBUtil loadDBUser];
        values = user.collections;
    }
    
    [cell.adapteView reset];
    cell.adapteView.data = values;
    cell.adapteView.nav = self.navigationController;
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.selectionStyle = 0;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [_rowHeights objectAtIndex:indexPath.section];
    if (indexPath.section == 0) {
        NodeNavigationTableViewCell *cell = self.prototypeCell;
        
        DBUser *user = [DBUtil loadDBUser];
        NSArray *values = user.collections;
        [cell.adapteView reset];
        cell.adapteView.data = values;
        NSInteger height = values.count > 0 ? [cell cacluateHeight] : 50;
        
        return height;
    }
    return [height floatValue];
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [UIView new];
    v.backgroundColor = [UIColor colorWithRed:233/255.0 green:232/255.0 blue:227/255.0 alpha:1.0];
    v.frame = CGRectMake(0, 0, 320, 30);
    UILabel *l = [UILabel new];
    l.frame  = CGRectMake(20, 0, 320, 30);;
    l.text = [_sectionTitles objectAtIndex:section];
    [v addSubview:l];
    
    UIView *line1 = [UIView new];
    line1.frame = CGRectMake(0, 0, 320, 1);
    line1.backgroundColor = [UIColor lightGrayColor];
    [v addSubview:line1];
    
    UIView *line2 = [UIView new];
    line2.frame = CGRectMake(0, 29, 320, 1);
    line2.backgroundColor = [UIColor lightGrayColor];
    [v addSubview:line2];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

#pragma mark - DataModelDelegate
- (void)dataModel:(DataModel *)model didFinishWithData:(id)data {
    if (model == _logoutModel) {
        [Utils showMessage:@"登出成功"];
    }
}

- (void)dataModel:(DataModel *)model didFailWithError:(NSError *)error {
    if (model == _logoutModel) {
        [Utils showMessage:@"登出失败"];
    }
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
