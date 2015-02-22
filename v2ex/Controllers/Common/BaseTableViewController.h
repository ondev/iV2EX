//
//  BaseTableViewController.h
//  v2ex
//
//  Created by Haven on 18/2/14.
//  Copyright (c) 2014 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadMoreTableFooterView.h"
#import "EGORefreshTableHeaderView.h"

@interface BaseTableViewController : UITableViewController<LoadMoreTableFooterDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong) LoadMoreTableFooterView *loadMoreFooterView;
@property (nonatomic) BOOL reloading;

- (void)enableRefresh:(BOOL)enable;
- (void)enableLoadMore:(BOOL)enable;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)showOrHideAds;
- (void)showAdsWithAnimated:(BOOL)animated;
@end
