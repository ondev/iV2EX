//
//  TopicsViewController.h
//  v2ex
//
//  Created by Haven on 19/12/13.
//  Copyright (c) 2013 LF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemNode.h"
#import "BaseTableViewController.h"
#import "TopicsViewModel.h"

@interface TopicsViewController : BaseTableViewController<LoadMoreTableFooterDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, weak) UINavigationController *nav;  //when as subview,have value


@property (nonatomic, strong) TopicsViewModel *viewModel;
@property (nonatomic) NSInteger tabIndex;
@end
