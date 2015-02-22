//
//  NodesViewController.m
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import "NodesViewController.h"
#import "TopicsViewController.h"
#import "NSDate+TimeAgo.h"
#import "NodeListCell.h"
#import "MemShared.h"
#import "Utils.h"
#import "DataModel.h"

extern NSString *ShowLoginViewMsg;

@interface NodesViewController ()
@property (nonatomic, strong) NSArray *filteredData;

@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;

@end

@implementation NodesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.viewModel = [NodesViewModel new];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    self.viewModel = [NodesViewModel new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UINib *nib = [UINib nibWithNibName:@"NodeListCell_iPhone" bundle:nil];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"NodeCell"];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"NodeCell"];
    
    self.title = @"全部节点";
    
    
    UIImage *img = [[UIImage imageNamed:@"head_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgView.image = img;
    self.tableView.backgroundView = imgView;
    self.tableView.separatorColor = [UIColor clearColor];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor clearColor];
    
    @weakify(self);
    [[RACObserve(self.viewModel, nodes) ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [[RACObserve(self.viewModel, loading) skip:1] subscribeNext:^(NSNumber *loading){
        if (loading.boolValue) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
    [self enableNavigationTapGestrue:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self enableNavigationTapGestrue:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewModel.active = NO;
}

- (void)enableNavigationTapGestrue:(BOOL)enable {
    if (!_tapRecognizer) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarClicked:)];
        _tapRecognizer.numberOfTapsRequired = 2;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }
    if (enable) {
        [self.navigationController.navigationBar addGestureRecognizer:_tapRecognizer];
    }
    else {
        [self.navigationController.navigationBar removeGestureRecognizer:_tapRecognizer];
    }
}

-(void)navBarClicked:(UIGestureRecognizer*)recognizer{
    //add code to scroll your tableView to the top.
    [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_filteredData count];
    }
	
    return _viewModel.nodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NodeCell";
    NodeListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    MemNode *obj = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        obj = [_filteredData objectAtIndex:indexPath.row];
    }
    else {
        obj = [_viewModel.nodes objectAtIndex:indexPath.row];
    }
    cell.node = obj;
    NSString *topics = obj.topicCount;
    NSString *title  = obj.nodeTitle;
    cell.ibName.text = title;
    cell.ibTopicCount.text = [NSString stringWithFormat:@"%@个主题", topics];
    
    //create time
    NSString * timeStampString = obj.created;
    NSTimeInterval _interval = [timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    cell.ibCreateTime.text = [date timeAgo];
    
    cell.ibHeader.text = obj.header;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //show topic list
    MemNode *obj = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        obj = _filteredData.count > indexPath.row ? [_filteredData objectAtIndex:indexPath.row] : nil;
    }
    else {
        obj = _viewModel.nodes.count > indexPath.row ? [_viewModel.nodes objectAtIndex:indexPath.row] : nil;
    }
    TopicsViewController *topicVC = [TopicsViewController new];
    topicVC.viewModel.node = obj;
    [self.navigationController pushViewController:topicVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

#pragma mark - UISearchDisplayDelegate
//http://stackoverflow.com/questions/110332/filtering-nsarray-into-a-new-nsarray-in-objective-c
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

-(void)filterContentForSearchText:(NSString*)searchText {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.nodeTitle contains[cd] %@",searchText];
    self.filteredData = [_viewModel.nodes filteredArrayUsingPredicate:predicate];
}

@end
